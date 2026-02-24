//
//  PaymentOptionsResponse.swift
//
//
//  Created by Vamsi Madduluri on 01/01/24.
//

import Foundation

public struct PaymentOptionsResponse: Codable {
    public let upiCollect: PaymentOption?
    public let intent: PaymentOption?
    public let cards: PaymentOption?
    public let netBanking: NetBankingOption?

    public struct PaymentOption: Codable {
        public let enabled: Bool?
        public let popularBanks: [Bank]?
        public let allBanks: [Bank]?
    }

    public struct NetBankingOption: Codable {
        public let enabled: Bool?
        public let popularBanks: [Bank]?
        public let allBanks: [Bank]?
    }

    public struct Bank: Codable {
        public let bankId: String?
        public let bankName: String?
        public let bankShortName: String?
        public let available: BankAvailability?
        public let accountConstraintSupported: Bool?
        public let priority: Int?
    }

    public enum BankAvailability: String, Codable {
        case available = "AVAILABLE"
        case unavailable = "UNAVAILABLE"
        case degraded = "DEGRADED"
    }
}
