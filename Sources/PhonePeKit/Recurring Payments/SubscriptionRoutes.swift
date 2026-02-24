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

public protocol SubscriptionRoutes: PhonePeAPIRoute {
    func create(request: SubscriptionRequest) async throws -> PhonePeResponse<SubscriptionResponse>
    func cancel(request: SubscriptionActionRequest) async throws -> PhonePeResponse<SubscriptionActionResponse>
    func pause(request: SubscriptionActionRequest) async throws -> PhonePeResponse<SubscriptionActionResponse>
    func unpause(request: SubscriptionActionRequest) async throws -> PhonePeResponse<SubscriptionActionResponse>
    func revoke(request: SubscriptionActionRequest) async throws -> PhonePeResponse<SubscriptionActionResponse>
}

public struct PhonePeSubscriptionRoutes: SubscriptionRoutes {
    public var headers: HTTPHeaders = [:]

    public let user: UserRoutes
    public let fetch: FetchRoutes
    public let auth: AuthRoutes
    public let debit: DebitRoutes
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

    public func create(request: SubscriptionRequest) async throws -> PhonePeResponse<SubscriptionResponse> {
        let path = "/v3/recurring/subscription/create"
        let requestBody = try Request.constructRequestBody(request: request)
        return try await apiHandler.send(
            method: .POST,
            path: path,
            body: .data(requestBody),
            headers: headers
        )
    }

    public func cancel(request: SubscriptionActionRequest) async throws -> PhonePeResponse<SubscriptionActionResponse> {
        let path = "/v3/recurring/subscription/cancel"
        let requestBody = try Request.constructRequestBody(request: request)
        return try await apiHandler.send(
            method: .POST,
            path: path,
            body: .data(requestBody),
            headers: headers
        )
    }

    public func pause(request: SubscriptionActionRequest) async throws -> PhonePeResponse<SubscriptionActionResponse> {
        let path = "/v3/recurring/subscription/pause"
        let requestBody = try Request.constructRequestBody(request: request)
        return try await apiHandler.send(
            method: .POST,
            path: path,
            body: .data(requestBody),
            headers: headers
        )
    }

    public func unpause(request: SubscriptionActionRequest) async throws -> PhonePeResponse<SubscriptionActionResponse> {
        let path = "/v3/recurring/subscription/unpause"
        let requestBody = try Request.constructRequestBody(request: request)
        return try await apiHandler.send(
            method: .POST,
            path: path,
            body: .data(requestBody),
            headers: headers
        )
    }

    public func revoke(request: SubscriptionActionRequest) async throws -> PhonePeResponse<SubscriptionActionResponse> {
        let path = "/v3/recurring/subscription/revoke"
        let requestBody = try Request.constructRequestBody(request: request)
        return try await apiHandler.send(
            method: .POST,
            path: path,
            body: .data(requestBody),
            headers: headers
        )
    }

    // MARK: - User Routes

    public struct UserRoutes {
        private let apiHandler: PhonePeAPIHandler
        private let baseUrl: String

        init(apiHandler: PhonePeAPIHandler, baseUrl: String) {
            self.apiHandler = apiHandler
            self.baseUrl = baseUrl
        }

        public func status(merchantId: String, merchantSubscriptionId: String) async throws -> PhonePeResponse<UserSubscriptionStatusResponse> {
            let path = "/v3/recurring/subscription/status/\(merchantId)/\(merchantSubscriptionId)"
            var requestHeaders: HTTPHeaders = [:]
            requestHeaders.add(name: "X-MERCHANT-ID", value: merchantId)
            requestHeaders.add(name: "merchantId", value: merchantId)
            requestHeaders.add(name: "merchantSubscriptionId", value: merchantSubscriptionId)
            return try await apiHandler.send(
                method: .GET,
                path: path,
                headers: requestHeaders
            )
        }
    }

    // MARK: - Fetch Routes

    public struct FetchRoutes {
        private let apiHandler: PhonePeAPIHandler
        private let baseUrl: String

        init(apiHandler: PhonePeAPIHandler, baseUrl: String) {
            self.apiHandler = apiHandler
            self.baseUrl = baseUrl
        }

