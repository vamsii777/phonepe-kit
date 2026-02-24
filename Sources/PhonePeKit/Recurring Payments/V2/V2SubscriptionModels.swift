//
//  V2SubscriptionModels.swift
//
//
//  Created for PhonePe v2 API support.
//

import Foundation

// MARK: - Subscription Setup

/// Request body for setting up a new v2 recurring subscription.
///
/// Pass this to ``PhonePeSubscriptionRoutesV2/create(request:)`` to initiate the
/// subscription mandate flow. The user must authorise the mandate on the PhonePe-hosted
/// page identified by ``V2SubscriptionSetupResponse/intentUrl``.
///
/// ## Example
///
/// ```swift
/// let paymentFlow = V2SubscriptionSetupRequest.PaymentFlow(
///     merchantSubscriptionId: "SUB_20240101_001",
///     authWorkflowType: "PENNY_DROP",
///     amountType: "FIXED",
///     maxAmount: 39900,
///     frequency: "MONTHLY"
/// )
/// let req = V2SubscriptionSetupRequest(
///     merchantOrderId: "ORDER_SETUP_001",
///     amount: 100,          // Penny-drop amount in paise
///     paymentFlow: paymentFlow
/// )
/// let response = try await client.subscriptions.create(request: req)
/// // Redirect user to response.intentUrl for mandate authorisation
/// ```
public struct V2SubscriptionSetupRequest: Codable {

    /// Your unique identifier for the setup order.
    public let merchantOrderId: String

    /// Amount collected during mandate setup (e.g. ₹1 for PENNY_DROP) in paise.
    public let amount: Int64

    /// Unix epoch timestamp (milliseconds) after which the setup session expires.
    public let expireAt: Int64?

    /// Device information used to tailor the UPI intent flow.
    public let deviceContext: DeviceContext?

    /// Subscription-specific payment flow configuration.
    public let paymentFlow: PaymentFlow

    /// Optional UDF metadata attached to the setup order.
    public let metaInfo: MetaInfo?

    // MARK: - Nested types

    /// Device context for the user's mobile device.
    public struct DeviceContext: Codable {
        /// Device operating system. Expected values: `"ANDROID"`, `"IOS"`.
        public let deviceOS: String?

        public init(deviceOS: String? = nil) {
            self.deviceOS = deviceOS
        }
    }

    /// Subscription payment flow parameters embedded inside the setup order.
    ///
    /// The `type` field is always set to `"SUBSCRIPTION_SETUP"` automatically.
    public struct PaymentFlow: Codable {
        /// Always `"SUBSCRIPTION_SETUP"`.
        public let type: String

        /// Your unique subscription identifier. Used to manage the mandate lifecycle.
        public let merchantSubscriptionId: String

        /// Mandate authorisation workflow. Common values:
        /// - `"PENNY_DROP"` — Small debit for bank account verification.
        /// - `"UPI_MANDATE"` — Standard UPI mandate flow.
        public let authWorkflowType: String

        /// Debit amount type:
        /// - `"FIXED"` — Each debit is for a fixed `maxAmount`.
        /// - `"VARIABLE"` — Each debit can be up to `maxAmount`.
        public let amountType: String

        /// Maximum amount (in paise) that can be debited per cycle.
        public let maxAmount: Int64

        /// Debit frequency. Common values: `"DAILY"`, `"WEEKLY"`, `"MONTHLY"`, `"YEARLY"`, `"AS_PRESENTED"`.
        public let frequency: String

        /// Preferred payment mode (e.g. `"UPI"`, `"CARD"`). Optional.
        public let paymentMode: String?

        /// URL to redirect the user to after mandate authorisation. Optional.
        public let redirectUrl: String?

        /// Creates a subscription setup payment flow.
        ///
        /// - Parameters:
        ///   - merchantSubscriptionId: Your unique subscription identifier.
        ///   - authWorkflowType: Mandate authorisation method (`"PENNY_DROP"` or `"UPI_MANDATE"`).
        ///   - amountType: Whether debits are `"FIXED"` or `"VARIABLE"`.
        ///   - maxAmount: Maximum per-cycle debit amount in paise.
        ///   - frequency: Debit frequency (e.g. `"MONTHLY"`).
        ///   - paymentMode: Optional preferred payment mode.
        ///   - redirectUrl: Optional post-authorisation redirect URL.
        public init(merchantSubscriptionId: String,
                    authWorkflowType: String,
                    amountType: String,
                    maxAmount: Int64,
                    frequency: String,
                    paymentMode: String? = nil,
                    redirectUrl: String? = nil) {
            self.type = "SUBSCRIPTION_SETUP"
            self.merchantSubscriptionId = merchantSubscriptionId
            self.authWorkflowType = authWorkflowType
            self.amountType = amountType
            self.maxAmount = maxAmount
            self.frequency = frequency
            self.paymentMode = paymentMode
            self.redirectUrl = redirectUrl
        }
    }

