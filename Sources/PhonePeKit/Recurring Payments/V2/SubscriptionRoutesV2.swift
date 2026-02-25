//
//  SubscriptionRoutesV2.swift
//
//
//  Created for PhonePe v2 API support.
//

import Foundation
import NIO
import NIOHTTP1
import AsyncHTTPClient

/// V2 implementation of recurring subscription (Autopay) routes.
///
/// `PhonePeSubscriptionRoutesV2` conforms to ``SubscriptionRoutes`` and is wired
/// automatically by ``PhonePeClient`` when you use a
/// ``PhonePeCredential/v2(clientId:clientSecret:clientVersion:)`` credential.
///
/// ## Subscription Lifecycle
///
/// ```
/// 1. create()     → Setup mandate, redirect user to intentUrl
/// 2. user.status() → Wait for ACTIVE state
/// 3. debit.notify() → 24–48h before each cycle
/// 4. debit.execute() → Trigger debit (if autoDebit is false)
/// 5. cancel()/pause()/unpause()/revoke() → Lifecycle management
/// ```
///
/// ## Quick Start
///
/// ```swift
/// // 1. Set up a subscription
/// let setupResp = try await client.subscriptions.create(request:
///     V2SubscriptionSetupRequest(
///         merchantOrderId: "SETUP_ORDER_001",
///         amount: 100,
///         paymentFlow: .init(
///             merchantSubscriptionId: "SUB_001",
///             authWorkflowType: "PENNY_DROP",
///             amountType: "FIXED",
///             maxAmount: 39900,
///             frequency: "MONTHLY"
///         )
///     )
/// )
/// // Redirect user to setupResp.intentUrl
///
/// // 2. Check subscription status
/// let status = try await client.subscriptions.user.status(merchantSubscriptionId: "SUB_001")
///
/// // 3. Notify upcoming debit
/// let notify = try await client.subscriptions.debit.notify(request:
///     V2NotifyRequest(
///         merchantOrderId: "DEBIT_ORDER_001",
///         amount: 39900,
///         paymentFlow: .init(merchantSubscriptionId: "SUB_001")
///     )
/// )
///
/// // 4. Execute the debit
/// let result = try await client.subscriptions.debit.execute(
///     request: V2RedeemRequest(merchantOrderId: "DEBIT_ORDER_001")
/// )
/// ```
public struct PhonePeSubscriptionRoutesV2: SubscriptionRoutes {

    /// Additional HTTP headers merged into every request sent by this route group.
    public var headers: HTTPHeaders = [:]

    /// Sub-routes for querying subscription and setup-order status.
    public let user: UserRoutesV2

    /// Sub-routes for notifying and executing subscription debits.
    public let debit: DebitRoutesV2

    private let apiHandler: PhonePeV2APIHandler
    private let baseUrl: String

    init(apiHandler: PhonePeV2APIHandler, baseUrl: String) {
        self.apiHandler = apiHandler
        self.baseUrl = baseUrl
        self.user = UserRoutesV2(apiHandler: apiHandler, baseUrl: baseUrl)
        self.debit = DebitRoutesV2(apiHandler: apiHandler, baseUrl: baseUrl)
    }

    // MARK: - Subscription setup

    /// Sets up a new v2 subscription mandate.
    ///
    /// Sends `POST /subscriptions/v2/setup`. After this call, redirect the user to
    /// ``V2SubscriptionSetupResponse/intentUrl`` for mandate authorisation.
    ///
    /// - Parameter request: Subscription setup details including subscription ID,
    ///   frequency, amount type, and maximum debit amount.
    /// - Returns: A ``V2SubscriptionSetupResponse`` containing the intent URL.
    /// - Throws: ``PhonePeError`` on validation errors or authentication failure.
    public func create(request: V2SubscriptionSetupRequest) async throws -> V2SubscriptionSetupResponse {
        let path = "/subscriptions/v2/setup"
        let requestBody = try JSONEncoder().encode(request)
        return try await apiHandler.send(
            method: .POST,
            path: path,
            body: .data(requestBody),
            headers: headers
        )
    }

