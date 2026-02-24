//
//  PhonePeErrorCode.swift
//
//
//  Created by Vamsi Madduluri on 30/12/23.
//

import Foundation

public enum PhonePeErrorCode: String, Sendable, Codable {
    // Payment status
    case PAYMENT_INITIATED = "PAYMENT_INITIATED"
    case PAYMENT_SUCCESS = "PAYMENT_SUCCESS"
    case PAYMENT_ERROR = "PAYMENT_ERROR"
    case PAYMENT_PENDING = "PAYMENT_PENDING"
    case PAYMENT_DECLINED = "PAYMENT_DECLINED"

    // Transaction
    case TRANSACTION_NOT_FOUND = "TRANSACTION_NOT_FOUND"
    case TXN_CANCELLED = "TXN_CANCELLED"
    case TIMED_OUT = "TIMED_OUT"

    // Auth & configuration
    case AUTHORIZATION_FAILED = "AUTHORIZATION_FAILED"
    case KEY_NOT_CONFIGURED = "KEY_NOT_CONFIGURED"
    case BAD_REQUEST = "BAD_REQUEST"
    case INTERNAL_SERVER_ERROR = "INTERNAL_SERVER_ERROR"

    // General success
    case SUCCESS = "SUCCESS"

    // VPA
    case INVALID_VPA = "INVALID_VPA"

    // Bank / balance
    case INSUFFICIENT_BALANCE = "INSUFFICIENT_BALANCE"
    case BANK_TECHNICAL_ISSUE = "BANK_TECHNICAL_ISSUE"
    case USER_BLACKLISTED = "USER_BLACKLISTED"

    // SDK-internal: server returned an empty response body
    case EMPTY_RESPONSE = "EMPTY_RESPONSE"
}
