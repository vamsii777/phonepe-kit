# PhonePeKit

![](https://img.shields.io/badge/Swift-5.9-lightgrey.svg?style=svg)
![](https://img.shields.io/badge/SwiftNio-2-lightgrey.svg?style=svg)

### PhonePeKit is a Swift package used to communicate with the [PhonePe](https://phonepe.com) API for Server Side Swift Apps.

PhonePeKit is heavily inspired by [StripeKit](https://github.com/vapor-community/stripe-kit/), a project developed by @andrewangeta. We deeply appreciate the framework and design principles laid out in Stripe-Kit, which have guided the development of PhonePeKit for the Swift ecosystem.

## Installation

To start using PhonePeKit, in your `Package.swift`, add the following

```swift
.package(url: "https://github.com/vamsii777/phonepe-kit.git", from: "main")
```

---

## Using the API

Initialize the `PhonePeClient`

```swift
let httpClient = HTTPClient(..)

let saltKey = "14fa5465-f8a7-443f-8477-f986b8fcfde9"
let saltIndex = "1"
   
let phonePe = PhonePeClient(httpClient: httpClient, saltKey: saltKey, saltIndex: saltIndex, environment: .sandbox)
```

And now you have access to the APIs via `phonePe`.

The APIs you have available correspond to what's implemented.

For example, to use the `Recurring Payments` API, the PhonePeClient has a property to access that API via routes.

```swift
do {
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

    let subscriptions = try await phonePeClient.subscriptions.createSubscription(request: request)
    
    if subscriptions.status == .succeeded {
        print("New swift servers are on the way 🚀")
    } else {
        print("Sorry you have to use Node.js 🤢")
    }
} catch {
    // Handle error
}
```

---

## What's Implemented

### PG Standard Checkout API

- [x] PAY 
- [x] Check Status 
- [ ] Refund (⚠️ In Progress)

### PG Custom Checkout API

- [ ] PAY
- [ ] Check Status
- [ ] Refund

### Others

- [ ] VPA Validate (⚠️ In Progress)
- [ ] Payment Options (⚠️ In Progress)
- [ ] Health Status (⚠️ In Progress)

### Recurring Payments

- [x] Create User Subscription
- [ ] User Subscription Status (⚠️ In Progress)
- [ ] Fetch All Subscriptions
- [ ] Verify VPA
- [ ] Submit Auth Request
- [ ] Auth Request Status
- [ ] Recurring INIT
- [ ] Recurring Debit Execute
- [ ] Recurring Debit Execute Status
- [ ] Cancel Subscription
- [ ] Revoke Subscription
- [ ] Pause/UnPause Subscription
- [ ] Cancel Subscription
- [ ] Revoke Subscription

## License
PhonePeKit is available under the MIT license. See the [LICENSE](LICENSE) file for more info.