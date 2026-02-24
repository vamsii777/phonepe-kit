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
    public var status: PhonePeStatusRoutes
    
    /// The routes for validating VPA and similar.
    public var validate: PhonePeValidateRoutes

    /// The routes for fetching payment options.
    public var options: PhonePeOptionsRoutes
    
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
        status = PhonePeStatusRoutes(apiHandler: handler, baseUrl: environment.baseUrl, healthBaseUrl: environment.healthbaseUrl)
        validate = PhonePeValidateRoutes(apiHandler: handler, baseUrl: environment.baseUrl)
        options = PhonePeOptionsRoutes(apiHandler: handler, baseUrl: environment.baseUrl)
    }
}
