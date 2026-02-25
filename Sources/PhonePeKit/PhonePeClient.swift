//
//  PhonePeClient.swift
//
//
//  Created by Vamsi Madduluri on 29/12/23.
//

import NIO
import AsyncHTTPClient

/// The main entry point for interacting with the PhonePe Payment Gateway API.
///
/// `PhonePeClient` exposes grouped route namespaces for every PhonePe product area.
/// Depending on the ``PhonePeCredential`` supplied at initialisation, the client
/// transparently uses either the v1 HMAC scheme or the v2 OAuth2 Bearer scheme.
///
/// ## Creating a V2 Client
///
/// ```swift
/// let httpClient = HTTPClient(eventLoopGroupProvider: .singleton)
/// let client = PhonePeClient(
///     httpClient: httpClient,
///     credential: .v2(clientId: "YOUR_CLIENT_ID", clientSecret: "YOUR_CLIENT_SECRET"),
///     environment: .sandbox
/// )
///
/// // Initiate a payment
/// let response = try await client.payments.initiate(request: V2PayRequest(
///     merchantOrderId: "ORDER_001",
///     amount: 10000,
///     paymentFlow: .init(redirectUrl: "https://example.com/return")
/// ))
/// ```
///
/// ## Creating a V1 Client (Legacy)
///
/// ```swift
/// let client = PhonePeClient(
///     httpClient: httpClient,
///     credential: .v1(saltKey: "YOUR_SALT_KEY", saltIndex: "1"),
///     environment: .sandbox
/// )
/// ```
///
/// - Important: Always shut down `HTTPClient` when your application exits by calling
///   `try await httpClient.shutdown()`.
public final class PhonePeClient {

    /// Routes for initiating payments and refunds.
    public var payments: any PayRoutes

    /// Routes for querying transaction and order status.
    public var status: any StatusRoutes

    /// Routes for creating and managing recurring subscriptions.
    public var subscriptions: any SubscriptionRoutes

    /// Routes for validating VPA addresses (v1 only).
    public var validate: any ValidateRoutes

    /// Routes for fetching available payment options (v1 only).
    public var options: any OptionsRoutes

    // MARK: - Primary init

    /// Creates a `PhonePeClient` with the given credential and environment.
    ///
    /// Use this initialiser for all new integrations. Pass ``PhonePeCredential/v2(clientId:clientSecret:clientVersion:)``
    /// for PhonePe v2 or ``PhonePeCredential/v1(saltKey:saltIndex:)`` for the legacy v1 API.
    ///
    /// - Parameters:
    ///   - httpClient: A shared `AsyncHTTPClient.HTTPClient` instance. The caller is
    ///     responsible for shutting it down.
    ///   - credential: The authentication credential (`.v1` or `.v2`).
    ///   - environment: The target environment (`.production` or `.sandbox`).
    public init(httpClient: HTTPClient, credential: PhonePeCredential, environment: Environment) {
        switch credential {
        case .v1(let saltKey, let saltIndex):
            let handler = PhonePeAPIHandler(httpClient: httpClient, saltKey: saltKey, saltIndex: saltIndex, environment: environment)
            payments = PhonePePayRoutes(apiHandler: handler, baseUrl: environment.baseUrl)
            status = PhonePeStatusRoutes(apiHandler: handler, baseUrl: environment.baseUrl, healthBaseUrl: environment.healthbaseUrl)
            subscriptions = PhonePeSubscriptionRoutes(apiHandler: handler, baseUrl: environment.baseUrl)
            validate = PhonePeValidateRoutes(apiHandler: handler, baseUrl: environment.baseUrl)
            options = PhonePeOptionsRoutes(apiHandler: handler, baseUrl: environment.baseUrl)

        case .v2(let clientId, let clientSecret, let clientVersion):
            let handler = PhonePeV2APIHandler(
                httpClient: httpClient,
                clientId: clientId,
                clientSecret: clientSecret,
                clientVersion: clientVersion,
                environment: environment
            )
            payments = PhonePePayRoutesV2(apiHandler: handler, baseUrl: environment.v2BaseUrl)
            status = PhonePeStatusRoutesV2(apiHandler: handler, baseUrl: environment.v2BaseUrl, healthBaseUrl: environment.healthbaseUrl)
            subscriptions = PhonePeSubscriptionRoutesV2(apiHandler: handler, baseUrl: environment.v2BaseUrl)
            validate = PhonePeValidateRoutesV2()
            options = PhonePeOptionsRoutesV2()
        }
    }

    // MARK: - Deprecated v1 init

    /// Creates a `PhonePeClient` using v1 HMAC salt credentials.
    ///
    /// - Parameters:
    ///   - httpClient: The HTTP client to use for making API requests.
    ///   - saltKey: The salt key for API authentication.
    ///   - saltIndex: The salt index for API authentication.
    ///   - environment: The environment configuration for the API.
    ///
    /// - Important: This initialiser is deprecated. Migrate to
    ///   ``init(httpClient:credential:environment:)`` with
    ///   ``PhonePeCredential/v1(saltKey:saltIndex:)``.
    @available(*, deprecated, renamed: "init(httpClient:credential:environment:)",
               message: "Use init(httpClient:credential:environment:) with PhonePeCredential.v1(saltKey:saltIndex:) instead.")
    public init(httpClient: HTTPClient, saltKey: String, saltIndex: String, environment: Environment) {
        let handler = PhonePeAPIHandler(httpClient: httpClient, saltKey: saltKey, saltIndex: saltIndex, environment: environment)
        payments = PhonePePayRoutes(apiHandler: handler, baseUrl: environment.baseUrl)
        status = PhonePeStatusRoutes(apiHandler: handler, baseUrl: environment.baseUrl, healthBaseUrl: environment.healthbaseUrl)
        subscriptions = PhonePeSubscriptionRoutes(apiHandler: handler, baseUrl: environment.baseUrl)
        validate = PhonePeValidateRoutes(apiHandler: handler, baseUrl: environment.baseUrl)
        options = PhonePeOptionsRoutes(apiHandler: handler, baseUrl: environment.baseUrl)
    }
}
