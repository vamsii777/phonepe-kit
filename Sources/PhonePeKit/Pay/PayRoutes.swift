//
//  PayRoutes.swift
//
//
//  Created by Vamsi Madduluri on 30/12/23.
//

import Foundation
import NIO
import NIOHTTP1
import AsyncHTTPClient

// Defines the required protocol for Pay routes
public protocol PayRoutes: PhonePeAPIRoute {
    func initiatePayment(request: PayRequest) async throws -> PhonePeResponse<PayResponse>
    func refundPayment(request: RefundRequest) async throws -> PhonePeResponse<RefundResponse>
}

// Struct for Pay API routes
public struct PhonePePayRoutes: PayRoutes {
    public var headers: HTTPHeaders = [:]

    private let apiHandler: PhonePeAPIHandler
    private let baseUrl: String

    init(apiHandler: PhonePeAPIHandler, baseUrl: String) {
        self.apiHandler = apiHandler
        self.baseUrl = baseUrl
    }

    public func initiatePayment(request: PayRequest) async throws -> PhonePeResponse<PayResponse> {
        let path = "/pg/v1/pay"

        let requestBody = try Request.constructRequestBody(request: request)

        return try await apiHandler.send(
            method: .POST,
            path: path,
            body: .data(requestBody),
            headers: headers
        )
    }

    public func refundPayment(request: RefundRequest) async throws -> PhonePeResponse<RefundResponse> {
        let path = "/pg/v1/refund"

        let requestBody = try Request.constructRequestBody(request: request)

        return try await apiHandler.send(
            method: .POST,
            path: path,
            body: .data(requestBody),
            headers: headers
        )
    }
}
