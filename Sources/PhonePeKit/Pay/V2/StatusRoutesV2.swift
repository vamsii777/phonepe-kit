//
//  StatusRoutesV2.swift
//
//
//  Created for PhonePe v2 API support.
//

import Foundation
import NIO
import NIOHTTP1
import AsyncHTTPClient

/// V2 implementation of order status and merchant health routes.
///
/// `PhonePeStatusRoutesV2` conforms to ``StatusRoutes`` and is wired automatically
/// by ``PhonePeClient`` when you use a ``PhonePeCredential/v2(clientId:clientSecret:clientVersion:)`` credential.
///
/// ## Checking Order Status
///
/// ```swift
/// let orderStatus = try await client.status.transaction(merchantOrderId: "ORDER_001")
/// if orderStatus.state == "COMPLETED" {
///     print("Payment of ₹\(orderStatus.amount / 100) received.")
/// }
/// ```
///
/// ## Checking Merchant Health
///
/// ```swift
/// let health = try await client.status.health(merchantId: "YOUR_MERCHANT_ID")
/// print(health) // HealthStatusResponse
/// ```
///
/// - Note: The health check endpoint is hosted on `https://uptime.phonepe.com` and is
///   unchanged between v1 and v2.
public struct PhonePeStatusRoutesV2: StatusRoutes {

    /// Additional HTTP headers merged into every request sent by this route group.
    public var headers: HTTPHeaders = [:]

    private let apiHandler: PhonePeV2APIHandler
    private let baseUrl: String
    private let healthBaseUrl: String

    init(apiHandler: PhonePeV2APIHandler, baseUrl: String, healthBaseUrl: String) {
        self.apiHandler = apiHandler
        self.baseUrl = baseUrl
        self.healthBaseUrl = healthBaseUrl
    }

    // MARK: - Order status

    /// Queries the current status of a v2 order by its merchant order ID.
    ///
    /// Sends `GET /checkout/v2/order/{merchantOrderId}/status`.
    ///
    /// Call this after receiving the payment callback or after a suitable polling
    /// interval to determine whether the payment completed, failed, or is still pending.
    ///
    /// - Parameter merchantOrderId: The unique order identifier you supplied in ``V2PayRequest/merchantOrderId``.
    /// - Returns: A ``V2OrderStatusResponse`` reflecting the current order state.
    /// - Throws: ``PhonePeError`` if the order is not found or authentication fails.
    public func transaction(merchantOrderId: String) async throws -> V2OrderStatusResponse {
        let path = "/checkout/v2/order/\(merchantOrderId)/status"
        return try await apiHandler.send(
            method: .GET,
            path: path,
            headers: headers
        )
    }

    // MARK: - Health

    /// Queries the health of the PhonePe Payment Gateway for your merchant account.
    ///
    /// Sends `GET https://uptime.phonepe.com/v1/pg/merchants/{merchantId}/health`.
    /// This endpoint is the same for both v1 and v2 and does not use OAuth2 authentication.
    ///
    /// - Parameter merchantId: Your PhonePe merchant identifier.
    /// - Returns: A ``HealthStatusResponse`` describing gateway availability.
    /// - Throws: ``PhonePeError`` on network errors or unexpected responses.
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
