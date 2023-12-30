//
//  PayRequest.swift
//
//
//  Created by Vamsi Madduluri on 30/12/23.
//

import Foundation

public struct PayRequest: Codable {
    let merchantId: String
    let merchantTransactionId: String
    let amount: Int64 // LONG type in Swift is represented as Int64
    let merchantUserId: String
    let redirectUrl: String
    let redirectMode: RedirectMode
    let callbackUrl: String
    let paymentInstrument: PaymentInstrument
    let mobileNumber: String? // Optional as it's not mandatory

    enum CodingKeys: String, CodingKey {
        case merchantId, merchantTransactionId, amount, merchantUserId, redirectUrl, redirectMode, callbackUrl, paymentInstrument, mobileNumber
    }

    enum RedirectMode: String, Codable {
        case REDIRECT
        case POST
    }

    struct PaymentInstrument: Codable {
        let type: PaymentInstrumentType
    }

    enum PaymentInstrumentType: String, Codable {
        case PAY_PAGE = "PAY_PAGE"
    }
}
