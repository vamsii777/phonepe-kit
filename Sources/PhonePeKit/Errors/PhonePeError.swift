//
//  PhonePeError.swift
//
//
//  Created by Vamsi Madduluri on 29/12/23.
//

import Foundation

public final class PhonePeError: Codable, Error, @unchecked Sendable {
    public var success: Bool?
    public var code: PhonePeErrorCode? // Changed to enum type
    public var message: String?

    public init(success: Bool?, code: PhonePeErrorCode? = nil, message: String? = nil) {
        self.success = success
        self.code = code
        self.message = message
    }
}