    /// UDF metadata attached to the setup order.
    public struct MetaInfo: Codable {
        public let udf1: String?
        public let udf2: String?
        public let udf3: String?
        public let udf4: String?
        public let udf5: String?

        public init(udf1: String? = nil, udf2: String? = nil, udf3: String? = nil,
                    udf4: String? = nil, udf5: String? = nil) {
            self.udf1 = udf1; self.udf2 = udf2; self.udf3 = udf3
            self.udf4 = udf4; self.udf5 = udf5
        }
    }

    // MARK: - Init

    /// Creates a v2 subscription setup request.
    ///
    /// - Parameters:
    ///   - merchantOrderId: Your unique order identifier for the setup transaction.
    ///   - amount: Setup/penny-drop amount in paise.
    ///   - expireAt: Session expiry as Unix epoch milliseconds. Pass `nil` for platform default.
    ///   - deviceContext: Optional device context for UPI intent flows.
    ///   - paymentFlow: Subscription configuration (subscription ID, frequency, amount type, etc.).
    ///   - metaInfo: Optional UDF metadata.
    public init(merchantOrderId: String,
                amount: Int64,
                expireAt: Int64? = nil,
                deviceContext: DeviceContext? = nil,
                paymentFlow: PaymentFlow,
                metaInfo: MetaInfo? = nil) {
        self.merchantOrderId = merchantOrderId
        self.amount = amount
        self.expireAt = expireAt
        self.deviceContext = deviceContext
        self.paymentFlow = paymentFlow
        self.metaInfo = metaInfo
    }
}

/// Response from a v2 subscription setup (``PhonePeSubscriptionRoutesV2/create(request:)``).
public struct V2SubscriptionSetupResponse: Codable {
    /// PhonePe's internal order identifier for the setup transaction.
    public let orderId: String

    /// Current state of the setup order (`"PENDING"`, `"COMPLETED"`, `"FAILED"`).
    public let state: String

    /// Deep-link or web URL to direct the user to for mandate authorisation.
    public let intentUrl: String?

    /// Alternative redirect URL for web-based mandate flows.
    public let redirectUrl: String?
}

// MARK: - Subscription Order Status

/// Response from a v2 subscription setup order status query
/// (``PhonePeSubscriptionRoutesV2/UserRoutesV2/orderStatus(merchantOrderId:)``).
public struct V2SubscriptionOrderStatusResponse: Codable {
    /// PhonePe's internal order identifier.
    public let orderId: String

    /// Current state of the order.
    public let state: String

    /// Order amount in paise.
    public let amount: Int64

    /// Subscription flow details embedded in the order.
    public let paymentFlow: PaymentFlowInfo?

    /// Individual payment attempt details.
    public let paymentDetails: [PaymentDetail]?

    /// Subscription-specific fields echoed from the setup request.
    public struct PaymentFlowInfo: Codable {
        /// Always `"SUBSCRIPTION_SETUP"` for setup orders.
        public let type: String?
        /// Your merchant subscription identifier.
        public let merchantSubscriptionId: String?
    }

    /// Details of a single payment attempt.
    public struct PaymentDetail: Codable {
        public let transactionId: String?
        public let paymentMode: String?
        public let timestamp: Int64?
        public let amount: Int64?
        public let state: String?
        public let errorCode: String?
    }
}

// MARK: - Subscription Status

/// Response from a v2 subscription lifecycle status query
/// (``PhonePeSubscriptionRoutesV2/UserRoutesV2/status(merchantSubscriptionId:)``).
///
/// Use this to check whether a mandate is active, paused, cancelled, or revoked.
public struct V2SubscriptionStatusResponse: Codable {
    /// Your merchant-assigned subscription identifier.
    public let merchantSubscriptionId: String

    /// PhonePe's internal subscription identifier.
    public let subscriptionId: String?

    /// Current mandate state. Values: `"ACTIVE"`, `"PAUSED"`, `"CANCELLED"`, `"REVOKED"`, `"CREATED"`.
    public let state: String

    /// Mandate authorisation workflow type used during setup.
    public let authWorkflowType: String?

    /// Whether debits are `"FIXED"` or `"VARIABLE"`.
    public let amountType: String?

    /// Maximum per-cycle debit amount in paise.
    public let maxAmount: Int64?

    /// Debit frequency (e.g. `"MONTHLY"`).
    public let frequency: String?

    /// Unix epoch timestamp (milliseconds) at which the mandate expires.
    public let expireAt: Int64?

    /// Start of a pause window (Unix epoch milliseconds). Present when `state` is `"PAUSED"`.
    public let pauseStartDate: Int64?

    /// End of a pause window (Unix epoch milliseconds). Present when `state` is `"PAUSED"`.
    public let pauseEndDate: Int64?
}

// MARK: - Debit Notify

