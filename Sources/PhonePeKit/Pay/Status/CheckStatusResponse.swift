//
//  CheckStatusResponse.swift
//
//
//  Created by Vamsi Madduluri on 30/12/23.
//

import Foundation

public struct CheckStatusResponse: Codable {
    public let merchantId: String?
    public let merchantTransactionId: String
    public let transactionId: String?
    public let amount: Int64
    public let state: String
    public let responseCode: String
    public let responseCodeDescription: String?
    public let paymentInstrument: PaymentInstrumentDetails?

    public struct PaymentInstrumentDetails: Codable {
        public let type: String?
        public let cardType: String?
        public let pgTransactionId: String?
        public let bankTransactionId: String?
        public let pgAuthorizationCode: String?
        public let arn: String?
        public let bankId: String?
        public let pgServiceTransactionId: String?
        public let brn: String?
        public let utr: String?
    }
}
