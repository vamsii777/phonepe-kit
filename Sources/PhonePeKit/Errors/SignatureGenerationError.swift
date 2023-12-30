//
//  SignatureGenerationError.swift
//
//
//  Created by Vamsi Madduluri on 30/12/23.
//

import Foundation

enum SignatureGenerationError: Error {
    case invalidBodyFormat
    case dataExtractionFailed
}
