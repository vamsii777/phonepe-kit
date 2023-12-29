//
//  CreateUserSubscriptionResponse.swift
//
//
//  Created by Vamsi Madduluri on 29/12/23.
//
import Foundation

public struct CreateUserSubscriptionResponse: Codable {
    var success: Bool
    var code: String
    var message: String
    var data: SubscriptionData
}

public struct SubscriptionData: Codable {
    var subscriptionId: String
    var state: String
    var validUpto: String
    var isSupportedApp: Bool
    var isSupportedUser: Bool
}
