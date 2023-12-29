//
//  PhonePeError.swift
//
//
//  Created by Vamsi Madduluri on 29/12/23.
//

import Foundation

public final class PhonePeError: Codable, Error {
    public var success: Bool?
    public var code: String? // Make optional
    public var message: String? // Make optional
    public var data: Data? // Update the type as needed

    public init(success: Bool?, code: String? = nil, message: String? = nil, data: Data? = nil) {
        self.success = success
        self.code = code
        self.message = message
        self.data = data
    }
}

// Usage example
// let error = PhonePeError(success: false, code: "some_error_code", message: "Error message", data: nil)
