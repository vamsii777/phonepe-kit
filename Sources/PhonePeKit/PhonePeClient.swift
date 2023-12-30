//
//  PhonePeClient.swift
//
//
//  Created by Vamsi Madduluri on 29/12/23.
//

import NIO
import AsyncHTTPClient

public final class PhonePeClient {

    public var subscriptions: PhonePeSubscriptionRoutes
    public var payments: PhonePePayRoutes
    
    var handler: PhonePeAPIHandler

    public init(httpClient: HTTPClient, saltKey: String, saltIndex: String, environment: Environment) {
        handler = PhonePeAPIHandler(httpClient: httpClient, saltKey: saltKey, saltIndex: saltIndex, environment: environment)
    
        subscriptions = PhonePeSubscriptionRoutes(apiHandler: handler, baseUrl: environment.baseUrl)
        payments = PhonePePayRoutes(apiHandler: handler, baseUrl: environment.baseUrl)
        
    }
}