        public func all(merchantId: String, merchantUserId: String) async throws -> PhonePeResponse<AllSubscriptionsResponse> {
            let path = "/v3/recurring/subscription/user/\(merchantId)/\(merchantUserId)/all"
            var requestHeaders: HTTPHeaders = [:]
            requestHeaders.add(name: "X-MERCHANT-ID", value: merchantId)
            requestHeaders.add(name: "merchantId", value: merchantId)
            requestHeaders.add(name: "merchantUserId", value: merchantUserId)
            return try await apiHandler.send(
                method: .GET,
                path: path,
                headers: requestHeaders
            )
        }
    }

    // MARK: - Auth Routes

    public struct AuthRoutes {
        private let apiHandler: PhonePeAPIHandler
        private let baseUrl: String

        init(apiHandler: PhonePeAPIHandler, baseUrl: String) {
            self.apiHandler = apiHandler
            self.baseUrl = baseUrl
        }

        public func status(merchantId: String, authRequestId: String) async throws -> PhonePeResponse<AuthRequestStatusResponse> {
            let path = "/v3/recurring/auth/status/\(merchantId)/\(authRequestId)"
            var requestHeaders: HTTPHeaders = [:]
            requestHeaders.add(name: "X-MERCHANT-ID", value: merchantId)
            requestHeaders.add(name: "merchantId", value: merchantId)
            requestHeaders.add(name: "authRequestId", value: authRequestId)
            return try await apiHandler.send(
                method: .GET,
                path: path,
                headers: requestHeaders
            )
        }

        public func initiate(request: AuthInitRequest) async throws -> PhonePeResponse<AuthInitResponse> {
            let path = "/v3/recurring/auth/init"
            let requestBody = try Request.constructRequestBody(request: request)
            return try await apiHandler.send(
                method: .POST,
                path: path,
                body: .data(requestBody),
                headers: [:]
            )
        }
    }

    // MARK: - VPA Routes

    public struct VPARoutes {
        private let apiHandler: PhonePeAPIHandler
        private let baseUrl: String

        init(apiHandler: PhonePeAPIHandler, baseUrl: String) {
            self.apiHandler = apiHandler
            self.baseUrl = baseUrl
        }

        public func verify(merchantId: String, vpa: String) async throws -> PhonePeResponse<VPAValidateResponse> {
            let path = "/v3/vpa/\(merchantId)/\(vpa)/validate"
            var requestHeaders: HTTPHeaders = [:]
            requestHeaders.add(name: "X-MERCHANT-ID", value: merchantId)
            requestHeaders.add(name: "merchantId", value: merchantId)
            requestHeaders.add(name: "vpa", value: vpa)
            return try await apiHandler.send(
                method: .GET,
                path: path,
                headers: requestHeaders
            )
        }
    }

    // MARK: - Debit Routes

    public struct DebitRoutes {
        private let apiHandler: PhonePeAPIHandler
        private let baseUrl: String

        init(apiHandler: PhonePeAPIHandler, baseUrl: String) {
            self.apiHandler = apiHandler
            self.baseUrl = baseUrl
        }

        /// Notifies the bank 24–48 hours before a debit. Call this before `execute`.
        /// If `autoDebit` is `true` in the request, PhonePe will auto-execute after the window.
        public func initiate(request: DebitInitRequest) async throws -> PhonePeResponse<DebitInitResponse> {
            let path = "/v3/recurring/debit/init"
            let requestBody = try Request.constructRequestBody(request: request)
            return try await apiHandler.send(
                method: .POST,
                path: path,
                body: .data(requestBody),
                headers: [:]
            )
        }

        public func execute(request: DebitExecuteRequest) async throws -> PhonePeResponse<DebitExecuteResponse> {
            let path = "/v3/recurring/debit/execute"
            let requestBody = try Request.constructRequestBody(request: request)
            return try await apiHandler.send(
                method: .POST,
                path: path,
                body: .data(requestBody),
                headers: [:]
            )
        }
    }
}


enum SubscriptionError: Error {
    case jsonEncodingFailed
    case dictionaryConversionFailed
    case bodyExtractionFailed
    case jsonDecodingFailed
}
