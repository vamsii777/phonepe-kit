//
//  SubscriptionRoutes.swift
//
//
//  Created by Vamsi Madduluri on 29/12/23.
//
import NIO
import NIOHTTP1
import Foundation
import AsyncHTTPClient

/// Protocol defining recurring subscription (Autopay) management routes.
///
/// Both v1 (`PhonePeSubscriptionRoutes`) and v2 (`PhonePeSubscriptionRoutesV2`)
/// implementations conform to this protocol.
///
/// ### V1 / V2 Method Routing
///
/// Each lifecycle method has two overloads — one that accepts a structured request
/// body (v1), and one that accepts a `merchantSubscriptionId` string directly (v2).
/// Default protocol extension implementations throw a descriptive ``PhonePeError``
/// for the unsupported version, so calling the wrong overload surfaces a clear runtime
/// error rather than a silent failure.
///
/// | Method | V1 signature | V2 signature |
/// |---|---|---|
/// | Create | `create(request: SubscriptionRequest)` | `create(request: V2SubscriptionSetupRequest)` |
/// | Cancel | `cancel(request: SubscriptionActionRequest)` | `cancel(merchantSubscriptionId:)` |
/// | Pause | `pause(request: SubscriptionActionRequest)` | `pause(merchantSubscriptionId:)` |
/// | Unpause | `unpause(request: SubscriptionActionRequest)` | `unpause(merchantSubscriptionId:)` |
/// | Revoke | `revoke(request: SubscriptionActionRequest)` | `revoke(merchantSubscriptionId:)` |
public protocol SubscriptionRoutes: PhonePeAPIRoute {
    // MARK: V1

    /// Creates a v1 subscription mandate.
    func create(request: SubscriptionRequest) async throws -> PhonePeResponse<SubscriptionResponse>
    /// Cancels a v1 subscription.
    func cancel(request: SubscriptionActionRequest) async throws -> PhonePeResponse<SubscriptionActionResponse>
    /// Pauses a v1 subscription.
    func pause(request: SubscriptionActionRequest) async throws -> PhonePeResponse<SubscriptionActionResponse>
    /// Unpauses a v1 subscription.
    func unpause(request: SubscriptionActionRequest) async throws -> PhonePeResponse<SubscriptionActionResponse>
    /// Revokes a v1 subscription.
    func revoke(request: SubscriptionActionRequest) async throws -> PhonePeResponse<SubscriptionActionResponse>

    // MARK: V2

    /// Sets up a v2 subscription mandate.
    func create(request: V2SubscriptionSetupRequest) async throws -> V2SubscriptionSetupResponse
    /// Cancels a v2 subscription by merchant subscription ID.
    func cancel(merchantSubscriptionId: String) async throws
    /// Pauses a v2 subscription by merchant subscription ID.
    func pause(merchantSubscriptionId: String) async throws
    /// Unpauses a v2 subscription by merchant subscription ID.
    func unpause(merchantSubscriptionId: String) async throws
    /// Revokes a v2 subscription by merchant subscription ID.
    func revoke(merchantSubscriptionId: String) async throws
}

