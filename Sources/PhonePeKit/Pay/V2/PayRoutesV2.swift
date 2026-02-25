//
//  PayRoutesV2.swift
//
//
//  Created for PhonePe v2 API support.
//

import Foundation
import NIO
import NIOHTTP1
import AsyncHTTPClient

/// V2 implementation of payment initiation and refund routes.
///
/// `PhonePePayRoutesV2` conforms to ``PayRoutes`` and is automatically wired by
/// ``PhonePeClient`` when you initialise with ``PhonePeCredential/v2(clientId:clientSecret:clientVersion:)``.
///
/// All requests are authenticated via `O-Bearer` tokens managed by ``PhonePeV2APIHandler``
/// and sent as direct JSON bodies (no Base64 wrapping).
///
/// ## Payment Flow
///
/// 1. Call ``initiate(request:)-v2`` → receive a `redirectUrl`.
/// 2. Redirect your user to that URL to complete payment on PhonePe's hosted page.
/// 3. After the user returns, call ``PhonePeStatusRoutesV2/transaction(merchantOrderId:)``
///    to confirm the outcome.
///
/// ## Refund Flow
///
/// 1. Call ``refund```.``RefundRoutesV2/initiate(request:)`` with a ``V2RefundRequest``.
/// 2. Poll ``refund```.``RefundRoutesV2/status(merchantRefundId:)`` for the final state.
public struct PhonePePayRoutesV2: PayRoutes {

    /// Additional HTTP headers merged into every request sent by this route group.
    public var headers: HTTPHeaders = [:]

    /// Refund sub-routes for initiating and querying v2 refunds.
    public let refund: RefundRoutesV2

    private let apiHandler: PhonePeV2APIHandler
    private let baseUrl: String

    init(apiHandler: PhonePeV2APIHandler, baseUrl: String) {
        self.apiHandler = apiHandler
        self.baseUrl = baseUrl
        self.refund = RefundRoutesV2(apiHandler: apiHandler, baseUrl: baseUrl)
    }

    // MARK: - Payment initiation

    /// Initiates a v2 standard checkout payment.
    ///
    /// Sends `POST /checkout/v2/pay` with the supplied ``V2PayRequest`` as a JSON body.
    /// On success, the response contains a ``V2PayResponse/redirectUrl`` to which you
    /// should redirect the user.
    ///
    /// - Parameter request: The payment details including amount, order ID, and redirect URL.
    /// - Returns: A ``V2PayResponse`` containing the PhonePe order ID and redirect URL.
    /// - Throws: ``PhonePeError`` on authentication failure, validation errors, or network issues.
    public func initiate(request: V2PayRequest) async throws -> V2PayResponse {
        let path = "/checkout/v2/pay"
        let requestBody = try JSONEncoder().encode(request)
        return try await apiHandler.send(
            method: .POST,
            path: path,
            body: .data(requestBody),
            headers: headers
        )
    }

    // MARK: - V2 Refund Routes

    /// Sub-routes for creating and querying v2 refunds.
    ///
    /// Access via ``PhonePePayRoutesV2/refund``:
    ///
    /// ```swift
    /// let refund = try await client.payments.refund.initiate(request: ...)
    /// let status = try await client.payments.refund.status(merchantRefundId: "REFUND_001")
    /// ```
    public struct RefundRoutesV2 {
        private let apiHandler: PhonePeV2APIHandler
        private let baseUrl: String

        init(apiHandler: PhonePeV2APIHandler, baseUrl: String) {
            self.apiHandler = apiHandler
            self.baseUrl = baseUrl
        }

        /// Initiates a v2 refund for a completed payment.
        ///
        /// Sends `POST /payments/v2/refund`. Both full and partial refunds are supported.
        ///
        /// - Parameter request: Refund details including the original order ID and amount.
        /// - Returns: A ``V2RefundResponse`` with the refund ID and initial state.
        /// - Throws: ``PhonePeError`` if the original order does not exist or the refund exceeds the original amount.
        public func initiate(request: V2RefundRequest) async throws -> V2RefundResponse {
            let path = "/payments/v2/refund"
            let requestBody = try JSONEncoder().encode(request)
            return try await apiHandler.send(
                method: .POST,
                path: path,
                body: .data(requestBody),
                headers: [:]
            )
        }

        /// Queries the current status of a v2 refund.
        ///
        /// Sends `GET /payments/v2/refund/{merchantRefundId}/status`.
        ///
        /// - Parameter merchantRefundId: The merchant-assigned refund identifier originally
        ///   passed to ``initiate(request:)``.
        /// - Returns: A ``V2RefundStatusResponse`` with the current refund state.
        /// - Throws: ``PhonePeError`` if the refund ID is not found.
        public func status(merchantRefundId: String) async throws -> V2RefundStatusResponse {
            let path = "/payments/v2/refund/\(merchantRefundId)/status"
            return try await apiHandler.send(
                method: .GET,
                path: path,
                headers: [:]
            )
        }
    }
}
