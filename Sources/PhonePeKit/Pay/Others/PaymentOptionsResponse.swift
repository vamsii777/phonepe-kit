//
//  PaymentOptionsResponse.swift
//
//
//  Created by Vamsi Madduluri on 01/01/24.
//

import Foundation

public struct PaymentOptionsResponse: Codable {
    var upiCollect: PaymentOption?
    var intent: PaymentOption?
    var cards: PaymentOption?
    var netBanking: NetBankingOption?
    
    enum CodingKeys: String, CodingKey {
        case upiCollect, intent, cards, netBanking
    }
    
    
    struct PaymentOption: Codable {
        var enabled: Bool?
        var popularBanks: [Bank]?
        var allBanks: [Bank]?
    }
    
    struct NetBankingOption: Codable {
        var enabled: Bool?
        var popularBanks: [Bank]?
        var allBanks: [Bank]?
    }
    
    struct Bank: Codable {
        var bankId: String?
        var bankName: String?
        var bankShortName: String?
        var available: BankAvailability?
        var accountConstraintSupported: Bool?
        var priority: Int?
    }
    
    enum BankAvailability: String, Codable {
        case available = "AVAILABLE"
        case unavailable = "UNAVAILABLE"
        case degraded = "DEGRADED"
    }
}
