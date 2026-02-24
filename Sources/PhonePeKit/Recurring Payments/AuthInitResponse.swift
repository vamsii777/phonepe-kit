//
//  AuthInitResponse.swift
//

import Foundation

public struct AuthInitResponse: Codable {
    public let merchantId: String
    public let merchantSubscriptionId: String
    public let authRequestId: String
    public let instrumentResponse: InstrumentResponse?

    public struct InstrumentResponse: Codable {
        public let type: String
        public let redirectInfo: RedirectInfo?
        public let intentUrl: String?

        public struct RedirectInfo: Codable {
            public let url: String
            public let method: String
        }
    }
}
