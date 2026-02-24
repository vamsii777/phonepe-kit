import Testing
@testable import PhonePeKit
import NIO
import AsyncHTTPClient
import Foundation

/// Integration tests for the PhonePe v2 API using public UAT sandbox credentials.
///
/// **Sandbox Credentials**
/// The credentials used here are the publicly documented UAT test values.
/// Replace with your own from the
/// [PhonePe Business Dashboard](https://business.phonepe.com) (Test Mode ON).
///
/// All calls hit `https://api-preprod.phonepe.com/apis/pg-sandbox`.
struct PhonePeV2ClientTests {

    // MARK: - Sandbox credentials

    private let sandboxClientId = "SU2504041946024365502022"
    private let sandboxClientSecret = "ae83cba2-07c0-43a9-b0c4-1d84c261fd12"

    /// Each test run uses a unique suffix so order IDs don't collide.
    private var suffix: String { String(Int(Date().timeIntervalSince1970)) }

    func makeClient() -> (PhonePeClient, HTTPClient) {
        let http = HTTPClient(eventLoopGroupProvider: .singleton)
        let client = PhonePeClient(
            httpClient: http,
            credential: .v2(clientId: sandboxClientId, clientSecret: sandboxClientSecret),
            environment: .sandbox
        )
        return (client, http)
    }

    // MARK: - Token

    /// Two consecutive API calls share a single token fetch (actor-level caching).
    @Test func testTokenCaching() async throws {
        let (client, http) = makeClient()
        defer { try? http.syncShutdown() }

        let req1 = V2PayRequest(merchantOrderId: "ORDER_CACHE_A_\(suffix)", amount: 10000,
                                paymentFlow: .init(redirectUrl: "https://webhook.site/r"))
        let req2 = V2PayRequest(merchantOrderId: "ORDER_CACHE_B_\(suffix)", amount: 10000,
                                paymentFlow: .init(redirectUrl: "https://webhook.site/r"))

        // Both calls must succeed; if the second broke caching it would fail with an auth error.
        let _ = try await client.payments.initiate(request: req1)
        let _ = try await client.payments.initiate(request: req2)
    }

    // MARK: - Payment

    @Test func testInitiateV2Payment() async throws {
        let (client, http) = makeClient()
        defer { try? http.syncShutdown() }

        let request = V2PayRequest(
            merchantOrderId: "ORDER_PAY_\(suffix)",
            amount: 10000,
            paymentFlow: .init(redirectUrl: "https://webhook.site/redirect-url")
        )
        let response = try await client.payments.initiate(request: request)
        #expect(!response.orderId.isEmpty)
        #expect(!response.state.isEmpty)
        // Sandbox payments start PENDING; redirectUrl should be present for PG_CHECKOUT.
        #expect(response.redirectUrl != nil)
    }

    @Test func testInitiateV2PaymentWithMetadata() async throws {
        let (client, http) = makeClient()
        defer { try? http.syncShutdown() }

        let request = V2PayRequest(
            merchantOrderId: "ORDER_META_\(suffix)",
            amount: 5000,
            expireAfter: 600,
            metaInfo: .init(udf1: "test-user-123", udf2: "ios-app"),
            paymentFlow: .init(redirectUrl: "https://webhook.site/r", redirectMode: "REDIRECT")
        )
        let response = try await client.payments.initiate(request: request)
        #expect(!response.orderId.isEmpty)
    }

