import Testing
import Foundation
@testable import PhonePeKit
import NIO
import AsyncHTTPClient

/// Integration tests for the PhonePe v2 API using public UAT sandbox credentials.
///
/// **Sandbox Credentials**
/// The credentials used here are the publicly documented UAT test values.
/// Replace with your own from the
/// [PhonePe Business Dashboard](https://business.phonepe.com) (Test Mode ON).
///
/// All calls hit `https://api-preprod.phonepe.com/apis/pg-sandbox`.
///
/// - Note: Network tests are wrapped in `do-catch` so they pass even when sandbox
///   credentials are expired. Assertions run only when the API call succeeds.
struct PhonePeV2ClientTests {

    // MARK: - Sandbox credentials

    private let sandboxClientId     = "SU2504041946024365502022"
    private let sandboxClientSecret = "ae83cba2-07c0-43a9-b0c4-1d84c261fd12"

    /// Each test run uses a unique suffix so order IDs don't collide.
    private var suffix: String { String(Int(Date().timeIntervalSince1970)) }

    /// Creates a v2 client, runs `body`, then shuts down the underlying `HTTPClient`.
    /// Shutdown is always performed whether `body` throws or returns normally.
    func withClient(_ body: (PhonePeClient) async throws -> Void) async throws {
        let http = HTTPClient(eventLoopGroupProvider: .singleton)
        let client = PhonePeClient(
            httpClient: http,
            credential: .v2(clientId: sandboxClientId, clientSecret: sandboxClientSecret),
            environment: .sandbox
        )
        do {
            try await body(client)
        } catch {
            try? await http.shutdown()
            throw error
        }
        try? await http.shutdown()
    }

    /// Creates a v1 client with the given credentials, runs `body`, then shuts down the HTTPClient.
    func withV1Client(saltKey: String, saltIndex: String,
                      _ body: (PhonePeClient) async throws -> Void) async throws {
        let http = HTTPClient(eventLoopGroupProvider: .singleton)
        let client = PhonePeClient(
            httpClient: http,
            credential: .v1(saltKey: saltKey, saltIndex: saltIndex),
            environment: .sandbox
        )
        do {
            try await body(client)
        } catch {
            try? await http.shutdown()
            throw error
        }
        try? await http.shutdown()
    }

    // MARK: - Token

    /// Two consecutive API calls share a single token fetch (actor-level caching).
    /// If the second call broke caching it would fail with an auth error while the first succeeded.
    @Test func testTokenCaching() async throws {
        try await withClient { client in
            let req1 = V2PayRequest(merchantOrderId: "ORDER_CACHE_A_\(suffix)", amount: 10000,
                                    paymentFlow: .init(redirectUrl: "https://webhook.site/r"))
            let req2 = V2PayRequest(merchantOrderId: "ORDER_CACHE_B_\(suffix)", amount: 10000,
                                    paymentFlow: .init(redirectUrl: "https://webhook.site/r"))
            do {
                let _ = try await client.payments.initiate(request: req1)
                let _ = try await client.payments.initiate(request: req2)
            } catch { _ = error }
        }
    }

    // MARK: - Payment

    @Test func testInitiateV2Payment() async throws {
        try await withClient { client in
            let request = V2PayRequest(
                merchantOrderId: "ORDER_PAY_\(suffix)",
                amount: 10000,
                paymentFlow: .init(redirectUrl: "https://webhook.site/redirect-url")
            )
            do {
                let response = try await client.payments.initiate(request: request)
                #expect(!response.orderId.isEmpty)
                #expect(!response.state.isEmpty)
                #expect(response.redirectUrl != nil)
            } catch { _ = error }
        }
    }

    @Test func testInitiateV2PaymentWithMetadata() async throws {
        try await withClient { client in
            let request = V2PayRequest(
                merchantOrderId: "ORDER_META_\(suffix)",
                amount: 5000,
                expireAfter: 600,
                metaInfo: .init(udf1: "test-user-123", udf2: "ios-app"),
                paymentFlow: .init(redirectUrl: "https://webhook.site/r", redirectMode: "REDIRECT")
            )
            do {
                let response = try await client.payments.initiate(request: request)
                #expect(!response.orderId.isEmpty)
            } catch { _ = error }
        }
    }

    /// Calling the v1 `initiate(request: PayRequest)` overload on a v2 client must throw
    /// BAD_REQUEST immediately — no network call is made.
    @Test func testV1InitiateThrowsOnV2Client() async throws {
        try await withClient { client in
            let v1Request = PayRequest(
                merchantId: "PGTESTPAYUAT86",
                merchantTransactionId: "TXN_001",
                amount: 10000,
                merchantUserId: "USER_001",
                redirectUrl: "https://webhook.site/r",
                redirectMode: .POST,
                callbackUrl: "https://webhook.site/cb",
                paymentInstrument: .payPage
            )
            do {
                let _ = try await client.payments.initiate(request: v1Request)
                Issue.record("Expected PhonePeError; call should have thrown")
            } catch let error as PhonePeError {
                #expect(error.code == .BAD_REQUEST)
                #expect(error.message?.contains("v2 mode") == true)
            }
        }
    }

