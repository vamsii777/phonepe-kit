//
//  PhonePeV2Request.swift
//
//
//  Created for PhonePe v2 API support.
//

import Foundation
import NIO
import NIOFoundationCompat
import NIOHTTP1
import AsyncHTTPClient

/// An actor that handles PhonePe v2 API requests using OAuth2 Bearer token authentication.
///
/// `PhonePeV2APIHandler` manages the full token lifecycle automatically:
/// - Fetches a new token on the first request via the `client_credentials` grant.
/// - Caches the token in memory.
/// - Re-fetches when the cached token has less than 60 seconds of remaining validity.
///
/// All outbound requests include an `Authorization: O-Bearer <token>` header and send
/// the request body as direct JSON (no base64 wrapping required by v2).
///
/// ## Thread Safety
/// Being an `actor`, all mutable state (the token cache) is automatically serialised.
/// Concurrent callers will each `await` the token, but only the first will trigger a
/// network fetch; subsequent callers receive the cached value once the actor is free.
actor PhonePeV2APIHandler {

    // MARK: - Token cache

    private struct CachedToken {
        let accessToken: String
        let expiresAt: Date

        /// `true` when the token has more than 60 seconds of remaining validity.
        var isValid: Bool {
            expiresAt > Date(timeIntervalSinceNow: 60)
        }
    }

    private var cachedToken: CachedToken?

    // MARK: - Dependencies

    private let httpClient: HTTPClient
    private let clientId: String
    private let clientSecret: String
    private let clientVersion: Int
    private let environment: Environment
    private let decoder: JSONDecoder

    // MARK: - Init

    /// Creates a new handler for v2 requests.
    ///
    /// - Parameters:
    ///   - httpClient: Shared `AsyncHTTPClient` instance used for all network calls.
    ///   - clientId: OAuth2 client identifier issued by PhonePe.
    ///   - clientSecret: OAuth2 client secret issued by PhonePe.
    ///   - clientVersion: Client version integer (usually `1`).
    ///   - environment: Target environment (`.production` or `.sandbox`).
    init(httpClient: HTTPClient,
         clientId: String,
         clientSecret: String,
         clientVersion: Int,
         environment: Environment) {
        self.httpClient = httpClient
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.clientVersion = clientVersion
        self.environment = environment
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .secondsSince1970
    }

    // MARK: - Public send

    /// Sends an authenticated v2 API request and returns a decoded `Codable` response.
    ///
    /// The method automatically:
    /// 1. Obtains a valid `O-Bearer` token (cached or freshly fetched).
    /// 2. Builds the full URL from `environment.v2BaseUrl + path`.
    /// 3. Attaches `Content-Type: application/json`, `Accept: application/json`,
    ///    and `Authorization: O-Bearer <token>` headers.
    /// 4. Sends the request body as raw JSON (no base64 wrapping).
    /// 5. Decodes the response body into `T`.
    ///
    /// - Parameters:
    ///   - method: HTTP method (`.GET`, `.POST`, etc.).
    ///   - path: Path appended to the resolved base URL (e.g. `"/checkout/v2/pay"`).
    ///   - query: Optional URL query string (without the leading `?`).
    ///   - body: Optional request body; must be serialised JSON.
    ///   - headers: Additional headers merged over the defaults.
    ///   - baseUrl: Overrides `environment.v2BaseUrl` when provided (used for the health endpoint).
    /// - Returns: The decoded response of type `T`.
    /// - Throws: ``PhonePeError`` on non-2xx responses, empty bodies, or decoding failures.
    func send<T: Codable>(
        method: HTTPMethod,
        path: String,
        query: String = "",
        body: HTTPClientRequest.Body? = nil,
        headers: HTTPHeaders,
        baseUrl: String? = nil
    ) async throws -> T {
        let token = try await getValidToken()

        var _headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "O-Bearer \(token)"
        ]
        headers.forEach { _headers.replaceOrAdd(name: $0.name, value: $0.value) }

        let resolvedBaseUrl = baseUrl ?? environment.v2BaseUrl
        var request = HTTPClientRequest(url: "\(resolvedBaseUrl)\(path)\(query.isEmpty ? "" : "?\(query)")")
        request.headers = _headers
        request.method = method
        request.body = body

        let response = try await httpClient.execute(request, timeout: .seconds(60))
        let responseData = try await response.body.collect(upTo: 1024 * 1024 * 100)

        guard responseData.readableBytes > 0 else {
            throw PhonePeError(
                success: false,
                code: .EMPTY_RESPONSE,
                message: "Server returned empty response body (HTTP \(response.status.code))"
            )
        }

        let data = Data(buffer: responseData)

        // For non-2xx responses, attempt to surface a structured PhonePeError.
        if response.status.code < 200 || response.status.code >= 300 {
            if let apiError = try? decoder.decode(PhonePeError.self, from: data) {
                throw apiError
            }
            throw PhonePeError(
                success: false,
                code: .unknown("HTTP_\(response.status.code)"),
                message: "Request failed with HTTP \(response.status.code)"
            )
        }

        return try decoder.decode(T.self, from: data)
    }

    // MARK: - Token management

    /// Returns a valid cached token, or fetches a new one if none exists or the cached
    /// token has less than 60 seconds of remaining validity.
    private func getValidToken() async throws -> String {
        if let cached = cachedToken, cached.isValid {
            return cached.accessToken
        }
        return try await fetchToken()
    }

    /// Fetches a fresh OAuth2 token using the `client_credentials` grant and caches it.
    ///
    /// The token endpoint accepts `application/x-www-form-urlencoded` and returns a JSON
    /// body containing `access_token` and `expires_at` (Unix epoch seconds).
    private func fetchToken() async throws -> String {
        let body = "client_id=\(clientId)&client_secret=\(clientSecret)&client_version=\(clientVersion)&grant_type=client_credentials"

        var request = HTTPClientRequest(url: environment.v2TokenUrl)
        request.method = .POST
        request.headers = ["Content-Type": "application/x-www-form-urlencoded",
                           "Accept": "application/json"]
        request.body = .bytes(.init(string: body))

        let response = try await httpClient.execute(request, timeout: .seconds(30))
        let responseData = try await response.body.collect(upTo: 1024 * 1024)

        guard responseData.readableBytes > 0 else {
            throw PhonePeError(
                success: false,
                code: .EMPTY_RESPONSE,
                message: "Empty response from OAuth2 token endpoint"
            )
        }

        let tokenData = Data(buffer: responseData)

        // Propagate structured error responses (e.g. 401 Unauthorized) as PhonePeError.
        if response.status.code < 200 || response.status.code >= 300 {
            if let apiError = try? decoder.decode(PhonePeError.self, from: tokenData) {
                throw apiError
            }
            throw PhonePeError(
                success: false,
                code: .AUTHORIZATION_FAILED,
                message: "OAuth2 token request failed with HTTP \(response.status.code)"
            )
        }

        let tokenResponse = try decoder.decode(V2TokenResponse.self, from: tokenData)

        // Prefer the epoch-based `expires_at` field; fall back to duration-based `expires_in`
        // if `expires_at` is absent (defensive for any future API change).
        let expiresAt: Date
        if let epoch = tokenResponse.expiresAt {
            expiresAt = Date(timeIntervalSince1970: TimeInterval(epoch))
        } else if let seconds = tokenResponse.expiresIn {
            expiresAt = Date(timeIntervalSinceNow: TimeInterval(seconds))
        } else {
            // Fallback: treat as valid for 7 days (standard PhonePe token lifetime).
            expiresAt = Date(timeIntervalSinceNow: 7 * 24 * 3600)
        }

        cachedToken = CachedToken(accessToken: tokenResponse.accessToken, expiresAt: expiresAt)
        return tokenResponse.accessToken
    }
}

// MARK: - Token response model

/// Internal model for decoding the OAuth2 token endpoint response.
///
/// PhonePe returns either `expires_at` (preferred, epoch-based) or `expires_in`
/// (duration in seconds). Both fields are decoded as optional for resilience.
private struct V2TokenResponse: Decodable {
    /// The opaque Bearer token string.
    let accessToken: String
    /// Unix epoch timestamp (seconds) at which the token expires. Preferred over `expiresIn`.
    let expiresAt: Int?
    /// Remaining validity in seconds. Used only when `expiresAt` is absent.
    let expiresIn: Int?

    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresAt = "expires_at"
        case expiresIn = "expires_in"
    }
}
