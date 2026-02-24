//
//  V2PayRequest.swift
//
//
//  Created for PhonePe v2 API support.
//

import Foundation

/// Request body for initiating a v2 standard checkout (PG Checkout) payment.
///
/// Build a `V2PayRequest` and pass it to
/// ``PhonePePayRoutesV2/initiate(request:)-v2`` to start a payment session.
///
/// ## Example
///
/// ```swift
/// let request = V2PayRequest(
///     merchantOrderId: "ORDER_20240101_001",
///     amount: 10000, // ₹100.00 in paise
///     paymentFlow: .init(redirectUrl: "https://example.com/return")
/// )
/// let response = try await client.payments.initiate(request: request)
/// print(response.redirectUrl) // Redirect the user here to complete payment
/// ```
public struct V2PayRequest: Codable {

    /// Your unique identifier for this order. Must be unique across all orders for your merchant account.
    public let merchantOrderId: String

    /// Payment amount in the smallest currency unit (paise for INR).
    /// For example, ₹100 = `10000`.
    public let amount: Int64

    /// Number of seconds after which the payment session expires.
    /// PhonePe applies a platform-default expiry when this is `nil`.
    public let expireAfter: Int?

    /// Optional key-value metadata attached to the order. Returned as-is in status responses.
    public let metaInfo: MetaInfo?

    /// Describes how the user will complete the payment (redirect flow, payment mode, etc.).
    public let paymentFlow: PaymentFlow

    // MARK: - Nested types

    /// Arbitrary metadata fields (`udf1`–`udf5`) stored alongside the order.
    ///
    /// Use these to attach business-specific identifiers (e.g. internal order IDs,
    /// customer segments) that are echoed back in status callbacks.
    public struct MetaInfo: Codable {
        /// User-defined field 1.
        public let udf1: String?
        /// User-defined field 2.
        public let udf2: String?
        /// User-defined field 3.
        public let udf3: String?
        /// User-defined field 4.
        public let udf4: String?
        /// User-defined field 5.
        public let udf5: String?

        public init(udf1: String? = nil, udf2: String? = nil, udf3: String? = nil,
                    udf4: String? = nil, udf5: String? = nil) {
            self.udf1 = udf1; self.udf2 = udf2; self.udf3 = udf3
            self.udf4 = udf4; self.udf5 = udf5
        }
    }

    /// Defines the payment UX flow — currently always `PG_CHECKOUT` with a redirect URL.
    ///
    /// After the user completes (or abandons) payment on the PhonePe-hosted page,
    /// they are redirected back to `redirectUrl`.
    public struct PaymentFlow: Codable {
        /// Flow type identifier. Always `"PG_CHECKOUT"` for standard checkout.
        public let type: String

        /// URL to redirect the user to after payment completion or failure.
        public let redirectUrl: String

        /// Optional redirect mode (`"REDIRECT"` or `"POST"`). Defaults to `"REDIRECT"` when `nil`.
        public let redirectMode: String?

        /// Creates a standard PG Checkout payment flow.
        ///
        /// - Parameters:
        ///   - redirectUrl: The URL PhonePe redirects the user to after payment.
        ///   - redirectMode: `"REDIRECT"` (default) or `"POST"`.
        public init(redirectUrl: String, redirectMode: String? = nil) {
            self.type = "PG_CHECKOUT"
            self.redirectUrl = redirectUrl
            self.redirectMode = redirectMode
        }
    }

    // MARK: - Init

    /// Creates a v2 pay request.
    ///
    /// - Parameters:
    ///   - merchantOrderId: Your unique order identifier.
    ///   - amount: Amount in paise (smallest currency unit).
    ///   - expireAfter: Session expiry in seconds. Pass `nil` for the platform default.
    ///   - metaInfo: Optional UDF metadata to attach to the order.
    ///   - paymentFlow: Checkout flow configuration including the redirect URL.
    public init(merchantOrderId: String,
                amount: Int64,
                expireAfter: Int? = nil,
                metaInfo: MetaInfo? = nil,
                paymentFlow: PaymentFlow) {
        self.merchantOrderId = merchantOrderId
        self.amount = amount
        self.expireAfter = expireAfter
        self.metaInfo = metaInfo
        self.paymentFlow = paymentFlow
    }
}
