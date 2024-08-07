# PhonePeKit

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fvamsii777%2Fphonepe-kit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/vamsii777/phonepe-kit)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fvamsii777%2Fphonepe-kit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/vamsii777/phonepe-kit)

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
- [x] Refund

### PG Custom Checkout API

- [ ] PAY (🚧 Under Development)
- [ ] Check Status (🚧 Under Development)
- [ ] Refund (🚧 Under Development)

### Others

- [x] VPA Validate
- [x] Payment Options
- [x] Health Status

### Recurring Payments

- [x] Create User Subscription
- [x] User Subscription Status
- [x] Fetch All Subscriptions
- [x] Verify VPA 
- [ ] Submit Auth Request (🚧 Under Development)
- [ ] Auth Request Status (🚧 Under Development)
- [ ] Recurring INIT (🚧 Under Development)
- [ ] Recurring Debit Execute (🚧 Under Development)
- [ ] Recurring Debit Execute Status (🚧 Under Development)
- [ ] Cancel Subscription (🚧 Under Development)
- [ ] Revoke Subscription (🚧 Under Development)
- [ ] Pause/UnPause Subscription (🚧 Under Development)
- [ ] Cancel Subscription (🚧 Under Development)
- [ ] Revoke Subscription (🚧 Under Development)

## License
PhonePeKit is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
