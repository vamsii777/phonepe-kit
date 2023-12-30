//
//  SubscriptionResponse.swift
//
//
//  Created by Vamsi Madduluri on 29/12/23.
//
import Foundation

public struct SubscriptionResponse: Codable {
    var subscriptionId: String
    var state: String
    var validUpto: String
    var isSupportedApp: Bool
    var isSupportedUser: Bool
}
