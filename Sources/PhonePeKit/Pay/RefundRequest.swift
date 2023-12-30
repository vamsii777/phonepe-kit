//
//  RefundRequest.swift
//
//
//  Created by Vamsi Madduluri on 31/12/23.
//

import Foundation

public struct RefundRequest: Codable {
    let merchantId: String
    let merchantUserId: String
    let originalTransactionId: String
    let merchantTransactionId: String
    let amount: Int64
    let callbackUrl: String
}
