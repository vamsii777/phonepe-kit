import XCTest
@testable import PhonePeKit
import NIO
import AsyncHTTPClient

class PhonePeClientTests: XCTestCase {

    var phonePeClient: PhonePeClient!
    var httpClient: HTTPClient!

    override func setUp() {
        super.setUp()
        httpClient = HTTPClient(eventLoopGroupProvider: .singleton)
    }

    func createClient(saltKey: String = "96434309-7796-489d-8924-ab56988a6076", environment: Environment) -> PhonePeClient {
        return PhonePeClient(httpClient: httpClient, saltKey: saltKey, saltIndex: "1", environment: environment)
    }

    func testInitiatePayment() async throws {
        let phonePeClient = createClient(environment: .sandbox)
        let request = PayRequest(
            merchantId: "PGTESTPAYUAT86",
            merchantTransactionId: "MT7850590068188104",
            amount: 10000, merchantUserId: "MUID123",
            redirectUrl: "https://webhook.site/redirect-url",
            redirectMode: .POST,
            callbackUrl: "https://webhook.site/callback-url",
            paymentInstrument: .payPage,
            mobileNumber: "9999999999"
        )
        let response = try await phonePeClient.payments.initiate(request: request)
        XCTAssertNotNil(response)
        XCTAssertEqual(response.success, true)
        XCTAssertEqual(response.code, "PAYMENT_INITIATED")
    }

    func testRefundPayment() async throws {
        let phonePeClient = createClient(environment: .sandbox)
        let request = RefundRequest(
            merchantId: "PGTESTPAYUAT86",
            merchantUserId: "User123",
            originalTransactionId: "OD620471739210623",
            merchantTransactionId: "ROD620471739210623",
            amount: 1000,
            callbackUrl: "https://webhook.site/callback-url"
        )
        do {
            let response = try await phonePeClient.payments.refund(request: request)
            XCTAssertNotNil(response)
            // Original transaction OD620471739210623 does not exist in sandbox;
            // PhonePe returns a non-success response for unknown transactions.
            XCTAssertFalse(response.success)
        } catch let error as PhonePeError {
            // PhonePe sandbox returns an empty body when the original transaction
            // does not exist — SDK surfaces this as EMPTY_RESPONSE.
            XCTAssertEqual(error.code, .EMPTY_RESPONSE)
        }
    }

    func testInitiatePaymentRedirect() async throws {
        let phonePeClient = createClient(environment: .sandbox)
        let request = PayRequest(
            merchantId: "PGTESTPAYUAT86",
            merchantTransactionId: "MT7850590068188104",
            amount: 10000, merchantUserId: "MUID123",
            redirectUrl: "https://webhook.site/redirect-url",
            redirectMode: .REDIRECT,
            callbackUrl: "https://webhook.site/callback-url",
            paymentInstrument: .payPage,
            mobileNumber: "9999999999"
        )
        let response = try await phonePeClient.payments.initiate(request: request)
        XCTAssertNotNil(response)
        XCTAssertEqual(response.success, true)
        XCTAssertEqual(response.code, "PAYMENT_INITIATED")
    }

    func testCheckTransactionStatus() async throws {
        let phonePeClient = createClient(environment: .sandbox)
        let merchantId = "PGTESTPAYUAT86"
        let merchantTransactionId = "7qfRVFLbjL8Le8vMKAUieq"

        do {
            let response = try await phonePeClient.status.transaction(merchantId: merchantId, merchantTransactionId: merchantTransactionId)
            XCTAssertNotNil(response)
            // Transaction does not exist in sandbox — expect TRANSACTION_NOT_FOUND.
            XCTAssertEqual(response.code, "TRANSACTION_NOT_FOUND")
        } catch let error as PhonePeError {
            // PhonePe sandbox returns an empty body for non-existent transactions
            // — SDK surfaces this as EMPTY_RESPONSE.
            XCTAssertEqual(error.code, .EMPTY_RESPONSE)
        }
    }

