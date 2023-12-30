//
//  PhonePeErrorCode.swift
//
//
//  Created by Vamsi Madduluri on 30/12/23.
//

import Foundation

public enum PhonePeErrorCode: String, Codable {
    case PAYMENT_INITIATED = "PAYMENT_INITIATED"
    case PAYMENT_ERROR = "PAYMENT_ERROR"
    case INTERNAL_SERVER_ERROR = "INTERNAL_SERVER_ERROR"
    case BAD_REQUEST = "BAD_REQUEST"
    case AUTHORIZATION_FAILED = "AUTHORIZATION_FAILED"
}
