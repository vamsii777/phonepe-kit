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

/// This file contains the implementation of the `PhonePeAPIHandler` struct and the `Environment` enum.
/// The `PhonePeAPIHandler` struct is responsible for sending HTTP requests to the PhonePe API.
/// The `Environment` enum defines the different environments (production, sandbox, and health) and their corresponding base URLs.

internal let PhonePeAPIBase = "https://api.phonepe.com/apis/hermes"
internal let PhonePeAPISandbox = "https://api-preprod.phonepe.com/apis/pg-sandbox"
internal let PhonePeHealthStatusBase: String = "https://uptime.phonepe.com"

/// Enum representing the different environments for the PhonePe API.
public enum Environment {
    case production
    case sandbox
    case health
    
    /// Returns the base URL for the environment.
    var baseUrl: String {
        switch self {
        case .production:
            return PhonePeAPIBase
        case .sandbox:
            return PhonePeAPISandbox
        case .health:
            return PhonePeHealthStatusBase
        }
    }
    
    /// Returns the base URL for the health environment.
    var healthbaseUrl: String {
        return PhonePeHealthStatusBase
    }
}

extension HTTPClientRequest.Body {
    /// Creates an HTTP request body from a string.
    ///
    /// - Parameter string: The string to be used as the request body.
    /// - Returns: An `HTTPClientRequest.Body` instance.
    public static func string(_ string: String) -> Self {
        .bytes(.init(string: string))
    }
    
    /// Creates an HTTP request body from data.
    ///
    /// - Parameter data: The data to be used as the request body.
    /// - Returns: An `HTTPClientRequest.Body` instance.
    public static func data(_ data: Data) -> Self {
        .bytes(.init(data: data))
    }
}

/// Struct responsible for handling API requests to PhonePe.
struct PhonePeAPIHandler {
    private let httpClient: HTTPClient
    private let saltKey: String
    private let saltIndex: String
    private let environment: Environment
    private let decoder: JSONDecoder
    
    /// Initializes a `PhonePeAPIHandler` instance.
    ///
    /// - Parameters:
    ///   - httpClient: The HTTP client to be used for making requests.
    ///   - saltKey: The salt key used for generating the request signature.
    ///   - saltIndex: The salt index used for generating the request signature.
    ///   - environment: The environment for the API requests.
    init(httpClient: HTTPClient, saltKey: String, saltIndex: String, environment: Environment) {
        self.httpClient = httpClient
        self.saltKey = saltKey
        self.saltIndex = saltIndex
        self.environment = environment
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .secondsSince1970
    }
    
    /// Sends an API request and returns the decoded response.
    ///
    /// - Parameters:
    ///   - method: The HTTP method for the request.
    ///   - path: The path for the request.
    ///   - query: The query string for the request.
    ///   - body: The request body.
    ///   - headers: Additional headers for the request.
    /// - Returns: The decoded response object of type `T`.
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
