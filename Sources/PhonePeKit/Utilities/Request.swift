//
//  Request.swift
//
//
//  Created by Vamsi Madduluri on 30/12/23.
//

import Foundation
import AsyncHTTPClient
import Crypto

class Request {
    
    static func constructRequestBody<T: Codable>(request: T) throws -> Data {
        do {
            let jsonData = try JSONEncoder().encode(request)
            let base64EncodedRequest = jsonData.base64EncodedString()
            let requestDictionary = ["request": base64EncodedRequest]
            return try JSONEncoder().encode(requestDictionary)
        } catch {
            throw SubscriptionError.jsonEncodingFailed
        }
    }
    
    static func parseBase64StringFromJSON(jsonString: String) throws -> String {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonObject = try? JSONDecoder().decode([String: String].self, from: jsonData),
              let base64EncodedRequest = jsonObject["request"] else {
            throw SubscriptionError.jsonDecodingFailed
        }
        return base64EncodedRequest
    }
    
    static func calculateSHA256(inputString: String) -> String {
        let inputData = Data(inputString.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    static func generateSignature(path: String, body: HTTPClientRequest.Body, saltKey: String, saltIndex: String) async throws -> String {
        let bodyDataString = try await extractBodyString(body: body)
        let base64EncodedRequest = try Request.parseBase64StringFromJSON(jsonString: bodyDataString)
        let combinedString = base64EncodedRequest + path + saltKey
        return Request.calculateSHA256(inputString: combinedString) + "###" + saltIndex
    }
    
    static func extractBodyString(body: HTTPClientRequest.Body) async throws -> String {
        var bodyData = Data()
        for try await buffer in body {
            bodyData.append(contentsOf: buffer.readableBytesView)
        }
        guard let bodyString = String(data: bodyData, encoding: .utf8) else {
            // TODO: Use PhonePeError instead of SubscriptionError
            throw SubscriptionError.bodyExtractionFailed
        }
        return bodyString
    }
}
