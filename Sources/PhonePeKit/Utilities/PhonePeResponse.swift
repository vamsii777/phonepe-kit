//
//  PhonePeResponse.swift
//
//
//  Created by Vamsi Madduluri on 30/12/23.
//

import Foundation

/// Represents a response from the PhonePe API.
///
/// The `PhonePeResponse` struct is a generic type that encapsulates the success status, error code, error message, and data returned by the PhonePe API.
/// It conforms to the `Codable` protocol to support encoding and decoding from/to JSON.
public struct PhonePeResponse<T: Codable>: Codable {
    /// Indicates whether the API request was successful or not.
    public let success: Bool
    
    /// The error code returned by the API in case of failure.
    public let code: String
    
    /// The error message returned by the API in case of failure.
    public let message: String?
    
    /// The data returned by the API in case of success.
    public let data: T?
    
    /// The coding keys used for encoding and decoding the struct.
    enum CodingKeys: String, CodingKey {
        case success, code, message, data
    }
}
