//
//  PhonePeClient.swift
//
//
//  Created by Vamsi Madduluri on 29/12/23.
//

import NIO
import AsyncHTTPClient

/// The main client class for interacting with the PhonePe API.
public final class PhonePeClient {

    /// The routes for managing subscriptions.
    public var subscriptions: PhonePeSubscriptionRoutes
    
    /// The routes for making payments.
    public var payments: PhonePePayRoutes
    
    /// The routes for checking payment status.
    public var checkstatus: PhonePeCheckStatusRoutes
    
    /// The routes for other PhonePe operations.
    public var other: PhonePeOtherRoutes
    
    /// The routes for performing health checks.
    public var healthcheck: PhonePeHealthCheckRoutes
    
    var handler: PhonePeAPIHandler

    /// Initializes a new instance of the `PhonePeClient` class.
    /// - Parameters:
    ///   - httpClient: The HTTP client to use for making API requests.
    ///   - saltKey: The salt key for API authentication.
    ///   - saltIndex: The salt index for API authentication.
    ///   - environment: The environment configuration for the API.
    public init(httpClient: HTTPClient, saltKey: String, saltIndex: String, environment: Environment) {
        handler = PhonePeAPIHandler(httpClient: httpClient, saltKey: saltKey, saltIndex: saltIndex, environment: environment)
        subscriptions = PhonePeSubscriptionRoutes(apiHandler: handler, baseUrl: environment.baseUrl)
        payments = PhonePePayRoutes(apiHandler: handler, baseUrl: environment.baseUrl)
        checkstatus = PhonePeCheckStatusRoutes(apiHandler: handler, baseUrl: environment.baseUrl)
        healthcheck = PhonePeHealthCheckRoutes(apiHandler: handler, baseUrl: environment.healthbaseUrl)
        other = PhonePeOtherRoutes(apiHandler: handler, baseUrl: environment.baseUrl)
    }
}
