//
//  HealthStatusResponse.swift
//
//
//  Created by Vamsi Madduluri on 31/12/23.
//

import Foundation

public struct HealthStatusResponse: Codable {
    public let overallHealth: OverallHealth?
    public let instruments: [String: InstrumentHealth?]

    public struct InstrumentHealth: Codable {
        public let health: HealthType
        public let downProviderIds: [String: [String]]?
    }

    public enum OverallHealth: String, Codable {
        case up = "UP"
        case down = "DOWN"
    }

    public enum HealthType: String, Codable {
        case up = "UP"
        case down = "DOWN"
    }
}
