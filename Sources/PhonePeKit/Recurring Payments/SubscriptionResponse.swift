//
//  SubscriptionResponse.swift
//
//
//  Created by Vamsi Madduluri on 29/12/23.
//
import Foundation

public struct SubscriptionResponse: Codable {
    public let subscriptionId: String
    public let state: String
    public let validUpto: String
    public let isSupportedApp: Bool
    public let isSupportedUser: Bool
}
