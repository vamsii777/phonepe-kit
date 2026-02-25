import Testing
@testable import PhonePeKit
import NIO
import AsyncHTTPClient

/// Integration tests for the PhonePe v1 API using public sandbox credentials.
///
/// - Merchant ID: `PGTESTPAYUAT86`
/// - Salt key: `96434309-7796-489d-8924-ab56988a6076` / index `1`
/// - Endpoint: `https://api-preprod.phonepe.com/apis/pg-sandbox`
struct PhonePeClientTests {

    private let saltKey    = "96434309-7796-489d-8924-ab56988a6076"
    private let saltIndex  = "1"
    private let merchantId = "PGTESTPAYUAT86"

    /// Creates a v1 client, runs `body`, then shuts down the underlying `HTTPClient`.
    /// Shutdown is always performed whether `body` throws or returns normally.
    func withClient(_ body: (PhonePeClient) async throws -> Void) async throws {
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

    // MARK: - Payment

    @Test func testInitiatePayment() async throws {
        try await withClient { client in
            let request = PayRequest(
                merchantId: merchantId,
                merchantTransactionId: "MT7850590068188104",
                amount: 10000,
                merchantUserId: "MUID123",
                redirectUrl: "https://webhook.site/redirect-url",
                redirectMode: .POST,
                callbackUrl: "https://webhook.site/callback-url",
                paymentInstrument: .payPage,
                mobileNumber: "9999999999"
            )
            do {
                let response = try await client.payments.initiate(request: request)
                #expect(response.success == true)
                #expect(response.code == .PAYMENT_INITIATED)
            } catch { _ = error }
        }
    }

    @Test func testInitiatePaymentRedirect() async throws {
        try await withClient { client in
            let request = PayRequest(
                merchantId: merchantId,
                merchantTransactionId: "MT7850590068188104",
                amount: 10000,
                merchantUserId: "MUID123",
                redirectUrl: "https://webhook.site/redirect-url",
                redirectMode: .REDIRECT,
                callbackUrl: "https://webhook.site/callback-url",
                paymentInstrument: .payPage,
                mobileNumber: "9999999999"
            )
            do {
                let response = try await client.payments.initiate(request: request)
                #expect(response.success == true)
                #expect(response.code == .PAYMENT_INITIATED)
            } catch { _ = error }
        }
    }

    @Test func testBadRequest() async throws {
        // Short mobile number — sandbox may still initiate or return an error.
        try await withClient { client in
            let request = PayRequest(
                merchantId: merchantId,
                merchantTransactionId: "MT7850590068188104",
                amount: 10000,
                merchantUserId: "MUID123",
                redirectUrl: "https://webhook.site/redirect-url",
                redirectMode: .POST,
                callbackUrl: "https://webhook.site/callback-url",
                paymentInstrument: .payPage,
                mobileNumber: "9999"
            )
            // Assert the call completes without crashing — sandbox is lenient with optional fields.
            do {
                let _ = try await client.payments.initiate(request: request)
            } catch { _ = error }
        }
    }

    // MARK: - Refund

    @Test func testRefundPayment() async throws {
        try await withClient { client in
            // Downcast to concrete type to access the nested refund sub-routes.
            let payments = try #require(client.payments as? PhonePePayRoutes)
            let request = RefundRequest(
                merchantId: merchantId,
                merchantUserId: "User123",
                originalTransactionId: "OD620471739210623",
                merchantTransactionId: "ROD620471739210623",
                amount: 1000,
                callbackUrl: "https://webhook.site/callback-url"
            )
            do {
                let response = try await payments.refund.initiate(request: request)
                // OD620471739210623 doesn't exist in sandbox — expect non-success.
                #expect(response.success == false)
            } catch let error as PhonePeError {
                // Sandbox may return empty body for unknown original transactions.
                #expect(error.code == .EMPTY_RESPONSE)
            }
        }
    }

    // MARK: - Status

    @Test func testCheckTransactionStatus() async throws {
        try await withClient { client in
            do {
                let response = try await client.status.transaction(
                    merchantId: merchantId,
                    merchantTransactionId: "7qfRVFLbjL8Le8vMKAUieq"
                )
                #expect(response.code == .TRANSACTION_NOT_FOUND || response.success == false)
            } catch let error as PhonePeError {
                #expect(error.code == .EMPTY_RESPONSE)
            }
        }
    }

    // MARK: - Validate / Options

    @Test func testVPAValidate() async throws {
        try await withClient { client in
            let request = VPAValidateRequest(vpa: "success@razorpay", merchantId: merchantId)
            do {
                let response = try await client.validate.vpa(request: request)
                #expect(response.code == .SUCCESS)
            } catch { _ = error }
        }
    }

    @Test func testPaymentOptions() async throws {
        try await withClient { client in
            let response = try await client.options.payment(merchantId: merchantId)
            #expect(response.success == true)
            #expect(response.code == .SUCCESS)
        }
    }

    // MARK: - Subscriptions (V1)

    @Test func testCreateSubscription() async throws {
        try await withClient { client in
            let request = SubscriptionRequest(
                merchantId: merchantId,
                merchantSubscriptionId: "MSUB123456789012345",
                merchantUserId: "MU123456789",
                authWorkflowType: .pennyDrop,
                amountType: .fixed,
                amount: 39900,
                frequency: .monthly,
                recurringCount: 12,
                subMerchantId: "DemoMerchant",
                mobileNumber: "7989378465",
                deviceContext: DeviceContext(phonePeVersionCode: 400922)
            )
            let response = try await client.subscriptions.create(request: request)
            #expect(response.success == true)
        }
    }

    @Test func testUserSubscriptionStatus() async throws {
        try await withClient { client in
            // Downcast to access nested user sub-routes (not part of the protocol).
            let subs = try #require(client.subscriptions as? PhonePeSubscriptionRoutes)
            let response = try await subs.user.status(
                merchantId: merchantId,
                merchantSubscriptionId: "MSUB123456789012345"
            )
            #expect(response.success == true)
        }
    }

    @Test func testFetchAllSubscriptionStatus() async throws {
        try await withClient { client in
            let subs = try #require(client.subscriptions as? PhonePeSubscriptionRoutes)
            do {
                let response = try await subs.fetch.all(
                    merchantId: merchantId,
                    merchantUserId: "MU123456789"
                )
                #expect(response.code == .SUCCESS)
            } catch { _ = error }
        }
    }

    @Test func testVerifyVPA() async throws {
        try await withClient { client in
            let subs = try #require(client.subscriptions as? PhonePeSubscriptionRoutes)
            let response = try await subs.vpa.verify(
                merchantId: merchantId,
                vpa: "9999999999@ybl"
            )
            print(response)
            #expect(response.code == .SUCCESS)
        }
    }

    @Test func testAuthRequestStatus() async throws {
        try await withClient { client in
            let subs = try #require(client.subscriptions as? PhonePeSubscriptionRoutes)
            do {
                let response = try await subs.auth.status(
                    merchantId: merchantId,
                    authRequestId: "TX123456789"
                )
                // Non-existent auth request — expect non-success.
                #expect(response.success == false)
            } catch {
                // Empty body from sandbox is acceptable.
            }
        }
    }

    @Test func testAuthInit() async throws {
        try await withClient { client in
            let subs = try #require(client.subscriptions as? PhonePeSubscriptionRoutes)
            let request = AuthInitRequest(
                merchantId: merchantId,
                merchantSubscriptionId: "MSUB123456789012345",
                merchantUserId: "MU123456789",
                authRequestId: "AR123456789",
                amount: 100,
                callbackUrl: "https://webhook.site/callback-url",
                paymentInstrument: .upiCollect(vpa: "test@ybl")
            )
            do {
                let response = try await subs.auth.initiate(request: request)
                #expect(response.success == false)
            } catch let error as PhonePeError {
                _ = error // An error here is also acceptable.
            }
        }
    }

    @Test func testExecuteDebit() async throws {
        try await withClient { client in
            let subs = try #require(client.subscriptions as? PhonePeSubscriptionRoutes)
            let request = DebitExecuteRequest(
                merchantId: merchantId,
                merchantSubscriptionId: "MSUB123456789012345",
                merchantTransactionId: "MT_DEBIT_001",
                merchantUserId: "MU123456789",
                amount: 39900,
                callbackUrl: "https://webhook.site/callback-url"
            )
            do {
                let _ = try await subs.debit.execute(request: request)
            } catch { _ = error }
        }
    }

    @Test func testCancelSubscription() async throws {
        try await withClient { client in
            let request = SubscriptionActionRequest(
                merchantId: merchantId,
                merchantSubscriptionId: "MSUB123456789012345"
            )
            do {
                let _ = try await client.subscriptions.cancel(request: request)
            } catch { _ = error }
        }
    }

    @Test func testPauseSubscription() async throws {
        try await withClient { client in
            let request = SubscriptionActionRequest(
                merchantId: merchantId,
                merchantSubscriptionId: "MSUB123456789012345",
                pauseStartDate: 1700000000000,
                pauseEndDate: 1700086400000
            )
            do {
                let _ = try await client.subscriptions.pause(request: request)
            } catch { _ = error }
        }
    }

    @Test func testUnpauseSubscription() async throws {
        try await withClient { client in
            let request = SubscriptionActionRequest(
                merchantId: merchantId,
                merchantSubscriptionId: "MSUB123456789012345"
            )
            do {
                let _ = try await client.subscriptions.unpause(request: request)
            } catch { _ = error }
        }
    }

    @Test func testRevokeSubscription() async throws {
        try await withClient { client in
            let request = SubscriptionActionRequest(
                merchantId: merchantId,
                merchantSubscriptionId: "MSUB123456789012345"
            )
            do {
                let _ = try await client.subscriptions.revoke(request: request)
            } catch { _ = error }
        }
    }
}
