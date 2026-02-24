//
//  PayRequest.swift
//
//
//  Created by Vamsi Madduluri on 30/12/23.
//

import Foundation

public struct PayRequest: Codable {
    public let merchantId: String
    public let merchantTransactionId: String
    public let amount: Int64
    public let merchantUserId: String
    public let redirectUrl: String
    public let redirectMode: RedirectMode
    public let callbackUrl: String
    public let paymentInstrument: PaymentInstrument
    public let mobileNumber: String?

    public enum RedirectMode: String, Codable {
        case REDIRECT
        case POST
    }

    public init(merchantId: String,
                merchantTransactionId: String,
                amount: Int64,
                merchantUserId: String,
                redirectUrl: String,
                redirectMode: RedirectMode,
                callbackUrl: String,
                paymentInstrument: PaymentInstrument,
                mobileNumber: String? = nil) {
        self.merchantId = merchantId
        self.merchantTransactionId = merchantTransactionId
        self.amount = amount
        self.merchantUserId = merchantUserId
        self.redirectUrl = redirectUrl
        self.redirectMode = redirectMode
        self.callbackUrl = callbackUrl
        self.paymentInstrument = paymentInstrument
        self.mobileNumber = mobileNumber
    }

    public enum PaymentInstrument: Codable {
        case payPage
        case upiCollect(vpa: String)
        case upiIntent(targetApp: String? = nil, deviceOS: DeviceOS? = nil)
        case netBanking(bankId: String)
        case card(authMode: String, cardNumber: String, cardExpiry: String,
                  cardHolderName: String, cvv: String)
        case token(authMode: String, token: String, cryptogram: String,
                   expiryMonth: String, expiryYear: String, cardHolderName: String)

        private enum CodingKeys: String, CodingKey {
            case type, vpa, targetApp, deviceOS, bankId
            case authMode, cardNumber, cardExpiry, cardHolderName, cvv
            case token, cryptogram, expiryMonth, expiryYear
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .payPage:
                try container.encode("PAY_PAGE", forKey: .type)
            case .upiCollect(let vpa):
                try container.encode("UPI_COLLECT", forKey: .type)
                try container.encode(vpa, forKey: .vpa)
            case .upiIntent(let targetApp, let deviceOS):
                try container.encode("UPI_INTENT", forKey: .type)
                try container.encodeIfPresent(targetApp, forKey: .targetApp)
                try container.encodeIfPresent(deviceOS, forKey: .deviceOS)
            case .netBanking(let bankId):
                try container.encode("NET_BANKING", forKey: .type)
                try container.encode(bankId, forKey: .bankId)
            case .card(let authMode, let cardNumber, let cardExpiry, let cardHolderName, let cvv):
                try container.encode("CARD", forKey: .type)
                try container.encode(authMode, forKey: .authMode)
                try container.encode(cardNumber, forKey: .cardNumber)
                try container.encode(cardExpiry, forKey: .cardExpiry)
                try container.encode(cardHolderName, forKey: .cardHolderName)
                try container.encode(cvv, forKey: .cvv)
            case .token(let authMode, let token, let cryptogram, let expiryMonth, let expiryYear, let cardHolderName):
                try container.encode("TOKEN", forKey: .type)
                try container.encode(authMode, forKey: .authMode)
                try container.encode(token, forKey: .token)
                try container.encode(cryptogram, forKey: .cryptogram)
                try container.encode(expiryMonth, forKey: .expiryMonth)
                try container.encode(expiryYear, forKey: .expiryYear)
                try container.encode(cardHolderName, forKey: .cardHolderName)
            }
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(String.self, forKey: .type)
            switch type {
            case "PAY_PAGE":
                self = .payPage
            case "UPI_COLLECT":
                let vpa = try container.decode(String.self, forKey: .vpa)
                self = .upiCollect(vpa: vpa)
            case "UPI_INTENT":
                let targetApp = try container.decodeIfPresent(String.self, forKey: .targetApp)
                let deviceOS = try container.decodeIfPresent(DeviceOS.self, forKey: .deviceOS)
                self = .upiIntent(targetApp: targetApp, deviceOS: deviceOS)
            case "NET_BANKING":
                let bankId = try container.decode(String.self, forKey: .bankId)
                self = .netBanking(bankId: bankId)
            case "CARD":
                let authMode = try container.decode(String.self, forKey: .authMode)
                let cardNumber = try container.decode(String.self, forKey: .cardNumber)
                let cardExpiry = try container.decode(String.self, forKey: .cardExpiry)
                let cardHolderName = try container.decode(String.self, forKey: .cardHolderName)
                let cvv = try container.decode(String.self, forKey: .cvv)
                self = .card(authMode: authMode, cardNumber: cardNumber, cardExpiry: cardExpiry,
                             cardHolderName: cardHolderName, cvv: cvv)
            case "TOKEN":
                let authMode = try container.decode(String.self, forKey: .authMode)
                let token = try container.decode(String.self, forKey: .token)
                let cryptogram = try container.decode(String.self, forKey: .cryptogram)
                let expiryMonth = try container.decode(String.self, forKey: .expiryMonth)
                let expiryYear = try container.decode(String.self, forKey: .expiryYear)
                let cardHolderName = try container.decode(String.self, forKey: .cardHolderName)
                self = .token(authMode: authMode, token: token, cryptogram: cryptogram,
                              expiryMonth: expiryMonth, expiryYear: expiryYear, cardHolderName: cardHolderName)
            default:
                throw DecodingError.dataCorruptedError(forKey: .type, in: container,
                    debugDescription: "Unknown PaymentInstrument type: \(type)")
            }
        }
    }
}

public enum DeviceOS: String, Codable {
    case ANDROID
    case IOS
}