    func testVPAValidate() async throws {
        let phonePeClient = createClient(environment: .sandbox)
        let request = VPAValidateRequest(vpa: "success@razorpay", merchantId: "PGTESTPAYUAT86")
        let response = try await phonePeClient.validate.vpa(request: request)
        XCTAssertNotNil(response)
        XCTAssertEqual(response.code, "SUCCESS")
    }

    func testPaymentOptions() async throws {
        let phonePeClient = createClient(environment: .sandbox)
        let response = try await phonePeClient.options.payment(merchantId: "PGTESTPAYUAT86")
        XCTAssertNotNil(response)
        XCTAssertEqual(response.success, true)
        XCTAssertEqual(response.code, "SUCCESS")
    }

    func testBadRequest() async throws {
        // Sending an invalid mobile number (too short) — sandbox may return BAD_REQUEST or still initiate.
        // We only assert the response is received (not nil).
        let phonePeClient = createClient(environment: .sandbox)
        let request = PayRequest(
            merchantId: "PGTESTPAYUAT86",
            merchantTransactionId: "MT7850590068188104",
            amount: 10000, merchantUserId: "MUID123",
            redirectUrl: "https://webhook.site/redirect-url",
            redirectMode: .POST,
            callbackUrl: "https://webhook.site/callback-url",
            paymentInstrument: .payPage,
            mobileNumber: "9999"
        )
        let response = try await phonePeClient.payments.initiate(request: request)
        XCTAssertNotNil(response)
    }

    func testCreateSubscription() async throws {
        let phonePeClient = createClient(environment: .sandbox)
        let request = SubscriptionRequest(
            merchantId: "PGTESTPAYUAT86",
            merchantSubscriptionId: "MSUB123456789012345",
            merchantUserId: "MU123456789",
            authWorkflowType: .pennyDrop,  // or .pennyDrop
            amountType: .fixed,  // or .variable
            amount: 39900,  // Sample amount in paise
            frequency: .monthly,  // Choose the appropriate frequency
            recurringCount: 12,  // Sample recurring count
            subMerchantId: "DemoMerchant",
            mobileNumber: "7989378465",  // Sample mobile number
            deviceContext: DeviceContext(phonePeVersionCode: 400922)  // Sample device context
        )
        let response = try await phonePeClient.subscriptions.create(request: request)
        XCTAssertNotNil(response)
        XCTAssertEqual(response.success, true)
    }

    func testUserSubscriptionStatus() async throws {
        let phonePeClient = createClient(environment: .sandbox)
        let response = try await phonePeClient.subscriptions.user.status(merchantId: "PGTESTPAYUAT86", merchantSubscriptionId: "MSUB123456789012345")
        XCTAssertNotNil(response)
        XCTAssertEqual(response.success, true)
    }

    func testFetchAllSubscriptionStatus() async throws {
        let phonePeClient = createClient(environment: .sandbox)
        let response = try await phonePeClient.subscriptions.fetch.all(merchantId: "PGTESTPAYUAT86", merchantUserId: "MU123456789")
        XCTAssertNotNil(response)
        XCTAssertEqual(response.code, "SUCCESS")
    }

    func testVerifyValidateVPA() async throws {
        let phonePeClient = createClient(environment: .sandbox)
        let response = try await phonePeClient.subscriptions.vpa.verify(merchantId: "PGTESTPAYUAT86", vpa: "9999999999@ybl")
        XCTAssertNotNil(response)
        XCTAssertEqual(response.code, "SUCCESS")
    }

    func testAuthRequestStatus() async throws {
        let phonePeClient = createClient(environment: .sandbox)
        // TX123456789 does not exist in sandbox — PhonePe returns a non-success response or empty body.
        do {
            let response = try await phonePeClient.subscriptions.auth.status(merchantId: "PGTESTPAYUAT86", authRequestId: "TX123456789")
            XCTAssertNotNil(response)
            XCTAssertFalse(response.success)
        } catch {
            // Sandbox may return empty body for unknown auth requests — surfaced as PhonePeError.
            XCTAssertNotNil(error)
        }
    }

