//
//  CheckStatusRoutes.swift
//
//
//  Created by Vamsi Madduluri on 30/12/23.
//

import Foundation
import NIO
import NIOHTTP1
import AsyncHTTPClient

// Protocol for Check Status routes
public protocol CheckStatusRoutes: PhonePeAPIRoute {
    func checkTransactionStatus(merchantId: String, merchantTransactionId: String) async throws -> PhonePeResponse<CheckStatusResponse>
}

// Struct for Check Status API routes
public struct PhonePeCheckStatusRoutes: CheckStatusRoutes {
    public var headers: HTTPHeaders = [:]
    
    private let apiHandler: PhonePeAPIHandler
    private let baseUrl: String
    
    init(apiHandler: PhonePeAPIHandler, baseUrl: String) {
        self.apiHandler = apiHandler
        self.baseUrl = baseUrl
    }
    
    public func checkTransactionStatus(merchantId: String, merchantTransactionId: String) async throws -> PhonePeResponse<CheckStatusResponse> {
        let path = "/pg/v1/status/\(merchantId)/\(merchantTransactionId)"
        
        var requestHeaders = headers
        requestHeaders.add(name: "X-MERCHANT-ID", value: merchantId)
        requestHeaders.add(name: "merchantId", value: merchantId)
        requestHeaders.add(name: "merchantTransactionId", value: merchantTransactionId)
        
        return try await apiHandler.send(
            method: .GET,
            path: path,
            headers: requestHeaders
        )
    }
}
