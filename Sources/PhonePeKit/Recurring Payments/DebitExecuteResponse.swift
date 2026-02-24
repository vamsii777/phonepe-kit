//
//  DebitExecuteResponse.swift
//

import Foundation

public struct DebitExecuteResponse: Codable {
    public let merchantId: String
    public let merchantTransactionId: String
    public let transactionId: String
    public let amount: Int64
    public let state: String
    public let responseCode: String
}
