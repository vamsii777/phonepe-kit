//
//  UserSubscriptionStatusResponse.swift
//
//
//  Created by Vamsi Madduluri on 31/12/23.
//

import Foundation

public struct UserSubscriptionStatusResponse: Codable {
    public let subscriptionId: String
    public let state: String
    public let startDate: Date?
    public let endDate: Date?
    public let validUpto: Date?
    public let isSupportedApp: Bool?
    public let isSupportedUser: Bool?

    enum CodingKeys: String, CodingKey {
        case subscriptionId
        case state
        case startDate = "stateStartDate"
        case endDate = "stateEndDate"
        case validUpto = "validUpto"
        case isSupportedApp
        case isSupportedUser
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        subscriptionId = try container.decode(String.self, forKey: .subscriptionId)
        state = try container.decode(String.self, forKey: .state)

        if let epoch = try container.decodeIfPresent(Double.self, forKey: .startDate) {
            startDate = Date(timeIntervalSince1970: epoch / 1000)
        } else {
            startDate = nil
        }

        if let epoch = try container.decodeIfPresent(Double.self, forKey: .endDate) {
            endDate = Date(timeIntervalSince1970: epoch / 1000)
        } else {
            endDate = nil
        }

        // Fixed: was incorrectly decoding from .endDate instead of .validUpto
        if let epoch = try container.decodeIfPresent(Double.self, forKey: .validUpto) {
            validUpto = Date(timeIntervalSince1970: epoch / 1000)
        } else {
            validUpto = nil
        }

        isSupportedApp = try container.decodeIfPresent(Bool.self, forKey: .isSupportedApp)
        isSupportedUser = try container.decodeIfPresent(Bool.self, forKey: .isSupportedUser)
    }
}
