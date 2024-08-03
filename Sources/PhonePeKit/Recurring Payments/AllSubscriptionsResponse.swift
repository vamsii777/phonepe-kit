//
//  AllSubscriptionsResponse.swift
//
//
//  Created by Vamsi Madduluri on 01/01/24.
//

import Foundation

/// Represents the response structure for retrieving all subscriptions.
public struct AllSubscriptionsResponse: Codable {
    /// An array of `Subscription` objects.
    var subscription: [Subscription]
    
    /// Represents a single subscription.
    struct Subscription: Codable {
        /// The merchant subscription ID.
        var merchantSubscriptionId: String
        /// The subscription ID.
        var subscriptionId: String
        /// The state of the subscription.
        var state: SubscriptionState
        /// The expiration date of the subscription.
        var expiredAt: String?
        /// The validity period of the subscription.
        var validUpto: String?
        
        /// Coding keys for encoding and decoding.
        enum CodingKeys: String, CodingKey {
            case merchantSubscriptionId, subscriptionId, state, expiredAt, validUpto
        }
        
    }
    
    /// Represents the possible states of a subscription.
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
