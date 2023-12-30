//
//  PayResponse.swift
//
//
//  Created by Vamsi Madduluri on 30/12/23.
//

import Foundation

public struct PayResponse: Codable {
    let instrumentResponse: InstrumentResponse
    struct InstrumentResponse: Codable {
        let type: String
        let redirectInfo: RedirectInfo

        struct RedirectInfo: Codable {
            let url: String
            let method: String
        }
    }
}
