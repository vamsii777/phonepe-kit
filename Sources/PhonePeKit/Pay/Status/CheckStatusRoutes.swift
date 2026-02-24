//
//  CheckStatusRoutes.swift
//
//
//  Created by Vamsi Madduluri on 30/12/23.
//

import Foundation
import NIO
import NIOHTTP1
import AsyncHTTPClient

/// Protocol defining payment status query routes.
///
/// Both v1 and v2 implementations conform to this protocol. The version-specific
/// `transaction` overloads are differentiated by their parameter labels:
///
/// - ``transaction(merchantId:merchantTransactionId:)`` — v1 two-parameter form
/// - ``transaction(merchantOrderId:)`` — v2 single-parameter form
///
/// The ``health(merchantId:)`` method is shared and unchanged between v1 and v2.
///
/// ## Usage
///
/// ```swift
/// // V2 order status
/// let status = try await client.status.transaction(merchantOrderId: "ORDER_001")
///
/// // V1 transaction status
/// let status = try await client.status.transaction(
///     merchantId: "MERCHANT_ID",
///     merchantTransactionId: "TXN_001"
/// )
/// ```
public protocol StatusRoutes: PhonePeAPIRoute {
    /// Queries v1 transaction status by merchant ID and transaction ID.
    func transaction(merchantId: String, merchantTransactionId: String) async throws -> PhonePeResponse<CheckStatusResponse>

    /// Queries v2 order status by merchant order ID.
    func transaction(merchantOrderId: String) async throws -> V2OrderStatusResponse

    /// Queries PhonePe PG health for the given merchant (same for v1 and v2).
    func health(merchantId: String) async throws -> HealthStatusResponse
}

extension StatusRoutes {
    /// Default — throws for v2 clients that call the v1 status overload.
    public func transaction(merchantId: String, merchantTransactionId: String) async throws -> PhonePeResponse<CheckStatusResponse> {
        throw PhonePeError(
            success: false,
            code: .BAD_REQUEST,
            message: "transaction(merchantId:merchantTransactionId:) is not supported in v2 mode. Use transaction(merchantOrderId:) instead."
        )
    }

    /// Default — throws for v1 clients that call the v2 status overload.
    public func transaction(merchantOrderId: String) async throws -> V2OrderStatusResponse {
        throw PhonePeError(
            success: false,
            code: .BAD_REQUEST,
            message: "transaction(merchantOrderId:) is not supported in v1 mode. Use transaction(merchantId:merchantTransactionId:) instead."
        )
    }
}

// MARK: - V1 Status Routes

/// V1 implementation of transaction status and merchant health routes.
///
/// `PhonePeStatusRoutes` is wired by ``PhonePeClient`` when you supply a
/// ``PhonePeCredential/v1(saltKey:saltIndex:)`` credential.
///
/// Access via ``PhonePeClient/status``:
///
/// ```swift
/// let status = try await client.status.transaction(
///     merchantId: "PGTESTPAYUAT86",
///     merchantTransactionId: "TXN_001"
/// )
/// ```
public struct PhonePeStatusRoutes: StatusRoutes {

    /// Additional HTTP headers merged into every outbound request.
    public var headers: HTTPHeaders = [:]

    private let apiHandler: PhonePeAPIHandler
    private let baseUrl: String
    private let healthBaseUrl: String

    init(apiHandler: PhonePeAPIHandler, baseUrl: String, healthBaseUrl: String) {
        self.apiHandler = apiHandler
        self.baseUrl = baseUrl
        self.healthBaseUrl = healthBaseUrl
    }

    /// Queries v1 transaction status via `GET /pg/v1/status/{merchantId}/{merchantTransactionId}`.
    ///
    /// - Parameters:
    ///   - merchantId: Your PhonePe merchant identifier.
    ///   - merchantTransactionId: The transaction ID originally passed in the payment request.
    /// - Returns: A ``PhonePeResponse`` wrapping a ``CheckStatusResponse``.
    /// - Throws: ``PhonePeError`` on authentication failure or if the transaction is not found.
    public func transaction(merchantId: String, merchantTransactionId: String) async throws -> PhonePeResponse<CheckStatusResponse> {
        let path = "/pg/v1/status/\(merchantId)/\(merchantTransactionId)"

        var requestHeaders = headers
        requestHeaders.add(name: "X-MERCHANT-ID", value: merchantId)
        requestHeaders.add(name: "merchantId", value: merchantId)
        requestHeaders.add(name: "merchantTransactionId", value: merchantTransactionId)

        return try await apiHandler.send(
            method: .GET,
            path: path,
            headers: requestHeaders
        )
    }

    /// Queries merchant health via `GET https://uptime.phonepe.com/v1/pg/merchants/{merchantId}/health`.
    ///
    /// - Parameter merchantId: Your PhonePe merchant identifier.
    /// - Returns: A ``HealthStatusResponse`` describing gateway availability.
    /// - Throws: ``PhonePeError`` on network errors.
    public func health(merchantId: String) async throws -> HealthStatusResponse {
        let path = "/v1/pg/merchants/\(merchantId)/health"

        var requestHeaders = headers
        requestHeaders.add(name: "X-MERCHANT-ID", value: merchantId)
        requestHeaders.add(name: "merchantId", value: merchantId)

        return try await apiHandler.send(
            method: .GET,
            path: path,
            headers: requestHeaders,
            baseUrl: healthBaseUrl
        )
    }
}
