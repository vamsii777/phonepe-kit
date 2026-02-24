//
//  OtherRoutes.swift
//
//
//  Created by Vamsi Madduluri on 31/12/23.
//

import Foundation
import NIO
import NIOHTTP1
import AsyncHTTPClient

public protocol ValidateRoutes: PhonePeAPIRoute {
    func vpa(request: VPAValidateRequest) async throws -> PhonePeResponse<VPAValidateResponse>
}

public struct PhonePeValidateRoutes: ValidateRoutes {
    public var headers: HTTPHeaders = [:]
    private let apiHandler: PhonePeAPIHandler
    private let baseUrl: String

    init(apiHandler: PhonePeAPIHandler, baseUrl: String) {
        self.apiHandler = apiHandler
        self.baseUrl = baseUrl
    }

    public func vpa(request: VPAValidateRequest) async throws -> PhonePeResponse<VPAValidateResponse> {
        let path = "/pg/v1/vpa/validate"
        let requestBody = try Request.constructRequestBody(request: request)
        return try await apiHandler.send(
            method: .POST,
            path: path,
            body: .data(requestBody),
            headers: headers
        )
    }
}

public protocol OptionsRoutes: PhonePeAPIRoute {
    func payment(merchantId: String) async throws -> PhonePeResponse<PaymentOptionsResponse>
}

public struct PhonePeOptionsRoutes: OptionsRoutes {
    public var headers: HTTPHeaders = [:]
    private let apiHandler: PhonePeAPIHandler
    private let baseUrl: String

    init(apiHandler: PhonePeAPIHandler, baseUrl: String) {
        self.apiHandler = apiHandler
        self.baseUrl = baseUrl
    }

    public func payment(merchantId: String) async throws -> PhonePeResponse<PaymentOptionsResponse> {
        let path = "/pg/v1/options/\(merchantId)"
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
