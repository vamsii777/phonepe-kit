//
//  AuthStatusResponse.swift
//
//
//  Created by Vamsi Madduluri on 01/01/24.
//

import Foundation

/// Represents the response for the authentication request status.
public struct AuthRequestStatusResponse: Codable {
    var merchantId: String
    var authRequestId: String
    var transactionDetails: TransactionDetails?
    var subscriptionDetails: SubscriptionDetails

    /// Represents the details of a transaction.
    struct TransactionDetails: Codable {
        var providerReferenceId: String?
        var amount: Int?
        var state: String?
        var payResponseCode: String?
        var payResponseCodeDescription: String?
        var paymentModes: [PaymentMode]?
    }
    
    /// Represents the details of a subscription.
    struct SubscriptionDetails: Codable {
        var subscriptionId: String
        var state: String
    }
    
    /// Represents a payment mode.
    struct PaymentMode: Codable {
        var mode: String
        var amount: Int
        var utr: String?
        var ifsc: String?
        var maskedAccountNumber: String?
        var umn: String?
    }
}
