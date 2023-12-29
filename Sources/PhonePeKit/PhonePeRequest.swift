//
//  PhonePeRequest.swift
//
//
//  Created by Vamsi Madduluri on 29/12/23.
//

import Foundation
import Crypto
import NIO
import NIOFoundationCompat
import NIOHTTP1
import AsyncHTTPClient

internal let PhonePeAPIBase = "https://api.phonepe.com/apis"
internal let PhonePeAPISandbox = "https://api-preprod.phonepe.com/apis/pg-sandbox"

public enum Environment {
    case production
    case sandbox
    
    var baseUrl: String {
        switch self {
        case .production:
            return PhonePeAPIBase
        case .sandbox:
            return PhonePeAPISandbox
        }
    }
}

extension HTTPClientRequest.Body {
    public static func string(_ string: String) -> Self {
        .bytes(.init(string: string))
    }
    
    public static func data(_ data: Data) -> Self {
        .bytes(.init(data: data))
    }
}


struct PhonePeAPIHandler {
    private let httpClient: HTTPClient
    private let saltKey: String
    private let saltIndex: String
    private let environment: Environment
    private let decoder: JSONDecoder
    
    init(httpClient: HTTPClient, saltKey: String, saltIndex: String, environment: Environment) {
        self.httpClient = httpClient
        self.saltKey = saltKey
        self.saltIndex = saltIndex
        self.environment = environment
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .secondsSince1970
    }
    
    func send<T: Codable>(method: HTTPMethod,
                          path: String,
                          query: String = "",
                          body: HTTPClientRequest.Body = .bytes(.init(string: "")),
                          headers: HTTPHeaders) async throws -> T {
        var _headers: HTTPHeaders = ["Content-Type": "application/json",
                                     "Accept": "application/json"]
        headers.forEach { _headers.replaceOrAdd(name: $0.name, value: $0.value) }
        
        let signature = try await generateSignature(path: path, body: body)
        _headers.add(name: "X-VERIFY", value: signature)
        
        var request = HTTPClientRequest(url: "\(environment.baseUrl)\(path)?\(query)")
        request.headers = _headers
        request.method = method
        request.body = body
        
        let response = try await httpClient.execute(request, timeout: .seconds(60))
        let responseData = try await response.body.collect(upTo: 1024 * 1024 * 100) // 100 MB limit
        guard response.status == .ok else {
            let errorDescription = String(buffer: responseData)
            let statusCode = response.status.code
            let userInfo: [String: Any] = [
                NSLocalizedDescriptionKey: errorDescription,
                "StatusCode": statusCode
            ]
            throw NSError(domain: "PhonePeAPIError", code: Int(statusCode), userInfo: userInfo)
        }
        
        
        return try decoder.decode(T.self, from: Data(buffer: responseData))
    }
    
    private func generateSignature(path: String, body: HTTPClientRequest.Body) async throws -> String {
        let bodyDataString = try await extractBodyString(body: body)
        let base64EncodedRequest = try parseBase64StringFromJSON(jsonString: bodyDataString)
        let combinedString = base64EncodedRequest + path + saltKey
        return calculateSHA256(inputString: combinedString) + "###" + saltIndex
    }
    
    private func extractBodyString(body: HTTPClientRequest.Body) async throws -> String {
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
    
    private func parseBase64StringFromJSON(jsonString: String) throws -> String {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonObject = try? JSONDecoder().decode([String: String].self, from: jsonData),
              let base64EncodedRequest = jsonObject["request"] else {
            // TODO: Use PhonePeError instead of SubscriptionError
            throw SubscriptionError.jsonDecodingFailed
        }
        return base64EncodedRequest
    }
    
    private func calculateSHA256(inputString: String) -> String {
        let inputData = Data(inputString.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}


enum SignatureGenerationError: Error {
    case invalidBodyFormat
    case dataExtractionFailed
}
