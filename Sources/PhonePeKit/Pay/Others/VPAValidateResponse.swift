//
//  VPAValidateResponse.swift
//
//
//  Created by Vamsi Madduluri on 31/12/23.
//

import Foundation

public struct VPAValidateResponse: Codable {
    public let name: String
    public let vpa: String
    public let exists: Bool?
}