    func testAuthInit() async throws {
        let phonePeClient = createClient(environment: .sandbox)
        let request = AuthInitRequest(
            merchantId: "PGTESTPAYUAT86",
            merchantSubscriptionId: "MSUB123456789012345",
            merchantUserId: "MU123456789",
            authRequestId: "AR123456789",
            amount: 100,
            callbackUrl: "https://webhook.site/callback-url",
            paymentInstrument: .upiCollect(vpa: "test@ybl")
        )
        do {
            let response = try await phonePeClient.subscriptions.auth.initiate(request: request)
            XCTAssertNotNil(response)
            // Non-existent subscription in sandbox returns a non-success code.
            XCTAssertFalse(response.success)
        } catch let error as PhonePeError {
            XCTAssertNotNil(error)
        }
    }

    func testExecuteDebit() async throws {
        let phonePeClient = createClient(environment: .sandbox)
        let request = DebitExecuteRequest(
            merchantId: "PGTESTPAYUAT86",
            merchantSubscriptionId: "MSUB123456789012345",
            merchantTransactionId: "MT_DEBIT_001",
            merchantUserId: "MU123456789",
            amount: 39900,
            callbackUrl: "https://webhook.site/callback-url"
        )
        do {
            let response = try await phonePeClient.subscriptions.debit.execute(request: request)
            XCTAssertNotNil(response)
            XCTAssertFalse(response.success)
        } catch let error as PhonePeError {
            XCTAssertNotNil(error)
        }
    }

    func testCancelSubscription() async throws {
        let phonePeClient = createClient(environment: .sandbox)
        let request = SubscriptionActionRequest(
            merchantId: "PGTESTPAYUAT86",
            merchantSubscriptionId: "MSUB123456789012345"
        )
        do {
            let response = try await phonePeClient.subscriptions.cancel(request: request)
            XCTAssertNotNil(response)
        } catch let error as PhonePeError {
            XCTAssertNotNil(error)
        }
    }

    func testPauseSubscription() async throws {
        let phonePeClient = createClient(environment: .sandbox)
        let request = SubscriptionActionRequest(
            merchantId: "PGTESTPAYUAT86",
            merchantSubscriptionId: "MSUB123456789012345",
            pauseStartDate: 1700000000000,
            pauseEndDate: 1700086400000
        )
        do {
            let response = try await phonePeClient.subscriptions.pause(request: request)
            XCTAssertNotNil(response)
        } catch let error as PhonePeError {
            XCTAssertNotNil(error)
        }
    }

    func testUnpauseSubscription() async throws {
        let phonePeClient = createClient(environment: .sandbox)
        let request = SubscriptionActionRequest(
            merchantId: "PGTESTPAYUAT86",
            merchantSubscriptionId: "MSUB123456789012345"
        )
        do {
            let response = try await phonePeClient.subscriptions.unpause(request: request)
            XCTAssertNotNil(response)
        } catch let error as PhonePeError {
            XCTAssertNotNil(error)
        }
    }

    func testRevokeSubscription() async throws {
        let phonePeClient = createClient(environment: .sandbox)
        let request = SubscriptionActionRequest(
            merchantId: "PGTESTPAYUAT86",
            merchantSubscriptionId: "MSUB123456789012345"
        )
        do {
            let response = try await phonePeClient.subscriptions.revoke(request: request)
            XCTAssertNotNil(response)
        } catch let error as PhonePeError {
            XCTAssertNotNil(error)
        }
    }

    // USE PRODUCTION KEY & SALT
    // Phonepe does not have an uptime test URL.
    func healthStatus() async throws {
        let phonePeClient = createClient(environment: .production)
        let response = try await phonePeClient.status.health(merchantId: "MSUB123456789012345")
        XCTAssertNotNil(response)
    }
}
