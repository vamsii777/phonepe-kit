//
//  DebitInitResponse.swift
//

import Foundation

/// Response model for the debit init (pre-debit notification) API.
public struct DebitInitResponse: Codable {
    public let merchantId: String
    public let merchantTransactionId: String
    public let transactionId: String
    public let state: String
    /// Used as a reference in the subsequent `debit.execute` call.
    public let notificationId: String?
    /// Epoch milliseconds — earliest time to call `debit.execute`.
    public let validAfter: Int64?
    /// Epoch milliseconds — deadline to call `debit.execute`.
    public let validUpto: Int64?
}
