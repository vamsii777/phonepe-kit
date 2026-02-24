//
//  RefundRequest.swift
//
//
//  Created by Vamsi Madduluri on 31/12/23.
//

import Foundation

public struct RefundRequest: Codable {
    public let merchantId: String
    public let merchantUserId: String
    public let originalTransactionId: String
    public let merchantTransactionId: String
    public let amount: Int64
    public let callbackUrl: String

    public init(merchantId: String,
                merchantUserId: String,
                originalTransactionId: String,
                merchantTransactionId: String,
                amount: Int64,
                callbackUrl: String) {
        self.merchantId = merchantId
        self.merchantUserId = merchantUserId
        self.originalTransactionId = originalTransactionId
        self.merchantTransactionId = merchantTransactionId
        self.amount = amount
        self.callbackUrl = callbackUrl
    }
}
