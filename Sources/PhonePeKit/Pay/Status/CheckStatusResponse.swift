//
//  CheckStatusResponse.swift
//
//
//  Created by Vamsi Madduluri on 30/12/23.
//

import Foundation

public struct CheckStatusResponse: Codable {
    let merchantId: String?
    let merchantTransactionId: String
    let transactionId: String?
    let amount: Int64
    let state: String
    let responseCode: String
    let responseCodeDescription: String?
    let paymentInstrument: CheckStatusPaymentInstrumentType?
    
    struct CheckStatusPaymentInstrumentType: Codable {
        let type: String?
        let cardType: String?
        let pgTransactionId: String?
        let bankTransactionId: String?
        let pgAuthorizationCode: String?
        let arn: String?
        let bankId: String?
        let pgServiceTransactionId: String?
        let brn: String?
        let utr: String?
    }
}


