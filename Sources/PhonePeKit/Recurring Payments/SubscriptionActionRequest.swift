//
//  SubscriptionActionRequest.swift
//

import Foundation

public struct SubscriptionActionRequest: Codable {
    public let merchantId: String
    public let merchantSubscriptionId: String
    public let pauseStartDate: Int64?   // epoch-ms, pause only
    public let pauseEndDate: Int64?     // epoch-ms, pause only

    public init(merchantId: String,
                merchantSubscriptionId: String,
                pauseStartDate: Int64? = nil,
                pauseEndDate: Int64? = nil) {
        self.merchantId = merchantId
        self.merchantSubscriptionId = merchantSubscriptionId
        self.pauseStartDate = pauseStartDate
        self.pauseEndDate = pauseEndDate
    }
}
