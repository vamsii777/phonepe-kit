//
//  HealthStatusResponse.swift
//
//
//  Created by Vamsi Madduluri on 31/12/23.
//

import Foundation

public struct HealthStatusResponse: Codable {
    var overallHealth: OverallHealth?
    var instruments: [String: InstrumentHealth?]
    
    struct InstrumentHealth: Codable {
        var health: HealthType
        var downProviderIds: [String: [String]]?

        enum CodingKeys: String, CodingKey {
            case health, downProviderIds
        }
    }
    
    enum OverallHealth: String, Codable {
        case up = "UP"
        case down = "DOWN"
    }

    enum HealthType: String, Codable {
        case up = "UP"
        case down = "DOWN"
    }
}
