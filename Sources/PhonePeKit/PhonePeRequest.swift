//
//  PhonePeRequest.swift
//
//
//  Created by Vamsi Madduluri on 29/12/23.
//

import Foundation
import NIO
import NIOFoundationCompat
import NIOHTTP1
import AsyncHTTPClient

// MARK: - Base URL constants

internal let PhonePeAPIBase = "https://api.phonepe.com/apis/hermes"
internal let PhonePeAPISandbox = "https://api-preprod.phonepe.com/apis/pg-sandbox"
internal let PhonePeHealthStatusBase: String = "https://uptime.phonepe.com"

internal let PhonePeV2APIBase = "https://api.phonepe.com/apis/pg"
internal let PhonePeV2APISandbox = "https://api-preprod.phonepe.com/apis/pg-sandbox"
internal let PhonePeV2TokenProd = "https://api.phonepe.com/apis/identity-manager/v1/oauth/token"
internal let PhonePeV2TokenSandbox = "https://api-preprod.phonepe.com/apis/pg-sandbox/v1/oauth/token"

// MARK: - Environment

/// The target deployment environment for all ``PhonePeClient`` operations.
///
/// Pass the appropriate environment to ``PhonePeClient/init(httpClient:credential:environment:)``
/// to direct API calls to either the live production gateway or the sandbox:
///
/// ```swift
/// // Sandbox (UAT) — safe for testing; no real money moves.
/// let client = PhonePeClient(httpClient: ..., credential: ..., environment: .sandbox)
///
/// // Production — live transactions.
/// let client = PhonePeClient(httpClient: ..., credential: ..., environment: .production)
/// ```
///
/// - Note: The `.health` case is retained for legacy compatibility but maps to the
///   sandbox v2 base URL. Prefer `.sandbox` or `.production` for all new code.
public enum Environment {
    /// PhonePe production gateway. Real transactions and real money.
    case production

    /// PhonePe UAT sandbox. Safe for development and testing.
    case sandbox

    /// Legacy health-check environment alias. Prefer `.sandbox`.
    case health

    // MARK: - V1

    /// V1 (HMAC) base URL for the environment.
    ///
    /// - Production: `https://api.phonepe.com/apis/hermes`
    /// - Sandbox/Health: `https://api-preprod.phonepe.com/apis/pg-sandbox`
    var baseUrl: String {
        switch self {
        case .production: return PhonePeAPIBase
        case .sandbox: return PhonePeAPISandbox
        case .health: return PhonePeHealthStatusBase
        }
    }

    // MARK: - V2

    /// V2 (OAuth2) base URL for the environment.
    ///
    /// - Production: `https://api.phonepe.com/apis/pg`
    /// - Sandbox/Health: `https://api-preprod.phonepe.com/apis/pg-sandbox`
    var v2BaseUrl: String {
        switch self {
        case .production: return PhonePeV2APIBase
        case .sandbox, .health: return PhonePeV2APISandbox
        }
    }

    /// OAuth2 token endpoint URL used by ``PhonePeV2APIHandler`` to obtain Bearer tokens.
    ///
    /// - Production: `https://api.phonepe.com/apis/identity-manager/v1/oauth/token`
    /// - Sandbox/Health: `https://api-preprod.phonepe.com/apis/pg-sandbox/v1/oauth/token`
    var v2TokenUrl: String {
        switch self {
        case .production: return PhonePeV2TokenProd
        case .sandbox, .health: return PhonePeV2TokenSandbox
        }
    }

    // MARK: - Health

    /// Base URL for the PhonePe merchant health endpoint (`https://uptime.phonepe.com`).
    /// Shared across all environments.
    var healthbaseUrl: String {
        return PhonePeHealthStatusBase
    }
}

// MARK: - HTTPClientRequest.Body helpers

extension HTTPClientRequest.Body {
    /// Creates an HTTP request body from a UTF-8 string.
    ///
    /// - Parameter string: The string to encode as the request body.
    /// - Returns: An `HTTPClientRequest.Body` backed by the string's UTF-8 bytes.
    public static func string(_ string: String) -> Self {
        .bytes(.init(string: string))
    }

