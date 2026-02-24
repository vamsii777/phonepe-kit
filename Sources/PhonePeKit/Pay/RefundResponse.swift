//
//  RefundResponse.swift
//
//
//  Created by Vamsi Madduluri on 31/12/23.
//

import Foundation

public struct RefundResponse: Codable {
    public let merchantId: String
    public let merchantTransactionId: String
    public let transactionId: String
    public let amount: Int64
    public let state: String
    public let responseCode: String
}
