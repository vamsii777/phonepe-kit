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

// Protocol for Status routes
public protocol StatusRoutes: PhonePeAPIRoute {
    func transaction(merchantId: String, merchantTransactionId: String) async throws -> PhonePeResponse<CheckStatusResponse>
    func health(merchantId: String) async throws -> HealthStatusResponse
}

// Struct for Status API routes
public struct PhonePeStatusRoutes: StatusRoutes {
    public var headers: HTTPHeaders = [:]

    private let apiHandler: PhonePeAPIHandler
    private let baseUrl: String
    private let healthBaseUrl: String

    init(apiHandler: PhonePeAPIHandler, baseUrl: String, healthBaseUrl: String) {
        self.apiHandler = apiHandler
        self.baseUrl = baseUrl
        self.healthBaseUrl = healthBaseUrl
    }

    public func transaction(merchantId: String, merchantTransactionId: String) async throws -> PhonePeResponse<CheckStatusResponse> {
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

    public func health(merchantId: String) async throws -> HealthStatusResponse {
        let path = "/v1/pg/merchants/\(merchantId)/health"

        var requestHeaders = headers
        requestHeaders.add(name: "X-MERCHANT-ID", value: merchantId)
        requestHeaders.add(name: "merchantId", value: merchantId)

        return try await apiHandler.send(
            method: .GET,
            path: path,
            headers: requestHeaders,
            baseUrl: healthBaseUrl
        )
    }
}
