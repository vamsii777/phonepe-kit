//
//  RefundResponse.swift
//
//
//  Created by Vamsi Madduluri on 31/12/23.
//

import Foundation

public struct RefundResponse: Codable {
    let merchantId: String
    let merchantTransactionId: String
    let transactionId: String
    let amount: Int64
    let state: String
    let responseCode: String
}
