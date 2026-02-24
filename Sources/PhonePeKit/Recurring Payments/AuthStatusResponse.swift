//
//  AuthStatusResponse.swift
//
//
//  Created by Vamsi Madduluri on 01/01/24.
//

import Foundation

public struct AuthRequestStatusResponse: Codable {
    public let merchantId: String
    public let authRequestId: String
    public let transactionDetails: TransactionDetails?
    public let subscriptionDetails: SubscriptionDetails

    public struct TransactionDetails: Codable {
        public let providerReferenceId: String?
        public let amount: Int?
        public let state: String?
        public let payResponseCode: String?
        public let payResponseCodeDescription: String?
        public let paymentModes: [PaymentMode]?
    }

    public struct SubscriptionDetails: Codable {
        public let subscriptionId: String
        public let state: String
    }

    public struct PaymentMode: Codable {
        public let mode: String
        public let amount: Int
        public let utr: String?
        public let ifsc: String?
        public let maskedAccountNumber: String?
        public let umn: String?
    }
}
