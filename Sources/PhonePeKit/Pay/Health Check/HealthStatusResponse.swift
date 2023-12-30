//
//  HealthStatusResponse.swift
//
//
//  Created by Vamsi Madduluri on 31/12/23.
//

import Foundation

public struct HealthStatusResponse: Codable {
    let overallHealth: String
}

public enum HealthStatus: String, Codable {
    case up = "UP"
    case down = "DOWN"
}

public struct InstrumentHealth: Codable {
    let health: HealthStatus
    let downProviderIds: [ProviderType: [String]]?

    enum CodingKeys: String, CodingKey {
        case health, downProviderIds
    }
}

public enum ProviderType: String, Codable {
    case bank = "BANK"
    case cardNetwork = "CARD_NETWORK"
    case psp = "PSP"
}