extension SubscriptionRoutes {
    public func create(request: SubscriptionRequest) async throws -> PhonePeResponse<SubscriptionResponse> {
        throw PhonePeError(success: false, code: .BAD_REQUEST,
            message: "create(request: SubscriptionRequest) is not supported in v2 mode. Use create(request: V2SubscriptionSetupRequest) instead.")
    }
    public func cancel(request: SubscriptionActionRequest) async throws -> PhonePeResponse<SubscriptionActionResponse> {
        throw PhonePeError(success: false, code: .BAD_REQUEST,
            message: "cancel(request:) is not supported in v2 mode. Use cancel(merchantSubscriptionId:) instead.")
    }
    public func pause(request: SubscriptionActionRequest) async throws -> PhonePeResponse<SubscriptionActionResponse> {
        throw PhonePeError(success: false, code: .BAD_REQUEST,
            message: "pause(request:) is not supported in v2 mode. Use pause(merchantSubscriptionId:) instead.")
    }
    public func unpause(request: SubscriptionActionRequest) async throws -> PhonePeResponse<SubscriptionActionResponse> {
        throw PhonePeError(success: false, code: .BAD_REQUEST,
            message: "unpause(request:) is not supported in v2 mode. Use unpause(merchantSubscriptionId:) instead.")
    }
    public func revoke(request: SubscriptionActionRequest) async throws -> PhonePeResponse<SubscriptionActionResponse> {
        throw PhonePeError(success: false, code: .BAD_REQUEST,
            message: "revoke(request:) is not supported in v2 mode. Use revoke(merchantSubscriptionId:) instead.")
    }
    public func create(request: V2SubscriptionSetupRequest) async throws -> V2SubscriptionSetupResponse {
        throw PhonePeError(success: false, code: .BAD_REQUEST,
            message: "create(request: V2SubscriptionSetupRequest) is not supported in v1 mode. Use create(request: SubscriptionRequest) instead.")
    }
    public func cancel(merchantSubscriptionId: String) async throws {
        throw PhonePeError(success: false, code: .BAD_REQUEST,
            message: "cancel(merchantSubscriptionId:) is not supported in v1 mode. Use cancel(request: SubscriptionActionRequest) instead.")
    }
    public func pause(merchantSubscriptionId: String) async throws {
        throw PhonePeError(success: false, code: .BAD_REQUEST,
            message: "pause(merchantSubscriptionId:) is not supported in v1 mode. Use pause(request: SubscriptionActionRequest) instead.")
    }
    public func unpause(merchantSubscriptionId: String) async throws {
        throw PhonePeError(success: false, code: .BAD_REQUEST,
            message: "unpause(merchantSubscriptionId:) is not supported in v1 mode. Use unpause(request: SubscriptionActionRequest) instead.")
    }
    public func revoke(merchantSubscriptionId: String) async throws {
        throw PhonePeError(success: false, code: .BAD_REQUEST,
            message: "revoke(merchantSubscriptionId:) is not supported in v1 mode. Use revoke(request: SubscriptionActionRequest) instead.")
    }
}

// MARK: - V1 Subscription Routes

/// V1 implementation of subscription routes using HMAC X-VERIFY authentication.
///
/// `PhonePeSubscriptionRoutes` is wired by ``PhonePeClient`` when you supply a
/// ``PhonePeCredential/v1(saltKey:saltIndex:)`` credential.
///
/// Access via ``PhonePeClient/subscriptions``:
///
/// ```swift
/// // Create a subscription
/// let sub = try await client.subscriptions.create(request: SubscriptionRequest(...))
///
/// // Check subscription status
/// let status = try await client.subscriptions.user.status(
///     merchantId: "MERCHANT_ID",
///     merchantSubscriptionId: "SUB_001"
/// )
/// ```
public struct PhonePeSubscriptionRoutes: SubscriptionRoutes {

    /// Additional HTTP headers merged into every outbound request.
    public var headers: HTTPHeaders = [:]

    /// V1 sub-routes for querying subscription and user status.
    public let user: UserRoutes

    /// V1 sub-routes for fetching all subscriptions for a user.
    public let fetch: FetchRoutes

    /// V1 sub-routes for auth request management.
    public let auth: AuthRoutes

    /// V1 sub-routes for debit initiation and execution.
    public let debit: DebitRoutes

    /// V1 sub-routes for VPA verification in subscription context.
    public let vpa: VPARoutes

    private let apiHandler: PhonePeAPIHandler
    private let baseUrl: String

    init(apiHandler: PhonePeAPIHandler, baseUrl: String) {
        self.apiHandler = apiHandler
        self.baseUrl = baseUrl
        self.user = UserRoutes(apiHandler: apiHandler, baseUrl: baseUrl)
        self.fetch = FetchRoutes(apiHandler: apiHandler, baseUrl: baseUrl)
        self.auth = AuthRoutes(apiHandler: apiHandler, baseUrl: baseUrl)
        self.debit = DebitRoutes(apiHandler: apiHandler, baseUrl: baseUrl)
        self.vpa = VPARoutes(apiHandler: apiHandler, baseUrl: baseUrl)
    }

    /// Creates a v1 subscription via `POST /v3/recurring/subscription/create`.
    public func create(request: SubscriptionRequest) async throws -> PhonePeResponse<SubscriptionResponse> {
        let path = "/v3/recurring/subscription/create"
        let requestBody = try Request.constructRequestBody(request: request)
        return try await apiHandler.send(method: .POST, path: path, body: .data(requestBody), headers: headers)
    }

