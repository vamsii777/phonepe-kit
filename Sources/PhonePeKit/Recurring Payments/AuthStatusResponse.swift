//
//  AuthStatusResponse.swift
//
//
//  Created by Vamsi Madduluri on 01/01/24.
//

import Foundation

public struct AuthRequestStatusResponse: Codable {
    var merchantId: String
    var authRequestId: String
    var transactionDetails: TransactionDetails?
    var subscriptionDetails: SubscriptionDetails

    struct TransactionDetails: Codable {
        var providerReferenceId: String?
        var amount: Int?
        var state: String?
        var payResponseCode: String?
        var payResponseCodeDescription: String?
        var paymentModes: [PaymentMode]?
    }
    
    struct SubscriptionDetails: Codable {
        var subscriptionId: String
        var state: String
    }
    
    struct PaymentMode: Codable {
        var mode: String
        var amount: Int
        var utr: String?
        var ifsc: String?
        var maskedAccountNumber: String?
        var umn: String?
    }
}
