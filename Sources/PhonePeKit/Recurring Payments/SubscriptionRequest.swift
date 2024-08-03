//
//  SubscriptionRequest.swift
//
//
//  Created by Vamsi Madduluri on 29/12/23.
//

import Foundation

/// Represents a request for creating a subscription.
public struct SubscriptionRequest: Codable {
    public var merchantId: String
    public var merchantSubscriptionId: String
    public var merchantUserId: String
    public var authWorkflowType: AuthWorkflowType
    public var amountType: AmountType
    public var amount: Int // Amount in paise
    public var frequency: Frequency
    public var recurringCount: Int
    public var subMerchantId: String?
    public var mobileNumber: String? // Mandatory for Subscription – PhonePe Intent Flow
    public var deviceContext: DeviceContext?

    /// Initializes a new instance of the `SubscriptionRequest` struct.
    ///
    /// - Parameters:
    ///   - merchantId: The ID of the merchant.
    ///   - merchantSubscriptionId: The ID of the merchant subscription.
    ///   - merchantUserId: The ID of the merchant user.
    ///   - authWorkflowType: The authentication workflow type.
    ///   - amountType: The type of the amount.
    ///   - amount: The amount in paise.
    ///   - frequency: The frequency of the subscription.
    ///   - recurringCount: The number of recurring payments.
    ///   - subMerchantId: The ID of the sub-merchant (optional).
    ///   - mobileNumber: The mobile number (mandatory for subscription with PhonePe Intent Flow) (optional).
    ///   - deviceContext: The device context (optional).
    public init(merchantId: String,
                merchantSubscriptionId: String,
                merchantUserId: String,
                authWorkflowType: AuthWorkflowType,
                amountType: AmountType,
                amount: Int,
                frequency: Frequency,
                recurringCount: Int,
                subMerchantId: String? = nil,
                mobileNumber: String? = nil,
                deviceContext: DeviceContext? = nil) {
        self.merchantId = merchantId
        self.merchantSubscriptionId = merchantSubscriptionId
        self.merchantUserId = merchantUserId
        self.authWorkflowType = authWorkflowType
        self.amountType = amountType
        self.amount = amount
        self.frequency = frequency
        self.recurringCount = recurringCount
        self.subMerchantId = subMerchantId
        self.mobileNumber = mobileNumber
        self.deviceContext = deviceContext
    }
}


public enum AuthWorkflowType: String, Codable {
    case pennyDrop = "PENNY_DROP"
    case transaction = "TRANSACTION"
}

public enum AmountType: String, Codable {
    case fixed = "FIXED"
    case variable = "VARIABLE"
}

public enum Frequency: String, Codable {
    case daily = "DAILY"
    case weekly = "WEEKLY"
    case fortnightly = "FORTNIGHTLY"
    case monthly = "MONTHLY"
    case quarterly = "QUARTERLY"
    case halfyearly = "HALFYEARLY"
    case yearly = "YEARLY"
    case onDemand = "ON_DEMAND"
}

public struct DeviceContext: Codable {
    public var phonePeVersionCode: Int // Mandatory for Subscription – PhonePe Intent Flow

    public init(phonePeVersionCode: Int) {
        self.phonePeVersionCode = phonePeVersionCode
    }
}
