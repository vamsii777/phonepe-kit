//
//  PhonePeClient.swift
//
//
//  Created by Vamsi Madduluri on 29/12/23.
//

import NIO
import AsyncHTTPClient

public final class PhonePeClient {
    // MARK: - Core Resources
    public var subscriptions: PhonePeSubscriptionRoutes

    // MARK: - Additional Functionalities
    // ... other functionalities like balances, users, etc.

    var handler: PhonePeAPIHandler

    // Assuming Environment is a publicly accessible enum
    public init(httpClient: HTTPClient, saltKey: String, saltIndex: String, environment: Environment) {
        handler = PhonePeAPIHandler(httpClient: httpClient, saltKey: saltKey, saltIndex: saltIndex, environment: environment)

        // Instantiate PhonePeSubscriptionRoutes instead of SubscriptionRoutes
        subscriptions = PhonePeSubscriptionRoutes(apiHandler: handler, baseUrl: environment.baseUrl)
        // ... initialize other routes
    }
}