    // MARK: - Lifecycle management

    /// Cancels an active v2 subscription.
    ///
    /// Sends `POST /subscriptions/v2/{merchantSubscriptionId}/cancel`.
    /// Cancellation is permanent; the subscription cannot be reactivated after cancellation.
    ///
    /// - Parameter merchantSubscriptionId: The unique subscription identifier to cancel.
    /// - Throws: ``PhonePeError`` if the subscription does not exist or is not cancellable.
    public func cancel(merchantSubscriptionId: String) async throws {
        let path = "/subscriptions/v2/\(merchantSubscriptionId)/cancel"
        let _: EmptyResponse = try await apiHandler.send(
            method: .POST,
            path: path,
            headers: headers
        )
    }

    /// Pauses an active v2 subscription.
    ///
    /// Sends `POST /subscriptions/v2/{merchantSubscriptionId}/pause`.
    /// While paused, no debits are executed. Resume with ``unpause(merchantSubscriptionId:)``.
    ///
    /// - Parameter merchantSubscriptionId: The unique subscription identifier to pause.
    /// - Throws: ``PhonePeError`` if the subscription does not exist or cannot be paused.
    public func pause(merchantSubscriptionId: String) async throws {
        let path = "/subscriptions/v2/\(merchantSubscriptionId)/pause"
        let _: EmptyResponse = try await apiHandler.send(
            method: .POST,
            path: path,
            headers: headers
        )
    }

    /// Resumes a paused v2 subscription.
    ///
    /// Sends `POST /subscriptions/v2/{merchantSubscriptionId}/unpause`.
    ///
    /// - Parameter merchantSubscriptionId: The unique subscription identifier to unpause.
    /// - Throws: ``PhonePeError`` if the subscription does not exist or is not paused.
    public func unpause(merchantSubscriptionId: String) async throws {
        let path = "/subscriptions/v2/\(merchantSubscriptionId)/unpause"
        let _: EmptyResponse = try await apiHandler.send(
            method: .POST,
            path: path,
            headers: headers
        )
    }

    /// Revokes (merchant-cancelled) a v2 subscription.
    ///
    /// Sends `POST /subscriptions/v2/{merchantSubscriptionId}/revoke`.
    /// Revocation is an irrecoverable action initiated by the merchant.
    ///
    /// - Parameter merchantSubscriptionId: The unique subscription identifier to revoke.
    /// - Throws: ``PhonePeError`` if the subscription does not exist or is not revocable.
    public func revoke(merchantSubscriptionId: String) async throws {
        let path = "/subscriptions/v2/\(merchantSubscriptionId)/revoke"
        let _: EmptyResponse = try await apiHandler.send(
            method: .POST,
            path: path,
            headers: headers
        )
    }

    // MARK: - V2 User Routes

    /// Sub-routes for querying subscription and setup-order status.
    ///
    /// Access via ``PhonePeSubscriptionRoutesV2/user``:
    ///
    /// ```swift
    /// // Subscription lifecycle status
    /// let status = try await client.subscriptions.user.status(merchantSubscriptionId: "SUB_001")
    ///
    /// // Setup order status
    /// let orderStatus = try await client.subscriptions.user.orderStatus(merchantOrderId: "SETUP_ORDER_001")
    /// ```
    public struct UserRoutesV2 {
        private let apiHandler: PhonePeV2APIHandler
        private let baseUrl: String

        init(apiHandler: PhonePeV2APIHandler, baseUrl: String) {
            self.apiHandler = apiHandler
            self.baseUrl = baseUrl
        }

        /// Queries the lifecycle status of a v2 subscription.
        ///
        /// Sends `GET /subscriptions/v2/{merchantSubscriptionId}/status`.
        ///
        /// - Parameter merchantSubscriptionId: Your unique subscription identifier.
        /// - Returns: A ``V2SubscriptionStatusResponse`` with the current mandate state,
        ///   amount configuration, and any pause window dates.
        /// - Throws: ``PhonePeError`` if the subscription is not found.
        public func status(merchantSubscriptionId: String) async throws -> V2SubscriptionStatusResponse {
            let path = "/subscriptions/v2/\(merchantSubscriptionId)/status"
            return try await apiHandler.send(
                method: .GET,
                path: path,
                headers: [:]
            )
        }

