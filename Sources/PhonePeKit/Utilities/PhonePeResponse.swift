//
//  PhonePeResponse.swift
//
//
//  Created by Vamsi Madduluri on 30/12/23.
//

import Foundation

/// A generic wrapper for PhonePe v1 API responses.
///
/// Every v1 API call returns a JSON envelope of the form:
/// ```json
/// { "success": true, "code": "PAYMENT_INITIATED", "message": "...", "data": { ... } }
/// ```
///
/// `PhonePeResponse<T>` decodes this envelope and surfaces:
/// - ``success`` — whether the request succeeded.
/// - ``code`` — a strongly typed ``PhonePeCode`` (unknown codes are captured in `.unknown(_:)`).
/// - ``message`` — optional human-readable detail.
/// - ``data`` — the payload decoded as `T`, or `nil` when the shape doesn't match.
public struct PhonePeResponse<T: Codable>: Codable {
    /// Whether the API request succeeded.
    public let success: Bool

    /// The response code returned by PhonePe, decoded as a ``PhonePeCode``.
    ///
    /// Codes not yet listed in the enum are captured as ``PhonePeCode/unknown(_:)``
    /// so that future additions never break decoding.
    public let code: PhonePeCode

    /// Optional human-readable message accompanying the response.
    public let message: String?

    /// The response payload. `nil` when the shape doesn't match `T` or when absent.
    public let data: T?

    enum CodingKeys: String, CodingKey {
        case success, code, message, data
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decode(Bool.self, forKey: .success)
        code = try container.decode(PhonePeCode.self, forKey: .code)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        // Use try? so that error responses with a mismatched `data` shape
        // (e.g. missing required fields) yield nil instead of throwing.
        data = try? container.decodeIfPresent(T.self, forKey: .data)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(success, forKey: .success)
        try container.encode(code, forKey: .code)
        try container.encodeIfPresent(message, forKey: .message)
        try container.encodeIfPresent(data, forKey: .data)
    }
}
