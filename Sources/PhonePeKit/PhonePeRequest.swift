//
//  PhonePeRequest.swift
//
//
//  Created by Vamsi Madduluri on 29/12/23.
//

import Foundation
import NIO
import NIOFoundationCompat
import NIOHTTP1
import AsyncHTTPClient

internal let PhonePeAPIBase = "https://api.phonepe.com/apis/hermes"
internal let PhonePeAPISandbox = "https://api-preprod.phonepe.com/apis/pg-sandbox"
internal let PhonePeHealthStatusBase: String = "https://uptime.phonepe.com/v1"
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

    var healthbaseUrl: String {
        return PhonePeHealthStatusBase
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
                          body: HTTPClientRequest.Body? = nil,
                          headers: HTTPHeaders) async throws -> T {
        var _headers: HTTPHeaders = ["Content-Type": "application/json",
                                     "Accept": "application/json"]
        headers.forEach { _headers.replaceOrAdd(name: $0.name, value: $0.value) }
        
        let signature = try await Request.generateSignature(path: path, body: body, saltKey: saltKey, saltIndex: saltIndex)
        _headers.add(name: "X-VERIFY", value: signature)
        
        var request = HTTPClientRequest(url: "\(environment.baseUrl)\(path)?\(query)")
        request.headers = _headers
        request.method = method
        request.body = body
        
        let response = try await httpClient.execute(request, timeout: .seconds(60))
        let responseData = try await response.body.collect(upTo: 1024 * 1024 * 100) // 100 MB limit
        
        return try decoder.decode(T.self, from: Data(buffer: responseData))
    }
    
}
