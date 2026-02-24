//
//  DebitInitRequest.swift
//

import Foundation

/// Request model for the debit init (pre-debit notification) API.
/// Must be called 24–48 hours before `debit.execute` to notify the bank.
public struct DebitInitRequest: Codable {
    public let merchantId: String
    public let merchantSubscriptionId: String
    public let merchantTransactionId: String
    public let merchantUserId: String
    public let amount: Int64
    public let callbackUrl: String
    /// If `true`, PhonePe auto-executes the debit after the 24-hour window.
    /// If `false` (default), the merchant must call `debit.execute` manually.
    public let autoDebit: Bool
    public let subMerchantId: String?

    public init(merchantId: String,
                merchantSubscriptionId: String,
                merchantTransactionId: String,
                merchantUserId: String,
                amount: Int64,
                callbackUrl: String,
                autoDebit: Bool = false,
                subMerchantId: String? = nil) {
        self.merchantId = merchantId
        self.merchantSubscriptionId = merchantSubscriptionId
        self.merchantTransactionId = merchantTransactionId
        self.merchantUserId = merchantUserId
        self.amount = amount
        self.callbackUrl = callbackUrl
        self.autoDebit = autoDebit
        self.subMerchantId = subMerchantId
    }
}
