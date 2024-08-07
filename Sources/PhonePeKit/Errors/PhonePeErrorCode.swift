//
//  PhonePeErrorCode.swift
//
//
//  Created by Vamsi Madduluri on 30/12/23.
//

import Foundation

public enum PhonePeErrorCode: String, Sendable, Codable {
    case PAYMENT_INITIATED = "PAYMENT_INITIATED"
    case PAYMENT_ERROR = "PAYMENT_ERROR"
    case INTERNAL_SERVER_ERROR = "INTERNAL_SERVER_ERROR"
    case BAD_REQUEST = "BAD_REQUEST"
    case AUTHORIZATION_FAILED = "AUTHORIZATION_FAILED"
    case PAYMENT_SUCCESS = "PAYMENT_SUCCESS"
    case TRANSACTION_NOT_FOUND = "TRANSACTION_NOT_FOUND"
    case PAYMENT_PENDING = "PAYMENT_PENDING"
    case PAYMENT_DECLINED = "PAYMENT_DECLINED"
    case TIMED_OUT = "TIMED_OUT"
    case INVALID_VPA = "INVALID_VPA"
}
