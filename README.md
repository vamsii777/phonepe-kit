# PhonePeKit

[![CI](https://github.com/vamsii777/phonepe-kit/actions/workflows/ci.yml/badge.svg)](https://github.com/vamsii777/phonepe-kit/actions/workflows/ci.yml)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fvamsii777%2Fphonepe-kit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/vamsii777/phonepe-kit)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fvamsii777%2Fphonepe-kit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/vamsii777/phonepe-kit)

A Swift package for integrating the [PhonePe](https://phonepe.com) Payment Gateway into server-side Swift applications.

Supports both the current **v2 OAuth2 API** and the legacy v1 HMAC API. New integrations should use v2.

PhonePeKit is inspired by [StripeKit](https://github.com/vapor-community/stripe-kit/).

---

## Installation

Add the dependency to your `Package.swift`:

```swift
.package(url: "https://github.com/vamsii777/phonepe-kit.git", from: "main")
```

And add `"PhonePeKit"` to your target's dependencies.

---

## V2 API (Current)

PhonePe v2 authenticates using OAuth2 Bearer tokens. The client manages token acquisition and refresh automatically.

### Setup

```swift
import AsyncHTTPClient
import PhonePeKit

let httpClient = HTTPClient(eventLoopGroupProvider: .singleton)

let client = PhonePeClient(
    httpClient: httpClient,
    credential: .v2(
        clientId: "YOUR_CLIENT_ID",
        clientSecret: "YOUR_CLIENT_SECRET",
        clientVersion: "1"
    ),
    environment: .sandbox
)
```

> **Credentials**: Obtain `clientId`, `clientSecret`, and `clientVersion` from the [PhonePe Business Dashboard](https://business.phonepe.com).

---

### Payments

#### Initiate a payment

```swift
let request = V2PayRequest(
    merchantOrderId: "ORDER_20240101_001",
    amount: 10000, // ₹100.00 in paise
    paymentFlow: .init(redirectUrl: "https://example.com/return")
)

let response = try await client.payments.initiate(request: request)
// Redirect the user to response.redirectUrl
```

#### Check order status

```swift
let status = try await client.status.transaction(merchantOrderId: "ORDER_20240101_001")
// status.state: "PENDING" | "COMPLETED" | "FAILED"
```

#### Refunds

```swift
// Initiate a refund
let refund = try await client.payments.refund.initiate(request: V2RefundRequest(
    merchantRefundId: "REFUND_001",
    merchantOrderId: "ORDER_20240101_001",
    amount: 10000
))

// Poll refund status
let refundStatus = try await client.payments.refund.status(merchantRefundId: "REFUND_001")
```

---

### Recurring Payments (Autopay)

V2 subscriptions use a simplified lifecycle — no separate auth-request step.

#### 1. Create a subscription mandate

```swift
let setup = try await client.subscriptions.create(request:
    V2SubscriptionSetupRequest(
        merchantOrderId: "SETUP_ORDER_001",
        amount: 100,              // setup fee in paise (can be 0 for penny-drop)
        paymentFlow: .init(
            merchantSubscriptionId: "SUB_001",
            authWorkflowType: "PENNY_DROP",
            amountType: "FIXED",
            maxAmount: 39900,     // ₹399.00 max debit per cycle
            frequency: "MONTHLY"
        )
    )
)
// Redirect user to setup.intentUrl for mandate authorisation
```

#### 2. Confirm subscription is active

```swift
let subStatus = try await client.subscriptions.user.status(merchantSubscriptionId: "SUB_001")
// subStatus.state: "ACTIVE" | "PENDING" | "CANCELLED" | ...

// Or check the setup order itself
let orderStatus = try await client.subscriptions.user.orderStatus(merchantOrderId: "SETUP_ORDER_001")
```

#### 3. Notify upcoming debit (24–48 h before)

```swift
let notify = try await client.subscriptions.debit.notify(request:
    V2NotifyRequest(
        merchantOrderId: "DEBIT_ORDER_001",
        amount: 39900,
        paymentFlow: .init(merchantSubscriptionId: "SUB_001")
    )
)
```

#### 4. Execute the debit

Required only when `autoDebit` is `false` in the notify request. If `autoDebit` is `true`, PhonePe executes it automatically after the notify call.

```swift
let result = try await client.subscriptions.debit.execute(
    request: V2RedeemRequest(merchantOrderId: "DEBIT_ORDER_001")
)
```

#### Lifecycle management

```swift
try await client.subscriptions.cancel(merchantSubscriptionId: "SUB_001")
try await client.subscriptions.pause(merchantSubscriptionId: "SUB_001")
try await client.subscriptions.unpause(merchantSubscriptionId: "SUB_001")
try await client.subscriptions.revoke(merchantSubscriptionId: "SUB_001")
```

---

## V1 API (Legacy)

> **Note**: V1 is supported for existing integrations. Migrate to v2 for new work.

V1 uses HMAC-SHA256 signatures via a `saltKey` and `saltIndex`.

### Setup

```swift
let client = PhonePeClient(
    httpClient: httpClient,
    credential: .v1(saltKey: "YOUR_SALT_KEY", saltIndex: "1"),
    environment: .sandbox
)
```

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
let response = try await client.payments.initiate(request: request)
```

### Check status

```swift
let status = try await client.status.transaction(
    merchantId: "MERCHANTID",
    merchantTransactionId: "MT1234567890"
)
```

### Refunds

```swift
let refund = try await client.payments.refund.initiate(request: RefundRequest(
    merchantId: "MERCHANTID",
    merchantUserId: "MU123",
    originalTransactionId: "MT1234567890",
    merchantTransactionId: "REFUND1234567890",
    amount: 10000,
    callbackUrl: "https://example.com/callback"
))
```

### Recurring Payments

```swift
// 1. Create a subscription
let subscription = try await client.subscriptions.create(request: SubscriptionRequest(
    merchantId: "MERCHANTID",
    merchantSubscriptionId: "MSUB123456789",
    merchantUserId: "MU123",
    authWorkflowType: .pennyDrop,
    amountType: .fixed,
    amount: 39900,
    frequency: .monthly,
    recurringCount: 12
))

// 2. Initiate auth request
let auth = try await client.subscriptions.auth.initiate(request: AuthInitRequest(
    merchantId: "MERCHANTID",
    merchantSubscriptionId: "MSUB123456789",
    merchantUserId: "MU123",
    authRequestId: "AR123",
    paymentInstrument: .upiCollect(vpa: "user@upi")
))

// 3. Notify bank 24–48 h before debit
let notify = try await client.subscriptions.debit.initiate(request: DebitInitRequest(
    merchantId: "MERCHANTID",
    merchantSubscriptionId: "MSUB123456789",
    merchantTransactionId: "MT_DEBIT_001",
    merchantUserId: "MU123",
    amount: 39900,
    callbackUrl: "https://example.com/callback"
))

// 4. Execute debit
let debit = try await client.subscriptions.debit.execute(request: DebitExecuteRequest(
    merchantId: "MERCHANTID",
    merchantSubscriptionId: "MSUB123456789",
    merchantTransactionId: "MT_DEBIT_001",
    merchantUserId: "MU123",
    amount: 39900,
    callbackUrl: "https://example.com/callback"
))
```

---

## What's Implemented

### PG Checkout — V2

| Method | Description |
|--------|-------------|
| `payments.initiate(request: V2PayRequest)` | Initiate a checkout payment |
| `payments.refund.initiate(request:)` | Initiate a full or partial refund |
| `payments.refund.status(merchantRefundId:)` | Check refund status |
| `status.transaction(merchantOrderId:)` | Check order status |
| `status.health(merchantId:)` | Check PhonePe gateway health |

### Recurring Payments — V2

| Method | Description |
|--------|-------------|
| `subscriptions.create(request: V2SubscriptionSetupRequest)` | Set up a mandate, get `intentUrl` |
| `subscriptions.user.status(merchantSubscriptionId:)` | Get mandate lifecycle status |
| `subscriptions.user.orderStatus(merchantOrderId:)` | Get setup-order status |
| `subscriptions.debit.notify(request:)` | Notify upcoming debit (call 24–48 h before) |
| `subscriptions.debit.execute(request:)` | Execute debit (when `autoDebit` is false) |
| `subscriptions.cancel(merchantSubscriptionId:)` | Cancel a mandate (permanent) |
| `subscriptions.pause(merchantSubscriptionId:)` | Pause a mandate |
| `subscriptions.unpause(merchantSubscriptionId:)` | Resume a paused mandate |
| `subscriptions.revoke(merchantSubscriptionId:)` | Revoke a mandate (merchant-initiated) |

### PG Checkout — V1 (Legacy)

| Method | Description |
|--------|-------------|
| `payments.initiate(request: PayRequest)` | Initiate a payment |
| `payments.refund.initiate(request:)` | Initiate a refund |
| `status.transaction(merchantId:merchantTransactionId:)` | Check payment or refund status |
| `status.health(merchantId:)` | Check PhonePe service health |
| `validate.vpa(request:)` | Validate a VPA |
| `options.payment(merchantId:)` | Fetch available payment options |

### Recurring Payments — V1 (Legacy)

| Method | Description |
|--------|-------------|
| `subscriptions.create(request: SubscriptionRequest)` | Create a subscription |
| `subscriptions.user.status(merchantId:merchantSubscriptionId:)` | Get subscription status |
| `subscriptions.fetch.all(merchantId:merchantUserId:)` | Fetch all subscriptions for a user |
| `subscriptions.vpa.verify(merchantId:vpa:)` | Verify a VPA for recurring payments |
| `subscriptions.auth.initiate(request:)` | Submit an auth request |
| `subscriptions.auth.status(merchantId:authRequestId:)` | Check auth request status |
| `subscriptions.debit.initiate(request:)` | Notify bank before debit |
| `subscriptions.debit.execute(request:)` | Execute a recurring debit |
| `subscriptions.cancel(request:)` | Cancel a subscription |
| `subscriptions.pause(request:)` | Pause a subscription |
| `subscriptions.unpause(request:)` | Unpause a subscription |
| `subscriptions.revoke(request:)` | Revoke a subscription |

---

## License

PhonePeKit is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