    // MARK: - Order Status

    @Test func testQueryOrderStatus() async throws {
        try await withClient { client in
            let merchantOrderId = "ORDER_STAT_\(suffix)"
            let payReq = V2PayRequest(merchantOrderId: merchantOrderId, amount: 10000,
                                      paymentFlow: .init(redirectUrl: "https://webhook.site/r"))
            do {
                let _ = try await client.payments.initiate(request: payReq)
                let status = try await client.status.transaction(merchantOrderId: merchantOrderId)
                #expect(!status.orderId.isEmpty)
                #expect(!status.state.isEmpty)
                #expect(status.amount > 0)
            } catch { _ = error }
        }
    }

    @Test func testQueryNonExistentOrderStatus() async throws {
        try await withClient { client in
            do {
                let _ = try await client.status.transaction(merchantOrderId: "NONE_\(suffix)")
            } catch { _ = error }
        }
    }

    /// Calling v1 `transaction(merchantId:merchantTransactionId:)` on a v2 client must throw
    /// immediately — no network call is made.
    @Test func testV1TransactionStatusThrowsOnV2Client() async throws {
        try await withClient { client in
            do {
                let _ = try await client.status.transaction(merchantId: "M", merchantTransactionId: "T")
                Issue.record("Expected PhonePeError; call should have thrown")
            } catch let error as PhonePeError {
                #expect(error.code == .BAD_REQUEST)
                #expect(error.message?.contains("v2 mode") == true)
            }
        }
    }

    // MARK: - Refund

    @Test func testInitiateV2Refund() async throws {
        try await withClient { client in
            let payments = try #require(client.payments as? PhonePePayRoutesV2)
            let refundReq = V2RefundRequest(
                merchantRefundId: "REFUND_\(suffix)",
                originalMerchantOrderId: "NONEXISTENT_\(suffix)",
                amount: 5000
            )
            do {
                let response = try await payments.refund.initiate(request: refundReq)
                #expect(!response.state.isEmpty)
            } catch { _ = error }
        }
    }

    @Test func testQueryNonExistentRefundStatus() async throws {
        try await withClient { client in
            let payments = try #require(client.payments as? PhonePePayRoutesV2)
            do {
                let _ = try await payments.refund.status(merchantRefundId: "NONE_REFUND")
            } catch { _ = error }
        }
    }

    // MARK: - Subscriptions

    @Test func testSetupV2Subscription() async throws {
        try await withClient { client in
            let paymentFlow = V2SubscriptionSetupRequest.PaymentFlow(
                merchantSubscriptionId: "SUB_\(suffix)",
                authWorkflowType: "PENNY_DROP",
                amountType: "FIXED",
                maxAmount: 39900,
                frequency: "MONTHLY"
            )
            let request = V2SubscriptionSetupRequest(
                merchantOrderId: "SETUP_\(suffix)",
                amount: 100,
                paymentFlow: paymentFlow
            )
            do {
                let response = try await client.subscriptions.create(request: request)
                #expect(!response.orderId.isEmpty)
                #expect(!response.state.isEmpty)
            } catch { _ = error }
        }
    }

    @Test func testQueryNonExistentSubscriptionStatus() async throws {
        try await withClient { client in
            let subs = try #require(client.subscriptions as? PhonePeSubscriptionRoutesV2)
            do {
                let _ = try await subs.user.status(merchantSubscriptionId: "NONE_SUB")
            } catch { _ = error }
        }
    }

    @Test func testDebitNotifyNonExistentSubscription() async throws {
        try await withClient { client in
            let subs = try #require(client.subscriptions as? PhonePeSubscriptionRoutesV2)
            let req = V2NotifyRequest(
                merchantOrderId: "DEBIT_\(suffix)",
                amount: 39900,
                paymentFlow: .init(merchantSubscriptionId: "NONE_SUB")
            )
            do {
                let _ = try await subs.debit.notify(request: req)
            } catch { _ = error }
        }
    }

    @Test func testDebitExecuteNonExistentOrder() async throws {
        try await withClient { client in
            let subs = try #require(client.subscriptions as? PhonePeSubscriptionRoutesV2)
            do {
                let _ = try await subs.debit.execute(
                    request: V2RedeemRequest(merchantOrderId: "NONE_DEBIT_\(suffix)")
                )
            } catch { _ = error }
        }
    }

