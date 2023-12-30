//
//  UserSubscriptionStatusResponse.swift
//  
//
//  Created by Vamsi Madduluri on 31/12/23.
//

import Foundation

public struct UserSubscriptionStatusResponse: Codable {
    let subscriptionId: String
    let state: String
    let startDate: Date?
    let endDate: Date?
    let validUpto: Date?
    let isSupportedApp: Bool?
    let isSupportedUser: Bool?

    enum CodingKeys: String, CodingKey {
        case subscriptionId
        case state
        case startDate = "stateStartDate"
        case endDate = "stateEndDate"
        case validUpto = "validUpto"
        case isSupportedApp = "isSupportedApp"
        case isSupportedUser = "isSupportedUser"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        subscriptionId = try container.decode(String.self, forKey: .subscriptionId)
        state = try container.decode(String.self, forKey: .state)

        if let startDateEpoch = try container.decodeIfPresent(Double.self, forKey: .startDate) {
            startDate = Date(timeIntervalSince1970: startDateEpoch / 1000)
        } else {
            startDate = nil
        }

        if let endDateEpoch = try container.decodeIfPresent(Double.self, forKey: .endDate) {
            endDate = Date(timeIntervalSince1970: endDateEpoch / 1000)
        } else {
            endDate = nil
        }

        if let validUptoEpoch = try container.decodeIfPresent(Double.self, forKey: .endDate) {
            validUpto = Date(timeIntervalSince1970: validUptoEpoch / 1000)
        } else {
            validUpto = nil
        }

        isSupportedApp = try container.decodeIfPresent(Bool.self, forKey: .isSupportedApp)
        isSupportedUser = try container.decodeIfPresent(Bool.self, forKey: .isSupportedUser)


    }
}