/// Request body for notifying PhonePe of an upcoming subscription debit
/// (``PhonePeSubscriptionRoutesV2/DebitRoutesV2/notify(request:)``).
///
/// Submit this **24–48 hours before** the intended debit date so that PhonePe can
/// notify the user's bank. If ``PaymentFlow/autoDebit`` is `true`, PhonePe will
/// automatically execute the debit after the notification window elapses.
///
/// ## Example
///
/// ```swift
/// let flow = V2NotifyRequest.PaymentFlow(
///     merchantSubscriptionId: "SUB_20240101_001",
///     autoDebit: false
/// )
/// let notifyReq = V2NotifyRequest(
///     merchantOrderId: "DEBIT_ORDER_001",
///     amount: 39900,
///     paymentFlow: flow
/// )
/// let notifyResp = try await client.subscriptions.debit.notify(request: notifyReq)
/// // Later, execute the debit manually:
/// let redeemResp = try await client.subscriptions.debit.execute(
///     request: V2RedeemRequest(merchantOrderId: "DEBIT_ORDER_001")
/// )
/// ```
public struct V2NotifyRequest: Codable {

    /// Your unique order identifier for this debit cycle.
    public let merchantOrderId: String

    /// Amount to debit in paise.
    public let amount: Int64

    /// Unix epoch timestamp (milliseconds) after which the debit window expires.
    public let expireAt: Int64?

    /// Debit redemption flow configuration.
    public let paymentFlow: PaymentFlow

    // MARK: - Nested types

    /// Debit redemption flow parameters.
    ///
    /// The `type` field is always set to `"SUBSCRIPTION_REDEMPTION"` automatically.
    public struct PaymentFlow: Codable {
        /// Always `"SUBSCRIPTION_REDEMPTION"`.
        public let type: String

        /// Your merchant subscription identifier (must already be in `ACTIVE` state).
        public let merchantSubscriptionId: String

        /// When `true`, PhonePe auto-executes the debit after the notification window.
        /// When `false` (default), call ``PhonePeSubscriptionRoutesV2/DebitRoutesV2/execute(request:)``
        /// explicitly to trigger the debit.
        public let autoDebit: Bool?

        /// Strategy for retrying failed debits. Pass `nil` to use the platform default.
        public let redemptionRetryStrategy: String?

        /// Creates a debit redemption payment flow.
        ///
        /// - Parameters:
        ///   - merchantSubscriptionId: The active subscription to debit.
        ///   - autoDebit: `true` to auto-execute after the bank notification window.
        ///   - redemptionRetryStrategy: Optional retry strategy identifier.
        public init(merchantSubscriptionId: String,
                    autoDebit: Bool? = nil,
                    redemptionRetryStrategy: String? = nil) {
            self.type = "SUBSCRIPTION_REDEMPTION"
            self.merchantSubscriptionId = merchantSubscriptionId
            self.autoDebit = autoDebit
            self.redemptionRetryStrategy = redemptionRetryStrategy
        }
    }

    // MARK: - Init

    /// Creates a v2 debit notify request.
    ///
    /// - Parameters:
    ///   - merchantOrderId: Your unique order identifier for this debit.
    ///   - amount: Debit amount in paise.
    ///   - expireAt: Debit window expiry as Unix epoch milliseconds.
    ///   - paymentFlow: Subscription redemption flow details.
    public init(merchantOrderId: String,
                amount: Int64,
                expireAt: Int64? = nil,
                paymentFlow: PaymentFlow) {
        self.merchantOrderId = merchantOrderId
        self.amount = amount
        self.expireAt = expireAt
        self.paymentFlow = paymentFlow
    }
}

/// Response from a v2 debit notify call.
public struct V2NotifyResponse: Codable {
    /// PhonePe's internal order identifier for the debit notification.
    public let orderId: String?

    /// Current state of the notification. Values: `"PENDING"`, `"COMPLETED"`, `"FAILED"`.
    public let state: String

    /// Unix epoch timestamp (milliseconds) after which the debit window expires.
    public let expireAt: Int64?
}

// MARK: - Debit Execute (Redeem)

/// Request body for executing (redeeming) a v2 subscription debit
/// (``PhonePeSubscriptionRoutesV2/DebitRoutesV2/execute(request:)``).
///
/// Call this after a successful ``V2NotifyRequest`` when
/// ``V2NotifyRequest/PaymentFlow/autoDebit`` is `false`.
public struct V2RedeemRequest: Codable {
    /// The `merchantOrderId` supplied in the preceding ``V2NotifyRequest``.
    public let merchantOrderId: String

    /// Creates a v2 redeem (debit execute) request.
    ///
    /// - Parameter merchantOrderId: The order ID from the notify step.
    public init(merchantOrderId: String) {
        self.merchantOrderId = merchantOrderId
    }
}

/// Response from a v2 debit execute (redeem) call.
public struct V2RedeemResponse: Codable {
    /// Outcome of the debit execution. Values: `"PENDING"`, `"COMPLETED"`, `"FAILED"`.
    public let state: String

    /// PhonePe transaction identifier for the debit, available when `state` is `"COMPLETED"`.
    public let transactionId: String?
}