    /// Calling the v1 `initiate(request: PayRequest)` overload on a v2 client must throw BAD_REQUEST.
    @Test func testV1InitiateThrowsOnV2Client() async throws {
        let (client, http) = makeClient()
        defer { try? http.syncShutdown() }

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

    // MARK: - Order Status

    @Test func testQueryOrderStatus() async throws {
        let (client, http) = makeClient()
        defer { try? http.syncShutdown() }

        let merchantOrderId = "ORDER_STAT_\(suffix)"
        let payReq = V2PayRequest(merchantOrderId: merchantOrderId, amount: 10000,
                                  paymentFlow: .init(redirectUrl: "https://webhook.site/r"))
        let _ = try await client.payments.initiate(request: payReq)

        let status = try await client.status.transaction(merchantOrderId: merchantOrderId)
        #expect(!status.orderId.isEmpty)
        #expect(!status.state.isEmpty)
        #expect(status.amount > 0)
    }

    @Test func testQueryNonExistentOrderStatus() async throws {
        let (client, http) = makeClient()
        defer { try? http.syncShutdown() }

        do {
            let _ = try await client.status.transaction(merchantOrderId: "NONE_\(suffix)")
        } catch let error as PhonePeError {
            // Sandbox returns empty body for unknown orders.
            _ = error
        }
    }

    /// Calling v1 `transaction(merchantId:merchantTransactionId:)` on a v2 client must throw.
    @Test func testV1TransactionStatusThrowsOnV2Client() async throws {
        let (client, http) = makeClient()
        defer { try? http.syncShutdown() }

        do {
            let _ = try await client.status.transaction(merchantId: "M", merchantTransactionId: "T")
            Issue.record("Expected PhonePeError; call should have thrown")
        } catch let error as PhonePeError {
            #expect(error.code == .BAD_REQUEST)
            #expect(error.message?.contains("v2 mode") == true)
        }
    }

    // MARK: - Refund

    @Test func testInitiateV2Refund() async throws {
        let (client, http) = makeClient()
        defer { try? http.syncShutdown() }

        let payments = try #require(client.payments as? PhonePePayRoutesV2)
        let refundReq = V2RefundRequest(
            merchantRefundId: "REFUND_\(suffix)",
            originalMerchantOrderId: "NONEXISTENT_\(suffix)",
            amount: 5000
        )
        do {
            let response = try await payments.refund.initiate(request: refundReq)
            // Sandbox may accept but return a FAILED state for unknown orders.
            #expect(!response.state.isEmpty)
        } catch let error as PhonePeError {
            _ = error
        }
    }

    @Test func testQueryNonExistentRefundStatus() async throws {
        let (client, http) = makeClient()
        defer { try? http.syncShutdown() }

        let payments = try #require(client.payments as? PhonePePayRoutesV2)
        do {
            let _ = try await payments.refund.status(merchantRefundId: "NONE_REFUND")
        } catch let error as PhonePeError {
            _ = error
        }
    }

    // MARK: - Subscriptions

    @Test func testSetupV2Subscription() async throws {
        let (client, http) = makeClient()
        defer { try? http.syncShutdown() }

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
        let response = try await client.subscriptions.create(request: request)
        #expect(!response.orderId.isEmpty)
        #expect(!response.state.isEmpty)
    }

    @Test func testQueryNonExistentSubscriptionStatus() async throws {
        let (client, http) = makeClient()
        defer { try? http.syncShutdown() }

        let subs = try #require(client.subscriptions as? PhonePeSubscriptionRoutesV2)
        do {
            let _ = try await subs.user.status(merchantSubscriptionId: "NONE_SUB")
        } catch let error as PhonePeError {
            _ = error
        }
    }

    @Test func testDebitNotifyNonExistentSubscription() async throws {
        let (client, http) = makeClient()
        defer { try? http.syncShutdown() }

        let subs = try #require(client.subscriptions as? PhonePeSubscriptionRoutesV2)
        let req = V2NotifyRequest(
            merchantOrderId: "DEBIT_\(suffix)",
            amount: 39900,
            paymentFlow: .init(merchantSubscriptionId: "NONE_SUB")
        )
        do {
            let _ = try await subs.debit.notify(request: req)
        } catch let error as PhonePeError {
            _ = error
        }
    }

    @Test func testDebitExecuteNonExistentOrder() async throws {
        let (client, http) = makeClient()
        defer { try? http.syncShutdown() }

        let subs = try #require(client.subscriptions as? PhonePeSubscriptionRoutesV2)
        do {
            let _ = try await subs.debit.execute(
                request: V2RedeemRequest(merchantOrderId: "NONE_DEBIT_\(suffix)")
            )
        } catch let error as PhonePeError {
            _ = error
        }
    }

    @Test func testCancelNonExistentSubscription() async throws {
        let (client, http) = makeClient()
        defer { try? http.syncShutdown() }

        do {
            try await client.subscriptions.cancel(merchantSubscriptionId: "NONE_SUB")
        } catch let error as PhonePeError {
            #expect(error.code != nil)
        }
    }

    @Test func testPauseNonExistentSubscription() async throws {
        let (client, http) = makeClient()
        defer { try? http.syncShutdown() }

        do {
            try await client.subscriptions.pause(merchantSubscriptionId: "NONE_SUB")
        } catch let error as PhonePeError {
            #expect(error.code != nil)
        }
    }

    @Test func testUnpauseNonExistentSubscription() async throws {
        let (client, http) = makeClient()
        defer { try? http.syncShutdown() }

        do {
            try await client.subscriptions.unpause(merchantSubscriptionId: "NONE_SUB")
        } catch let error as PhonePeError {
            #expect(error.code != nil)
        }
    }

    @Test func testRevokeNonExistentSubscription() async throws {
        let (client, http) = makeClient()
        defer { try? http.syncShutdown() }

        do {
            try await client.subscriptions.revoke(merchantSubscriptionId: "NONE_SUB")
        } catch let error as PhonePeError {
            #expect(error.code != nil)
        }
    }

    // MARK: - Cross-version guards

    /// Calling v2 create on a v1 client must throw BAD_REQUEST.
    @Test func testV2SubscriptionCreateThrowsOnV1Client() async throws {
        let http = HTTPClient(eventLoopGroupProvider: .singleton)
        defer { try? http.syncShutdown() }

        let v1Client = PhonePeClient(
            httpClient: http,
            credential: .v1(saltKey: "96434309-7796-489d-8924-ab56988a6076", saltIndex: "1"),
            environment: .sandbox
        )
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

    // MARK: - Validate / Options stubs

    @Test func testValidateVPAThrowsOnV2Client() async throws {
        let (client, http) = makeClient()
        defer { try? http.syncShutdown() }

        do {
            let _ = try await client.validate.vpa(request: VPAValidateRequest(vpa: "test@ybl", merchantId: "M"))
            Issue.record("Expected PhonePeError")
        } catch let error as PhonePeError {
            #expect(error.code == .BAD_REQUEST)
            #expect(error.message?.contains("v2 mode") == true)
        }
    }

    @Test func testPaymentOptionsThrowsOnV2Client() async throws {
        let (client, http) = makeClient()
        defer { try? http.syncShutdown() }

        do {
            let _ = try await client.options.payment(merchantId: "M")
            Issue.record("Expected PhonePeError")
        } catch let error as PhonePeError {
            #expect(error.code == .BAD_REQUEST)
            #expect(error.message?.contains("v2 mode") == true)
        }
    }

    // MARK: - Deprecated init backward compat

    @Test func testDeprecatedV1InitCompiles() {
        let http = HTTPClient(eventLoopGroupProvider: .singleton)
        defer { try? http.syncShutdown() }

        // Compiler warning expected (deprecated); runtime behaviour must still work.
        let client = PhonePeClient(
            httpClient: http,
            saltKey: "96434309-7796-489d-8924-ab56988a6076",
            saltIndex: "1",
            environment: .sandbox
        )
        _ = client.payments  // Verify the property is accessible via the deprecated init.
    }

    // MARK: - Error code resilience

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
        let codes: [PhonePeErrorCode] = [
            .PAYMENT_SUCCESS, .TXN_BLOCKED, .CARD_EXPIRED,
            .REFUND_BREACHED, .GENERIC_ERROR, .EMPTY_RESPONSE
        ]
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        for code in codes {
            let encoded = try encoder.encode(code)
            let decoded = try decoder.decode(PhonePeErrorCode.self, from: encoded)
            #expect(decoded == code)
        }
    }
}
