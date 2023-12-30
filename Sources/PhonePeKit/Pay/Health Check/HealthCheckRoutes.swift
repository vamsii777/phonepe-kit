//
//  HealthCheckRoutes.swift
//
//
//  Created by Vamsi Madduluri on 31/12/23.
//

import Foundation
import NIO
import NIOHTTP1
import AsyncHTTPClient

public protocol HealthCheckRoutes: PhonePeAPIRoute  {
    func status(merchantId: String) async throws -> HealthStatusResponse
}

public struct PhonePeHealthCheckRoutes: HealthCheckRoutes {
    
    public var headers: HTTPHeaders = [:]
    private let apiHandler: PhonePeAPIHandler
    private let baseUrl: String

    init(apiHandler: PhonePeAPIHandler, baseUrl: String) {
        self.apiHandler = apiHandler
        self.baseUrl = baseUrl
    }

    public func status(merchantId: String) async throws -> HealthStatusResponse {
        let path = "/v1/pg/merchants/\(merchantId)/health"
        
        var requestHeaders = headers
        requestHeaders.add(name: "X-MERCHANT-ID", value: merchantId)
        requestHeaders.add(name: "merchantId", value: merchantId)
        
        return try await apiHandler.send(
            method: .GET,
            path: path,
            headers: requestHeaders
        )
    }
}
