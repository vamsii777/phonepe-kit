//
//  DebitExecuteRequest.swift
//

import Foundation

public struct DebitExecuteRequest: Codable {
    public let merchantId: String
    public let merchantSubscriptionId: String
    public let merchantTransactionId: String
    public let merchantUserId: String
    public let amount: Int64
    public let callbackUrl: String
    public let subMerchantId: String?

    public init(merchantId: String,
                merchantSubscriptionId: String,
                merchantTransactionId: String,
                merchantUserId: String,
                amount: Int64,
                callbackUrl: String,
                subMerchantId: String? = nil) {
        self.merchantId = merchantId
        self.merchantSubscriptionId = merchantSubscriptionId
        self.merchantTransactionId = merchantTransactionId
        self.merchantUserId = merchantUserId
        self.amount = amount
        self.callbackUrl = callbackUrl
        self.subMerchantId = subMerchantId
    }
}
