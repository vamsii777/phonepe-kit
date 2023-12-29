import XCTest
@testable import PhonePeKit
import NIO
import AsyncHTTPClient

class PhonePeClientTests: XCTestCase {

    var phonePeClient: PhonePeClient!

    override func setUp() {
        super.setUp()
        let httpClient = HTTPClient(eventLoopGroupProvider: .singleton)
        let saltKey = "14fa5465-f8a7-443f-8477-f986b8fcfde9"
        let saltIndex = "1"
        
        phonePeClient = PhonePeClient(httpClient: httpClient, saltKey: saltKey, saltIndex: saltIndex, environment: .sandbox)
    }

    func testCreateSubscription() async throws {
        // Creating a sample CreateUserSubscriptionRequest
        let request = CreateUserSubscriptionRequest(
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

        // Perform the request
        let response = try await phonePeClient.subscriptions.createSubscription(request: request)
        
        // Validate the response
        XCTAssertNotNil(response)
        // Add more assertions based on expected response
    }
}
