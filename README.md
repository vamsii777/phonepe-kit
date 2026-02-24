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

### Payments

```swift
let request = PayRequest(
    merchantId: "MERCHANTID",
    merchantTransactionId: "MT1234567890",
    amount: 10000,
    merchantUserId: "MU123",
    redirectUrl: "https://example.com/redirect",
    redirectMode: .POST,
    callbackUrl: "https://example.com/callback",
    paymentInstrument: .payPage
)

let response = try await phonePe.payments.initiate(request: request)
```

### Refunds

```swift
let request = RefundRequest(
    merchantId: "MERCHANTID",
    merchantUserId: "MU123",
    originalTransactionId: "MT1234567890",
    merchantTransactionId: "REFUND1234567890",
    amount: 10000,
    callbackUrl: "https://example.com/callback"
)

let response = try await phonePe.payments.refund.initiate(request: request)
```

### Check Transaction Status

```swift
// Works for both payment and refund transactions
let response = try await phonePe.status.transaction(merchantId: "MERCHANTID", merchantTransactionId: "MT1234567890")
```

### Recurring Payments

```swift
// 1. Create a subscription
let request = SubscriptionRequest(
    merchantId: "MERCHANTID",
    merchantSubscriptionId: "MSUB123456789",
    merchantUserId: "MU123",
    authWorkflowType: .pennyDrop,
    amountType: .fixed,
    amount: 39900,
    frequency: .monthly,
    recurringCount: 12
)
let subscription = try await phonePe.subscriptions.create(request: request)

// 2. Initiate auth request
let authRequest = AuthInitRequest(
    merchantId: "MERCHANTID",
    merchantSubscriptionId: "MSUB123456789",
    merchantUserId: "MU123",
    authRequestId: "AR123",
    paymentInstrument: .upiCollect(vpa: "user@upi")
)
let auth = try await phonePe.subscriptions.auth.initiate(request: authRequest)

// 3. Notify bank 24–48h before debit
let debitInitRequest = DebitInitRequest(
    merchantId: "MERCHANTID",
    merchantSubscriptionId: "MSUB123456789",
    merchantTransactionId: "MT_DEBIT_001",
    merchantUserId: "MU123",
    amount: 39900,
    callbackUrl: "https://example.com/callback"
)
let notify = try await phonePe.subscriptions.debit.initiate(request: debitInitRequest)

// 4. Execute debit
let debitRequest = DebitExecuteRequest(
    merchantId: "MERCHANTID",
    merchantSubscriptionId: "MSUB123456789",
    merchantTransactionId: "MT_DEBIT_001",
    merchantUserId: "MU123",
    amount: 39900,
    callbackUrl: "https://example.com/callback"
)
let debit = try await phonePe.subscriptions.debit.execute(request: debitRequest)
```

---

## What's Implemented

### PG Checkout API

| Method | Description |
|--------|-------------|
| `payments.initiate(request:)` | Initiate a payment (PAY_PAGE, UPI, Net Banking, Card, Token) |
| `payments.refund.initiate(request:)` | Initiate a refund |
| `status.transaction(merchantId:merchantTransactionId:)` | Check payment or refund status |
| `status.health(merchantId:)` | Check PhonePe service health |
| `validate.vpa(request:)` | Validate a VPA |
| `options.payment(merchantId:)` | Fetch available payment options |

### Recurring Payments API

| Method | Description |
|--------|-------------|
| `subscriptions.create(request:)` | Create a subscription |
| `subscriptions.user.status(merchantId:merchantSubscriptionId:)` | Get subscription status for a user |
| `subscriptions.fetch.all(merchantId:merchantUserId:)` | Fetch all subscriptions for a user |
| `subscriptions.vpa.verify(merchantId:vpa:)` | Verify a VPA for recurring payments |
| `subscriptions.auth.initiate(request:)` | Submit an auth request |
| `subscriptions.auth.status(merchantId:authRequestId:)` | Check auth request status |
| `subscriptions.debit.initiate(request:)` | Notify bank before debit (call 24–48h before execute) |
| `subscriptions.debit.execute(request:)` | Execute a recurring debit |
| `subscriptions.cancel(request:)` | Cancel a subscription |
| `subscriptions.pause(request:)` | Pause a subscription |
| `subscriptions.unpause(request:)` | Unpause a subscription |
| `subscriptions.revoke(request:)` | Revoke a subscription |

## License
PhonePeKit is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
