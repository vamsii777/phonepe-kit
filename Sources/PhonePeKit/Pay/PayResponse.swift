//
//  PayResponse.swift
//
//
//  Created by Vamsi Madduluri on 30/12/23.
//

import Foundation

public struct PayResponse: Codable {
    public let instrumentResponse: InstrumentResponse?
    public struct InstrumentResponse: Codable {
        public let type: String
        public let redirectInfo: RedirectInfo?   // PAY_PAGE, NET_BANKING, CARD
        public let intentUrl: String?            // UPI_INTENT deep-link
        public let qrData: String?               // UPI_INTENT QR string

        public struct RedirectInfo: Codable {
            public let url: String
            public let method: String
        }
    }
}
