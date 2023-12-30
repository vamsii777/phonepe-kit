//
//  PhonePeResponse.swift
//
//
//  Created by Vamsi Madduluri on 30/12/23.
//

import Foundation

public struct PhonePeResponse<T: Codable>: Codable {
    let success: Bool
    let code: String
    let message: String?
    let data: T?

    enum CodingKeys: String, CodingKey {
        case success, code, message, data
    }
}
