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
    
    func createClient(saltKey: String) -> PhonePeClient {
        return PhonePeClient(httpClient: httpClient, saltKey: saltKey, saltIndex: "1", environment: .sandbox)
    }
    
    func testInitiatePayment() async throws {
        let phonePeClient = createClient(saltKey: "099eb0cd-02cf-4e2a-8aca-3e6c6aff0399")
        let request = PayRequest(
            merchantId: "PGTESTPAYUAT",
            merchantTransactionId: "MT7850590068188104",
            amount: 10000, merchantUserId: "MUID123",
            redirectUrl: "https://webhook.site/redirect-url",
            redirectMode: .POST,
            callbackUrl: "https://webhook.site/callback-url",
            paymentInstrument: PayRequest.PaymentInstrument(type: .PAY_PAGE),
            mobileNumber: "9999999999"
        )
        let response = try await phonePeClient.payments.initiatePayment(request: request)
        XCTAssertNotNil(response)
        XCTAssertEqual(response.success, true)
        XCTAssertEqual(response.code, "PAYMENT_INITIATED")
    }
    
    func testInitiatePaymentRedirect() async throws {
        let phonePeClient = createClient(saltKey: "099eb0cd-02cf-4e2a-8aca-3e6c6aff0399")
        let request = PayRequest(
            merchantId: "PGTESTPAYUAT",
            merchantTransactionId: "MT7850590068188104",
            amount: 10000, merchantUserId: "MUID123",
            redirectUrl: "https://webhook.site/redirect-url",
            redirectMode: .REDIRECT,
            callbackUrl: "https://webhook.site/callback-url",
            paymentInstrument: PayRequest.PaymentInstrument(type: .PAY_PAGE),
            mobileNumber: "9999999999"
        )
        let response = try await phonePeClient.payments.initiatePayment(request: request)
        XCTAssertNotNil(response)
        XCTAssertEqual(response.success, true)
        XCTAssertEqual(response.code, "PAYMENT_INITIATED")
    }
    
    func testCheckTransactionStatus() async throws {
        let phonePeClient = createClient(saltKey: "099eb0cd-02cf-4e2a-8aca-3e6c6aff0399")
        
        // Use sample merchantId and merchantTransactionId for testing
        let merchantId = "PGTESTPAYUAT"
        let merchantTransactionId = "7qfRVFLbjL8Le8vMKAUieq"
        
        let response = try await phonePeClient.checkstatus.checkTransactionStatus(merchantId: merchantId, merchantTransactionId: merchantTransactionId)
        XCTAssertNotNil(response)
        XCTAssertEqual(response.code, "PAYMENT_SUCCESS")
        // Further assertions based on expected response
    }
    
    func test401Request() async throws {
        let phonePeClient = createClient(saltKey: "14fa5465-f8a7-443f-8477-f986b8fcfde9")
        let request = PayRequest(
            merchantId: "PGTESTPAYUAT",
            merchantTransactionId: "MT7850590068188104",
            amount: 10000, merchantUserId: "MUID123",
            redirectUrl: "https://webhook.site/redirect-url",
            redirectMode: .POST,
            callbackUrl: "https://webhook.site/callback-url",
            paymentInstrument: PayRequest.PaymentInstrument(type: .PAY_PAGE),
            mobileNumber: "9999"
        )
        let response = try await phonePeClient.payments.initiatePayment(request: request)
        XCTAssertNotNil(response)
        XCTAssertEqual(response.code, "401")
    }
    
    func testCreateSubscription() async throws {
        let phonePeClient = createClient(saltKey: "14fa5465-f8a7-443f-8477-f986b8fcfde9")
        let request = SubscriptionRequest(
            merchantId: "PGTESTPAYUAT77",
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
        let response = try await phonePeClient.subscriptions.createSubscription(request: request)
        XCTAssertNotNil(response)
        XCTAssertEqual(response.success, true)
        XCTAssertNotNil(response)
    }
}
