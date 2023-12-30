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
    func createSubscription(request: SubscriptionRequest) async throws -> PhonePeResponse<SubscriptionResponse>
}

public struct PhonePeSubscriptionRoutes: SubscriptionRoutes {
    public var headers: HTTPHeaders = [:]
    
    private let apiHandler: PhonePeAPIHandler
    private let baseUrl: String
    
    init(apiHandler: PhonePeAPIHandler, baseUrl: String) {
        self.apiHandler = apiHandler
        self.baseUrl = baseUrl
    }
    
    public func createSubscription(request: SubscriptionRequest) async throws -> PhonePeResponse<SubscriptionResponse> {
        let path = "/v3/recurring/subscription/create"
        
        let requestBody = try Request.constructRequestBody(request: request)
        
        return try await apiHandler.send(
            method: .POST,
            path: path,
            body: .data(requestBody),
            headers: headers
        )
    }
}


enum SubscriptionError: Error {
    case jsonEncodingFailed
    case dictionaryConversionFailed
    case bodyExtractionFailed
    case jsonDecodingFailed
}
