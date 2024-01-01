//
//  AllSubscriptionsResponse.swift
//
//
//  Created by Vamsi Madduluri on 01/01/24.
//

import Foundation

public struct AllSubscriptionsResponse: Codable {
    var subscription: [Subscription]
    
    struct Subscription: Codable {
        var merchantSubscriptionId: String
        var subscriptionId: String
        var state: SubscriptionState
        var expiredAt: String?
        var validUpto: String?
        
        enum CodingKeys: String, CodingKey {
            case merchantSubscriptionId, subscriptionId, state, expiredAt, validUpto
        }
        
    }
    
    enum SubscriptionState: String, Codable {
        case created = "CREATED"
        case active = "ACTIVE"
        case suspended = "SUSPENDED"
        case revoked = "REVOKED"
        case cancelled = "CANCELLED"
        case paused = "PAUSED"
        case expired = "EXPIRED"
        case failed = "FAILED"
        case cancelInProgress = "CANCEL_IN_PROGRESS"
    }
    
}