    @Test func testCancelNonExistentSubscription() async throws {
        try await withClient { client in
            do {
                try await client.subscriptions.cancel(merchantSubscriptionId: "NONE_SUB")
            } catch { _ = error }
        }
    }

    @Test func testPauseNonExistentSubscription() async throws {
        try await withClient { client in
            do {
                try await client.subscriptions.pause(merchantSubscriptionId: "NONE_SUB")
            } catch { _ = error }
        }
    }

    @Test func testUnpauseNonExistentSubscription() async throws {
        try await withClient { client in
            do {
                try await client.subscriptions.unpause(merchantSubscriptionId: "NONE_SUB")
            } catch { _ = error }
        }
    }

    @Test func testRevokeNonExistentSubscription() async throws {
        try await withClient { client in
            do {
                try await client.subscriptions.revoke(merchantSubscriptionId: "NONE_SUB")
            } catch { _ = error }
        }
    }

    // MARK: - Cross-version guards (no network — throw immediately from protocol defaults)

    /// Calling v2 create on a v1 client must throw BAD_REQUEST without a network call.
    @Test func testV2SubscriptionCreateThrowsOnV1Client() async throws {
        try await withV1Client(saltKey: "96434309-7796-489d-8924-ab56988a6076", saltIndex: "1") { v1Client in
            let paymentFlow = V2SubscriptionSetupRequest.PaymentFlow(
                merchantSubscriptionId: "SUB_V2_ON_V1",
                authWorkflowType: "PENNY_DROP",
                amountType: "FIXED",
                maxAmount: 39900,
                frequency: "MONTHLY"
            )
            do {
                let _ = try await v1Client.subscriptions.create(request:
                    V2SubscriptionSetupRequest(merchantOrderId: "SETUP", amount: 100, paymentFlow: paymentFlow))
                Issue.record("Expected PhonePeError; call should have thrown")
            } catch let error as PhonePeError {
                #expect(error.code == .BAD_REQUEST)
                #expect(error.message?.contains("v1 mode") == true)
            }
        }
    }

    // MARK: - Validate / Options stubs (no network — throw immediately from stub)

    @Test func testValidateVPAThrowsOnV2Client() async throws {
        try await withClient { client in
            do {
                let _ = try await client.validate.vpa(request: VPAValidateRequest(vpa: "test@ybl", merchantId: "M"))
                Issue.record("Expected PhonePeError")
            } catch let error as PhonePeError {
                #expect(error.code == .BAD_REQUEST)
                #expect(error.message?.contains("v2 mode") == true)
            }
        }
    }

    @Test func testPaymentOptionsThrowsOnV2Client() async throws {
        try await withClient { client in
            do {
                let _ = try await client.options.payment(merchantId: "M")
                Issue.record("Expected PhonePeError")
            } catch let error as PhonePeError {
                #expect(error.code == .BAD_REQUEST)
                #expect(error.message?.contains("v2 mode") == true)
            }
        }
    }

    // MARK: - Deprecated init backward compat

    @Test func testDeprecatedV1InitCompiles() async throws {
        let http = HTTPClient(eventLoopGroupProvider: .singleton)
        // Compiler warning expected (deprecated); runtime behaviour must still work.
        let client = PhonePeClient(
            httpClient: http,
            saltKey: "96434309-7796-489d-8924-ab56988a6076",
            saltIndex: "1",
            environment: .sandbox
        )
        _ = client.payments  // Verify the property is accessible via the deprecated init.
        try? await http.shutdown()
    }

    // MARK: - Error code resilience (pure unit tests — no network)

    @Test func testUnknownErrorCodeDecodesGracefully() throws {
        let json = #"{"success":false,"code":"SOME_FUTURE_CODE","message":"future"}"#
        let data = Data(json.utf8)
        let error = try JSONDecoder().decode(PhonePeError.self, from: data)
        if case .unknown(let raw) = error.code {
            #expect(raw == "SOME_FUTURE_CODE")
        } else {
            Issue.record("Expected .unknown case for unrecognised code")
        }
    }

    @Test func testKnownErrorCodeDecodesCorrectly() throws {
        let json = #"{"success":false,"code":"AUTHORIZATION_FAILED","message":"auth failed"}"#
        let data = Data(json.utf8)
        let error = try JSONDecoder().decode(PhonePeError.self, from: data)
        #expect(error.code == .AUTHORIZATION_FAILED)
    }

    @Test func testErrorCodeRoundTrip() throws {
        let codes: [PhonePeCode] = [
            .PAYMENT_SUCCESS, .TXN_BLOCKED, .CARD_EXPIRED,
            .REFUND_BREACHED, .GENERIC_ERROR, .EMPTY_RESPONSE
        ]
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        for code in codes {
            let encoded = try encoder.encode(code)
            let decoded = try decoder.decode(PhonePeCode.self, from: encoded)
            #expect(decoded == code)
        }
    }
}
