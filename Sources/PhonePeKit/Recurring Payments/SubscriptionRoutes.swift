//
//  SubscriptionRoutes.swift
//
//
//  Created by Vamsi Madduluri on 29/12/23.
//
import NIO
import NIOHTTP1
import Foundation
import AsyncHTTPClient

public protocol SubscriptionRoutes: PhonePeAPIRoute {
    func createSubscription(request: CreateUserSubscriptionRequest) async throws -> CreateUserSubscriptionResponse
}

public struct PhonePeSubscriptionRoutes: SubscriptionRoutes {
    public var headers: HTTPHeaders = [:]
    
    private let apiHandler: PhonePeAPIHandler
    private let baseUrl: String
    
    init(apiHandler: PhonePeAPIHandler, baseUrl: String) {
        self.apiHandler = apiHandler
        self.baseUrl = baseUrl
    }
    
    public func createSubscription(request: CreateUserSubscriptionRequest) async throws -> CreateUserSubscriptionResponse {
        let path = "/v3/recurring/subscription/create"

        let requestBody = try constructRequestBody(request: request)
        
        return try await apiHandler.send(
            method: .POST,
            path: path,
            body: .data(requestBody),
            headers: headers
        )
    }

    private func constructRequestBody(request: CreateUserSubscriptionRequest) throws -> Data {
        do {
            let jsonData = try JSONEncoder().encode(request)
            let base64EncodedRequest = jsonData.base64EncodedString()
            let requestDictionary = ["request": base64EncodedRequest]
            return try JSONEncoder().encode(requestDictionary)
        } catch {
            throw SubscriptionError.jsonEncodingFailed
        }
    }
}


enum SubscriptionError: Error {
    case jsonEncodingFailed
    case dictionaryConversionFailed
    case bodyExtractionFailed
    case jsonDecodingFailed
}