        /// Queries the order status for a v2 subscription setup order.
        ///
        /// Sends `GET /subscriptions/v2/order/{merchantOrderId}/status`.
        /// Use this to confirm that the mandate authorisation completed successfully.
        ///
        /// - Parameter merchantOrderId: The merchant order ID supplied in ``V2SubscriptionSetupRequest/merchantOrderId``.
        /// - Returns: A ``V2SubscriptionOrderStatusResponse`` with the setup order outcome.
        /// - Throws: ``PhonePeError`` if the order is not found.
        public func orderStatus(merchantOrderId: String) async throws -> V2SubscriptionOrderStatusResponse {
            let path = "/subscriptions/v2/order/\(merchantOrderId)/status"
            return try await apiHandler.send(
                method: .GET,
                path: path,
                headers: [:]
            )
        }
    }

    // MARK: - V2 Debit Routes

    /// Sub-routes for notifying and executing subscription debits.
    ///
    /// Access via ``PhonePeSubscriptionRoutesV2/debit``:
    ///
    /// ```swift
    /// // Notify upcoming debit (call 24–48h before)
    /// try await client.subscriptions.debit.notify(request: notifyReq)
    ///
    /// // Execute the debit
    /// try await client.subscriptions.debit.execute(request: V2RedeemRequest(merchantOrderId: "DEBIT_001"))
    /// ```
    public struct DebitRoutesV2 {
        private let apiHandler: PhonePeV2APIHandler
        private let baseUrl: String

        init(apiHandler: PhonePeV2APIHandler, baseUrl: String) {
            self.apiHandler = apiHandler
            self.baseUrl = baseUrl
        }

        /// Notifies PhonePe of an upcoming subscription debit.
        ///
        /// Sends `POST /subscriptions/v2/notify`. Must be called **24–48 hours before**
        /// the debit date so PhonePe can notify the user's bank.
        ///
        /// If ``V2NotifyRequest/PaymentFlow/autoDebit`` is `true`, PhonePe will automatically
        /// execute the debit without requiring an explicit call to ``execute(request:)``.
        ///
        /// - Parameter request: Debit notification details including the subscription ID and amount.
        /// - Returns: A ``V2NotifyResponse`` with the debit order ID and initial state.
        /// - Throws: ``PhonePeError`` if the subscription is not active or validation fails.
        public func notify(request: V2NotifyRequest) async throws -> V2NotifyResponse {
            let path = "/subscriptions/v2/notify"
            let requestBody = try JSONEncoder().encode(request)
            return try await apiHandler.send(
                method: .POST,
                path: path,
                body: .data(requestBody),
                headers: [:]
            )
        }

        /// Executes (redeems) a subscription debit after a successful notify call.
        ///
        /// Sends `POST /subscriptions/v2/redeem`. Only required when
        /// ``V2NotifyRequest/PaymentFlow/autoDebit`` was `false` in the preceding notify call.
        ///
        /// - Parameter request: Contains the `merchantOrderId` from the notify step.
        /// - Returns: A ``V2RedeemResponse`` with the debit outcome and PhonePe transaction ID.
        /// - Throws: ``PhonePeError`` if the notify step hasn't completed or the debit fails.
        public func execute(request: V2RedeemRequest) async throws -> V2RedeemResponse {
            let path = "/subscriptions/v2/redeem"
            let requestBody = try JSONEncoder().encode(request)
            return try await apiHandler.send(
                method: .POST,
                path: path,
                body: .data(requestBody),
                headers: [:]
            )
        }
    }
}

// MARK: - Helpers

/// Internal helper for decoding empty JSON responses from action endpoints
/// (cancel, pause, unpause, revoke).
private struct EmptyResponse: Codable {}