    /// Creates an HTTP request body from raw `Data`.
    ///
    /// - Parameter data: The data to use as the request body.
    /// - Returns: An `HTTPClientRequest.Body` backed by the provided data.
    public static func data(_ data: Data) -> Self {
        .bytes(.init(data: data))
    }
}

// MARK: - PhonePeAPIHandler (V1)

/// Internal request handler for PhonePe v1 API calls using HMAC X-VERIFY authentication.
///
/// Every outbound request is signed with an HMAC-SHA256 hash derived from the
/// Base64-encoded request body, the endpoint path, and the merchant's salt key.
/// The resulting signature is sent in the `X-VERIFY` header.
///
/// This type is an implementation detail — consumers interact with it indirectly
/// through the route structs wired by ``PhonePeClient``.
struct PhonePeAPIHandler {
    private let httpClient: HTTPClient
    private let saltKey: String
    private let saltIndex: String
    private let environment: Environment
    private let decoder: JSONDecoder

    /// Creates a new v1 API handler.
    ///
    /// - Parameters:
    ///   - httpClient: Shared `AsyncHTTPClient` instance.
    ///   - saltKey: Merchant salt key for HMAC signature generation.
    ///   - saltIndex: Salt index identifying which key to use (typically `"1"`).
    ///   - environment: Target environment.
    init(httpClient: HTTPClient, saltKey: String, saltIndex: String, environment: Environment) {
        self.httpClient = httpClient
        self.saltKey = saltKey
        self.saltIndex = saltIndex
        self.environment = environment
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .secondsSince1970
    }

    /// Sends a signed v1 API request and returns a decoded `Codable` response.
    ///
    /// The method:
    /// 1. Computes an HMAC-SHA256 `X-VERIFY` signature for the request.
    /// 2. Builds the full URL from `environment.baseUrl + path`.
    /// 3. Attaches `Content-Type`, `Accept`, and `X-VERIFY` headers.
    /// 4. Executes the HTTP request and decodes the response body into `T`.
    ///
    /// - Parameters:
    ///   - method: HTTP method (`.GET`, `.POST`, etc.).
    ///   - path: Path appended to the resolved base URL.
    ///   - query: Optional URL query string (without leading `?`).
    ///   - body: Optional request body; must be Base64-wrapped JSON (see ``Request/constructRequestBody(request:)``).
    ///   - headers: Additional headers merged over the defaults.
    ///   - baseUrl: Overrides `environment.baseUrl` when provided (e.g. for the health endpoint).
    /// - Returns: The decoded response of type `T`.
    /// - Throws: ``PhonePeError`` on signature failure, empty response body, or decoding errors.
    func send<T: Codable>(method: HTTPMethod,
                          path: String,
                          query: String = "",
                          body: HTTPClientRequest.Body? = nil,
                          headers: HTTPHeaders,
                          baseUrl: String? = nil) async throws -> T {
        var _headers: HTTPHeaders = ["Content-Type": "application/json",
                                     "Accept": "application/json"]
        headers.forEach { _headers.replaceOrAdd(name: $0.name, value: $0.value) }

        let signature = try await Request.generateSignature(path: path, body: body, saltKey: saltKey, saltIndex: saltIndex)
        _headers.add(name: "X-VERIFY", value: signature)

        let resolvedBaseUrl = baseUrl ?? environment.baseUrl
        var request = HTTPClientRequest(url: "\(resolvedBaseUrl)\(path)?\(query)")
        request.headers = _headers
        request.method = method
        request.body = body

        let response = try await httpClient.execute(request, timeout: .seconds(60))
        let responseData = try await response.body.collect(upTo: 1024 * 1024 * 100) // 100 MB limit

        guard responseData.readableBytes > 0 else {
            throw PhonePeError(
                success: false,
                code: .EMPTY_RESPONSE,
                message: "Server returned empty response body (HTTP \(response.status.code))"
            )
        }

        let data = Data(buffer: responseData)

        // For non-2xx responses, surface a structured PhonePeError instead of a raw DecodingError.
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
}
