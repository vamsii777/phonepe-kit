//
//  SubscriptionActionResponse.swift
//

import Foundation

public struct SubscriptionActionResponse: Codable {
    public let merchantId: String?
    public let merchantSubscriptionId: String?
    public let subscriptionId: String?
    public let state: String?
}
