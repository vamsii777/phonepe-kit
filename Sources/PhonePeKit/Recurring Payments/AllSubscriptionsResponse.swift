//
//  AllSubscriptionsResponse.swift
//
//
//  Created by Vamsi Madduluri on 01/01/24.
//

import Foundation

public struct AllSubscriptionsResponse: Codable {
    public let subscription: [Subscription]

    public struct Subscription: Codable {
        public let merchantSubscriptionId: String
        public let subscriptionId: String
        public let state: SubscriptionState
        public let expiredAt: String?
        public let validUpto: String?
    }

    public enum SubscriptionState: String, Codable {
        case created = "CREATED"
        case active = "ACTIVE"
        case suspended = "SUSPENDED"
        case revoked = "REVOKED"
        case cancelled = "CANCELLED"
        case paused = "PAUSED"
        case expired = "EXPIRED"
        case failed = "FAILED"
        case activationInProgress = "ACTIVATION_IN_PROGRESS"
        case cancelInProgress = "CANCEL_IN_PROGRESS"
        case revokeInProgress = "REVOKE_IN_PROGRESS"
        case pauseInProgress = "PAUSE_IN_PROGRESS"
        case unpauseInProgress = "UNPAUSE_IN_PROGRESS"
    }
}
