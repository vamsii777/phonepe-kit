//
//  AuthInitRequest.swift
//

import Foundation

public struct AuthInitRequest: Codable {
    public let merchantId: String
    public let merchantSubscriptionId: String
    public let merchantUserId: String
    public let authRequestId: String
    public let amount: Int?
    public let callbackUrl: String?
    public let paymentInstrument: PaymentInstrument
    public let deviceContext: DeviceContext?

    public init(merchantId: String,
                merchantSubscriptionId: String,
                merchantUserId: String,
                authRequestId: String,
                amount: Int? = nil,
                callbackUrl: String? = nil,
                paymentInstrument: PaymentInstrument,
                deviceContext: DeviceContext? = nil) {
        self.merchantId = merchantId
        self.merchantSubscriptionId = merchantSubscriptionId
        self.merchantUserId = merchantUserId
        self.authRequestId = authRequestId
        self.amount = amount
        self.callbackUrl = callbackUrl
        self.paymentInstrument = paymentInstrument
        self.deviceContext = deviceContext
    }

    public enum PaymentInstrument: Codable {
        case upiCollect(vpa: String)
        case upiIntent(targetApp: String? = nil, deviceOS: DeviceOS? = nil)

        private enum CodingKeys: String, CodingKey {
            case type, vpa, targetApp, deviceOS
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .upiCollect(let vpa):
                try container.encode("UPI_COLLECT", forKey: .type)
                try container.encode(vpa, forKey: .vpa)
            case .upiIntent(let targetApp, let deviceOS):
                try container.encode("UPI_INTENT", forKey: .type)
                try container.encodeIfPresent(targetApp, forKey: .targetApp)
                try container.encodeIfPresent(deviceOS, forKey: .deviceOS)
            }
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(String.self, forKey: .type)
            switch type {
            case "UPI_COLLECT":
                let vpa = try container.decode(String.self, forKey: .vpa)
                self = .upiCollect(vpa: vpa)
            case "UPI_INTENT":
                let targetApp = try container.decodeIfPresent(String.self, forKey: .targetApp)
                let deviceOS = try container.decodeIfPresent(DeviceOS.self, forKey: .deviceOS)
                self = .upiIntent(targetApp: targetApp, deviceOS: deviceOS)
            default:
                throw DecodingError.dataCorruptedError(forKey: .type, in: container,
                    debugDescription: "Unknown AuthInitRequest.PaymentInstrument type: \(type)")
            }
        }
    }
}
