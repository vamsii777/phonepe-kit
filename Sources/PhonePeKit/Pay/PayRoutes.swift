//
//  PayRoutes.swift
//
//
//  Created by Vamsi Madduluri on 30/12/23.
//

import Foundation
import NIO
import NIOHTTP1
import AsyncHTTPClient

/// Protocol defining standard payment initiation routes.
///
/// Both v1 and v2 concrete implementations conform to this protocol.
/// Method overloads allow the compiler to select the correct implementation
/// based on the request type passed:
///
/// - ``initiate(request:)-v1`` — v1 HMAC-authenticated `PayRequest`
/// - ``initiate(request:)-v2`` — v2 OAuth2-authenticated `V2PayRequest`
///
/// Calling the wrong overload for your credential version will throw a
/// ``PhonePeError`` with a descriptive message rather than a compile error.
///
/// ## Usage
///
/// ```swift
/// // V2
/// let response = try await client.payments.initiate(request: V2PayRequest(...))
///
/// // V1
/// let response = try await client.payments.initiate(request: PayRequest(...))
/// ```
public protocol PayRoutes: PhonePeAPIRoute {
    /// Initiates a v1 payment. Implemented by ``PhonePePayRoutes``.
    func initiate(request: PayRequest) async throws -> PhonePeResponse<PayResponse>

    /// Initiates a v2 payment. Implemented by ``PhonePePayRoutesV2``.
    func initiate(request: V2PayRequest) async throws -> V2PayResponse
}

extension PayRoutes {
    /// Default implementation — throws a descriptive error for v2 clients calling the v1 overload.
    public func initiate(request: PayRequest) async throws -> PhonePeResponse<PayResponse> {
        throw PhonePeError(
            success: false,
            code: .BAD_REQUEST,
            message: "initiate(request: PayRequest) is not supported in v2 mode. Use initiate(request: V2PayRequest) instead."
        )
    }

    /// Default implementation — throws a descriptive error for v1 clients calling the v2 overload.
    public func initiate(request: V2PayRequest) async throws -> V2PayResponse {
        throw PhonePeError(
            success: false,
            code: .BAD_REQUEST,
            message: "initiate(request: V2PayRequest) is not supported in v1 mode. Use initiate(request: PayRequest) instead."
        )
    }
}

// MARK: - V1 Pay Routes

/// V1 implementation of payment routes using HMAC X-VERIFY authentication.
///
/// `PhonePePayRoutes` is wired by ``PhonePeClient`` when you supply a
/// ``PhonePeCredential/v1(saltKey:saltIndex:)`` credential.
///
/// Access via ``PhonePeClient/payments``:
///
/// ```swift
/// let response = try await client.payments.initiate(request: PayRequest(...))
/// let refundResp = try await client.payments.refund.initiate(request: RefundRequest(...))
/// ```
public struct PhonePePayRoutes: PayRoutes {

    /// Additional HTTP headers merged into every outbound request.
    public var headers: HTTPHeaders = [:]

    /// V1 refund sub-routes.
    public let refund: RefundRoutes

    private let apiHandler: PhonePeAPIHandler
    private let baseUrl: String

    init(apiHandler: PhonePeAPIHandler, baseUrl: String) {
        self.apiHandler = apiHandler
        self.baseUrl = baseUrl
        self.refund = RefundRoutes(apiHandler: apiHandler, baseUrl: baseUrl)
    }

    /// Initiates a v1 payment via `POST /pg/v1/pay`.
    ///
    /// The request is Base64-encoded and HMAC-signed before sending.
    ///
    /// - Parameter request: The v1 payment request body.
    /// - Returns: A ``PhonePeResponse`` wrapping a ``PayResponse``.
    /// - Throws: ``PhonePeError`` on authentication failure or API error.
    public func initiate(request: PayRequest) async throws -> PhonePeResponse<PayResponse> {
        let path = "/pg/v1/pay"
        let requestBody = try Request.constructRequestBody(request: request)
        return try await apiHandler.send(
            method: .POST,
            path: path,
            body: .data(requestBody),
            headers: headers
        )
    }

    // MARK: - V1 Refund Routes

    /// Sub-routes for v1 refund operations.
    ///
    /// Access via ``PhonePePayRoutes/refund``:
    ///
    /// ```swift
    /// let refundResp = try await client.payments.refund.initiate(request: RefundRequest(...))
    /// ```
    public struct RefundRoutes {
        private let apiHandler: PhonePeAPIHandler
        private let baseUrl: String

        init(apiHandler: PhonePeAPIHandler, baseUrl: String) {
            self.apiHandler = apiHandler
            self.baseUrl = baseUrl
        }

        /// Initiates a v1 refund via `POST /pg/v1/refund`.
        ///
        /// - Parameter request: The v1 refund request body.
        /// - Returns: A ``PhonePeResponse`` wrapping a ``RefundResponse``.
        /// - Throws: ``PhonePeError`` on validation or API errors.
        public func initiate(request: RefundRequest) async throws -> PhonePeResponse<RefundResponse> {
            let path = "/pg/v1/refund"
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