    /// Cancels a v1 subscription via `POST /v3/recurring/subscription/cancel`.
    public func cancel(request: SubscriptionActionRequest) async throws -> PhonePeResponse<SubscriptionActionResponse> {
        let path = "/v3/recurring/subscription/cancel"
        let requestBody = try Request.constructRequestBody(request: request)
        return try await apiHandler.send(method: .POST, path: path, body: .data(requestBody), headers: headers)
    }

    /// Pauses a v1 subscription via `POST /v3/recurring/subscription/pause`.
    public func pause(request: SubscriptionActionRequest) async throws -> PhonePeResponse<SubscriptionActionResponse> {
        let path = "/v3/recurring/subscription/pause"
        let requestBody = try Request.constructRequestBody(request: request)
        return try await apiHandler.send(method: .POST, path: path, body: .data(requestBody), headers: headers)
    }

    /// Unpauses a v1 subscription via `POST /v3/recurring/subscription/unpause`.
    public func unpause(request: SubscriptionActionRequest) async throws -> PhonePeResponse<SubscriptionActionResponse> {
        let path = "/v3/recurring/subscription/unpause"
        let requestBody = try Request.constructRequestBody(request: request)
        return try await apiHandler.send(method: .POST, path: path, body: .data(requestBody), headers: headers)
    }

    /// Revokes a v1 subscription via `POST /v3/recurring/subscription/revoke`.
    public func revoke(request: SubscriptionActionRequest) async throws -> PhonePeResponse<SubscriptionActionResponse> {
        let path = "/v3/recurring/subscription/revoke"
        let requestBody = try Request.constructRequestBody(request: request)
        return try await apiHandler.send(method: .POST, path: path, body: .data(requestBody), headers: headers)
    }

    // MARK: - User Routes

    /// V1 sub-routes for querying individual subscription status.
    public struct UserRoutes {
        private let apiHandler: PhonePeAPIHandler
        private let baseUrl: String

        init(apiHandler: PhonePeAPIHandler, baseUrl: String) {
            self.apiHandler = apiHandler
            self.baseUrl = baseUrl
        }

        /// Queries subscription status via `GET /v3/recurring/subscription/status/{merchantId}/{merchantSubscriptionId}`.
        ///
        /// - Parameters:
        ///   - merchantId: Your PhonePe merchant identifier.
        ///   - merchantSubscriptionId: The subscription identifier to query.
        /// - Returns: A ``PhonePeResponse`` wrapping a ``UserSubscriptionStatusResponse``.
        public func status(merchantId: String, merchantSubscriptionId: String) async throws -> PhonePeResponse<UserSubscriptionStatusResponse> {
            let path = "/v3/recurring/subscription/status/\(merchantId)/\(merchantSubscriptionId)"
            var requestHeaders: HTTPHeaders = [:]
            requestHeaders.add(name: "X-MERCHANT-ID", value: merchantId)
            requestHeaders.add(name: "merchantId", value: merchantId)
            requestHeaders.add(name: "merchantSubscriptionId", value: merchantSubscriptionId)
            return try await apiHandler.send(method: .GET, path: path, headers: requestHeaders)
        }
    }

    // MARK: - Fetch Routes

    /// V1 sub-routes for fetching all subscriptions belonging to a user.
    public struct FetchRoutes {
        private let apiHandler: PhonePeAPIHandler
        private let baseUrl: String

        init(apiHandler: PhonePeAPIHandler, baseUrl: String) {
            self.apiHandler = apiHandler
            self.baseUrl = baseUrl
        }

        /// Fetches all subscriptions for a user via
        /// `GET /v3/recurring/subscription/user/{merchantId}/{merchantUserId}/all`.
        ///
        /// - Parameters:
        ///   - merchantId: Your PhonePe merchant identifier.
        ///   - merchantUserId: The user whose subscriptions to retrieve.
        /// - Returns: A ``PhonePeResponse`` wrapping an ``AllSubscriptionsResponse``.
        public func all(merchantId: String, merchantUserId: String) async throws -> PhonePeResponse<AllSubscriptionsResponse> {
            let path = "/v3/recurring/subscription/user/\(merchantId)/\(merchantUserId)/all"
            var requestHeaders: HTTPHeaders = [:]
            requestHeaders.add(name: "X-MERCHANT-ID", value: merchantId)
            requestHeaders.add(name: "merchantId", value: merchantId)
            requestHeaders.add(name: "merchantUserId", value: merchantUserId)
            return try await apiHandler.send(method: .GET, path: path, headers: requestHeaders)
        }
    }

