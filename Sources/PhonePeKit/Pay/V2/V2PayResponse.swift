//
//  V2PayResponse.swift
//
//
//  Created for PhonePe v2 API support.
//

import Foundation

// MARK: - Pay Response

/// Response returned after successfully initiating a v2 standard checkout payment.
///
/// After receiving this response, redirect the user to ``redirectUrl`` to complete
/// the payment on PhonePe's hosted checkout page.
public struct V2PayResponse: Codable {
    /// PhonePe's internal order identifier. Store this alongside your `merchantOrderId`
    /// for reconciliation.
    public let orderId: String

    /// Current state of the order. Typical values: `"PENDING"`, `"COMPLETED"`, `"FAILED"`.
    public let state: String

    /// Unix epoch timestamp (milliseconds) after which the payment session expires.
    public let expireAt: Int64?

    /// URL to redirect the user to for completing payment on PhonePe's hosted page.
    public let redirectUrl: String?
}

// MARK: - Order Status Response

/// Response from a v2 order status query (``PhonePeStatusRoutesV2/transaction(merchantOrderId:)``).
///
/// Poll this after a payment to determine the final outcome.
///
/// ## Example
///
/// ```swift
/// let status = try await client.status.transaction(merchantOrderId: "ORDER_20240101_001")
/// switch status.state {
/// case "COMPLETED": print("Payment successful, amount: \(status.amount)")
/// case "FAILED":    print("Payment failed: \(status.errorCode ?? "unknown")")
/// default:          print("Payment pending")
/// }
/// ```
public struct V2OrderStatusResponse: Codable {
    /// PhonePe's internal order identifier.
    public let orderId: String

    /// Current order state. Values: `"PENDING"`, `"COMPLETED"`, `"FAILED"`.
    public let state: String

    /// Total order amount in paise.
    public let amount: Int64

    /// Unix epoch timestamp (milliseconds) at which the session expired or will expire.
    public let expireAt: Int64?

    /// High-level error code when `state` is `"FAILED"` (e.g. `"PAYMENT_DECLINED"`).
    public let errorCode: String?

    /// Granular error code providing additional failure context.
    public let detailedErrorCode: String?

    /// Individual payment attempt details within this order.
    public let paymentDetails: [PaymentDetail]?

    /// Details of a single payment attempt within an order.
    public struct PaymentDetail: Codable {
        /// PhonePe transaction identifier for this attempt.
        public let transactionId: String?
        /// Payment mode used (e.g. `"UPI"`, `"CARD"`, `"NET_BANKING"`).
        public let paymentMode: String?
        /// Unix epoch timestamp (milliseconds) of this attempt.
        public let timestamp: Int64?
        /// Amount attempted in paise.
        public let amount: Int64?
        /// Outcome of this attempt: `"COMPLETED"`, `"FAILED"`, or `"PENDING"`.
        public let state: String?
        /// Error code when this attempt failed.
        public let errorCode: String?
    }
}

// MARK: - Refund Request

/// Request body for initiating a v2 refund
/// (``PhonePePayRoutesV2/RefundRoutesV2/initiate(request:)``).
///
/// Refunds are partial or full reversals of a completed `COMPLETED` order.
/// Partial refunds are supported by specifying an `amount` less than the original.
///
/// ## Example
///
/// ```swift
/// let refundReq = V2RefundRequest(
///     merchantRefundId: "REFUND_001",
///     originalMerchantOrderId: "ORDER_20240101_001",
///     amount: 5000 // Partial refund of ₹50
/// )
/// let refund = try await client.payments.refund.initiate(request: refundReq)
/// ```
public struct V2RefundRequest: Codable {
    /// Your unique identifier for this refund. Must be unique across all refunds.
    public let merchantRefundId: String

    /// The `merchantOrderId` of the original completed payment being refunded.
    public let originalMerchantOrderId: String

    /// Refund amount in paise. Must be ≤ the original payment amount.
    public let amount: Int64

    /// Creates a v2 refund request.
    ///
    /// - Parameters:
    ///   - merchantRefundId: Your unique refund identifier.
    ///   - originalMerchantOrderId: The merchant order ID of the original payment.
    ///   - amount: Refund amount in paise.
    public init(merchantRefundId: String, originalMerchantOrderId: String, amount: Int64) {
        self.merchantRefundId = merchantRefundId
        self.originalMerchantOrderId = originalMerchantOrderId
        self.amount = amount
    }
}

// MARK: - Refund Response

/// Response from a v2 refund initiation.
public struct V2RefundResponse: Codable {
    /// PhonePe's internal refund identifier.
    public let refundId: String?

    /// Your merchant-supplied refund identifier (echoed back).
    public let merchantRefundId: String?

    /// Refund amount in paise.
    public let amount: Int64

    /// Current state of the refund. Values: `"PENDING"`, `"COMPLETED"`, `"FAILED"`.
    public let state: String
}

// MARK: - Refund Status Response

/// Response from a v2 refund status query
/// (``PhonePePayRoutesV2/RefundRoutesV2/status(merchantRefundId:)``).
public struct V2RefundStatusResponse: Codable {
    /// PhonePe's internal refund identifier.
    public let refundId: String?

    /// Your merchant-supplied refund identifier.
    public let merchantRefundId: String?

    /// The `merchantOrderId` of the original payment that was refunded.
    public let originalMerchantOrderId: String?

    /// Refund amount in paise.
    public let amount: Int64

    /// Current state of the refund. Values: `"PENDING"`, `"COMPLETED"`, `"FAILED"`.
    public let state: String

    /// Unix epoch timestamp (milliseconds) when the refund was processed.
    public let timestamp: Int64?

    /// Error code when `state` is `"FAILED"`.
    public let errorCode: String?
}
