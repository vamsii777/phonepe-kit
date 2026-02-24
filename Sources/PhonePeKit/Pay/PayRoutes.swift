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

public protocol PayRoutes: PhonePeAPIRoute {
    func initiate(request: PayRequest) async throws -> PhonePeResponse<PayResponse>
}

public struct PhonePePayRoutes: PayRoutes {
    public var headers: HTTPHeaders = [:]

    public let refund: RefundRoutes

    private let apiHandler: PhonePeAPIHandler
    private let baseUrl: String

    init(apiHandler: PhonePeAPIHandler, baseUrl: String) {
        self.apiHandler = apiHandler
        self.baseUrl = baseUrl
        self.refund = RefundRoutes(apiHandler: apiHandler, baseUrl: baseUrl)
    }

    public func initiate(request: PayRequest) async throws -> PhonePeResponse<PayResponse> {
        let path = "/pg/v1/pay"
        let requestBody = try Request.constructRequestBody(request: request)
        return try await apiHandler.send(
            method: .POST,
            path: path,
            body: .data(requestBody),
            headers: headers
        )
    }

    // MARK: - Refund Routes

    public struct RefundRoutes {
        private let apiHandler: PhonePeAPIHandler
        private let baseUrl: String

        init(apiHandler: PhonePeAPIHandler, baseUrl: String) {
            self.apiHandler = apiHandler
            self.baseUrl = baseUrl
        }

        public func initiate(request: RefundRequest) async throws -> PhonePeResponse<RefundResponse> {
            let path = "/pg/v1/refund"
            let requestBody = try Request.constructRequestBody(request: request)
            return try await apiHandler.send(
                method: .POST,
                path: path,
                body: .data(requestBody),
                headers: [:]
            )
        }
    }
}