    // MARK: - Auth Routes

    /// V1 sub-routes for subscription auth request management.
    public struct AuthRoutes {
        private let apiHandler: PhonePeAPIHandler
        private let baseUrl: String

        init(apiHandler: PhonePeAPIHandler, baseUrl: String) {
            self.apiHandler = apiHandler
            self.baseUrl = baseUrl
        }

        /// Queries auth request status via
        /// `GET /v3/recurring/auth/status/{merchantId}/{authRequestId}`.
        public func status(merchantId: String, authRequestId: String) async throws -> PhonePeResponse<AuthRequestStatusResponse> {
            let path = "/v3/recurring/auth/status/\(merchantId)/\(authRequestId)"
            var requestHeaders: HTTPHeaders = [:]
            requestHeaders.add(name: "X-MERCHANT-ID", value: merchantId)
            requestHeaders.add(name: "merchantId", value: merchantId)
            requestHeaders.add(name: "authRequestId", value: authRequestId)
            return try await apiHandler.send(method: .GET, path: path, headers: requestHeaders)
        }

        /// Initiates an auth request via `POST /v3/recurring/auth/init`.
        public func initiate(request: AuthInitRequest) async throws -> PhonePeResponse<AuthInitResponse> {
            let path = "/v3/recurring/auth/init"
            let requestBody = try Request.constructRequestBody(request: request)
            return try await apiHandler.send(method: .POST, path: path, body: .data(requestBody), headers: [:])
        }
    }

    // MARK: - VPA Routes

    /// V1 sub-routes for VPA verification in the subscription context.
    public struct VPARoutes {
        private let apiHandler: PhonePeAPIHandler
        private let baseUrl: String

        init(apiHandler: PhonePeAPIHandler, baseUrl: String) {
            self.apiHandler = apiHandler
            self.baseUrl = baseUrl
        }

        /// Verifies a VPA via `GET /v3/vpa/{merchantId}/{vpa}/validate`.
        public func verify(merchantId: String, vpa: String) async throws -> PhonePeResponse<VPAValidateResponse> {
            let path = "/v3/vpa/\(merchantId)/\(vpa)/validate"
            var requestHeaders: HTTPHeaders = [:]
            requestHeaders.add(name: "X-MERCHANT-ID", value: merchantId)
            requestHeaders.add(name: "merchantId", value: merchantId)
            requestHeaders.add(name: "vpa", value: vpa)
            return try await apiHandler.send(method: .GET, path: path, headers: requestHeaders)
        }
    }

    // MARK: - Debit Routes

    /// V1 sub-routes for debit initiation and execution.
    public struct DebitRoutes {
        private let apiHandler: PhonePeAPIHandler
        private let baseUrl: String

        init(apiHandler: PhonePeAPIHandler, baseUrl: String) {
            self.apiHandler = apiHandler
            self.baseUrl = baseUrl
        }

        /// Notifies the bank 24–48 hours before a debit via `POST /v3/recurring/debit/init`.
        ///
        /// If `autoDebit` is `true` in the request body, PhonePe auto-executes the debit
        /// after the notification window elapses.
        public func initiate(request: DebitInitRequest) async throws -> PhonePeResponse<DebitInitResponse> {
            let path = "/v3/recurring/debit/init"
            let requestBody = try Request.constructRequestBody(request: request)
            return try await apiHandler.send(method: .POST, path: path, body: .data(requestBody), headers: [:])
        }

        /// Executes a debit via `POST /v3/recurring/debit/execute`.
        public func execute(request: DebitExecuteRequest) async throws -> PhonePeResponse<DebitExecuteResponse> {
            let path = "/v3/recurring/debit/execute"
            let requestBody = try Request.constructRequestBody(request: request)
            return try await apiHandler.send(method: .POST, path: path, body: .data(requestBody), headers: [:])
        }
    }
}


enum SubscriptionError: Error {
    case jsonEncodingFailed
    case dictionaryConversionFailed
    case bodyExtractionFailed
    case jsonDecodingFailed
}
