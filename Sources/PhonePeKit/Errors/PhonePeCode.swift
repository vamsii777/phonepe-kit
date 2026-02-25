//
//  PhonePeCode.swift
//
//
//  Created by Vamsi Madduluri on 30/12/23.
//

import Foundation

/// All documented PhonePe API error codes plus an ``unknown(_:)`` fallback.
///
/// These codes appear in the `code` field of every PhonePe API JSON response and in
/// ``PhonePeError/code``. The ``unknown(_:)`` case captures any code not listed here
/// so that future PhonePe additions don't break JSON decoding.
///
/// ## Sources
/// - [PhonePe Error Codes Reference](https://developer.phonepe.com/payment-gateway/error-codes)
public enum PhonePeCode: Sendable, Codable, Equatable {

    // MARK: - General success / initiation

    /// Payment session successfully created. User must still complete the flow.
    case PAYMENT_INITIATED
    /// Payment completed successfully.
    case PAYMENT_SUCCESS
    /// Catch-all payment error.
    case PAYMENT_ERROR
    /// Payment is in progress; poll again.
    case PAYMENT_PENDING
    /// Payment was declined.
    case PAYMENT_DECLINED
    /// Generic success for non-payment operations.
    case SUCCESS
    /// Operation is pending; check after 15 minutes.
    case PENDING

    // MARK: - Transaction lifecycle

    /// Transaction not found in PhonePe's system.
    case TRANSACTION_NOT_FOUND
    /// Deprecated alias for ``TRANSACTION_NOT_FOUND`` (some older endpoints).
    case TXN_NOT_FOUND
    /// Transaction was cancelled by the customer.
    case TXN_CANCELLED
    /// Merchant-initiated cancellation.
    case REQUEST_CANCEL_BY_REQUESTER
    /// Customer declined the payment request.
    case REQUEST_DECLINE_BY_REQUESTEE
    /// Payment request timed out before the user acted.
    case REQUEST_TIME_OUT
    /// Payment could not be completed (bank/customer issue).
    case TXN_AUTO_FAILED
    /// Transaction failed.
    case TXN_FAILED
    /// Transaction not completed in time.
    case TXN_NOT_COMPLETED
    /// Customer's transaction limit exceeded.
    case TXN_LIMIT_BREACHED
    /// Customer's daily transaction frequency limit exceeded.
    case TXN_FREQ_LIMIT_BREACHED
    /// Payment blocked (security, compliance, or bank rule).
    case TXN_BLOCKED
    /// Transaction is not allowed for this customer or context.
    case TXN_NOT_ALLOWED
    /// Global request timeout.
    case TIMED_OUT
    /// Amount mismatch between request and processor.
    case TXN_AMOUNT_MISMATCH
    /// The original payment request was not found (UPI collect).
    case REQUEST_NOT_FOUND
    /// A payment with the same order ID is already in progress.
    case DUPLICATE_TRANSACTION
    /// Order expired before the user completed payment.
    case ORDER_EXPIRED
    /// Customer cancelled the order on PhonePe's UI.
    case ORDER_CANCELLED_BY_USER

    // MARK: - Authentication & authorisation

    /// Authentication with the bank or payment processor failed.
    case AUTHENTICATION_FAILED
    /// OAuth2 or merchant API key authorisation failed.
    case AUTHORIZATION_FAILED
    /// Salt key / merchant key not configured in PhonePe.
    case KEY_NOT_CONFIGURED
    /// Customer entered incorrect UPI PIN.
    case INVALID_MPIN
    /// Customer exceeded max incorrect PIN attempts.
    case MPIN_LIMIT_BREACHED
    /// Customer has not set a UPI PIN.
    case MPIN_NOT_SET
    /// Bank-side authentication timeout.
    case AUTH_TIMEOUT
    /// Bank-level hash mismatch.
    case HASH_MISMATCH
    /// Max authentication attempts exceeded (card flows).
    case MAX_AUTH_EXCEEDED

    // MARK: - Card errors

    /// Invalid or incorrectly entered card number.
    case INVALID_CARD_NUMBER
    /// Invalid card details provided.
    case INVALID_CARD_DETAILS
    /// Incorrect or expired CVV.
    case INVALID_CVV_EXPIRY
    /// Customer's card is blocked by their bank.
    case CARD_BLOCKED
    /// Customer's card is expired.
    case CARD_EXPIRED
    /// Unsupported card category for this merchant.
    case INVALID_CARD_TYPE
    /// Card BIN is not supported for this payment.
    case CARD_BIN_NOT_SUPPORTED
    /// Incorrect card name entered.
    case INVALID_CARD_NAME
    /// Invalid card reference.
    case INVALID_CARD
    /// Incorrect OTP or PIN entered (card flows).
    case WRONG_PIN
    /// Customer's card does not allow online transactions.
    case ONLINE_TRANSACTIONS_DISABLED
    /// Customer's card does not support international payments.
    case INTERNATIONAL_TXN_NOT_ALLOWED

    // MARK: - Account & balance

    /// Insufficient funds in the customer's account.
    case INSUFFICIENT_BALANCE
    /// Customer's account type is not eligible for this payment.
    case ACCOUNT_NOT_ELIGIBLE
    /// Customer's bank account is blocked or frozen.
    case ACCOUNT_BLOCKED
    /// Invalid or unregistered account number.
    case ACCOUNT_DOES_NOT_EXIST
    /// Customer's bank account is inactive.
    case ACCOUNT_INACTIVE
    /// Customer is blacklisted.
    case USER_BLACKLISTED

    // MARK: - Bank / processor errors

    /// Generic bank-side technical malfunction.
    case BANK_TECHNICAL_ISSUE
    /// Bank returned a generic error.
    case BANK_ERROR
    /// Bank processing failure (cannot process).
    case BANK_NOT_ABLE_TO_PROCESS
    /// Bank's merchant configuration is missing or incorrect.
    case BANK_MERCHANT_CONFIG
    /// Bank-side technical issue (generic).
    case TECHNICAL_ISSUE_BANK
    /// Bank declined the transaction.
    case TRANSACTION_DECLINED
    /// Payment gateway declined the transaction.
    case TRANSACTION_DECLINED_PG
    /// Bank doesn't support the requested payment method.
    case UNSUPPORTED_PAYMENT_MODE
    /// Customer's bank blocks payments matching business risk rules.
    case BUSINESS_RISK_RULES
    /// Payment gateway processor error.
    case PROCESSOR_ERROR
    /// Internal security block (generic).
    case INTERNAL_SECURITY_BLOCK
    /// Invalid UPI ID entered by the customer.
    case INVALID_VPA
    /// Device fingerprint mismatch (temporary issue).
    case DEVICE_FINGERPRINT_MISMATCH

    // MARK: - Request / parameter errors

    /// Malformed or missing request parameters.
    case BAD_REQUEST
    /// Invalid request (general).
    case INVALID_REQUEST
    /// Invalid fields in the request.
    case INVALID_FIELDS
    /// Invalid amount value.
    case INVALID_AMOUNT
    /// Invalid currency provided.
    case INVALID_CURRENCY
    /// Invalid transaction ID.
    case INVALID_TXN_ID
    /// Invalid transaction.
    case INVALID_TXN
    /// Invalid date provided.
    case INVALID_DATE
    /// Invalid bank code.
    case INVALID_BANK_CODE
    /// Invalid parameters provided.
    case INVALID_PARAMETERS
    /// Invalid customer identifier.
    case INVALID_CUSTOMER_ID
    /// Invalid details provided by the merchant.
    case INVALID_DETAILS_MERCHANT
    /// Invalid details provided by the customer.
    case INVALID_DETAILS
    /// Address mismatch with bank records.
    case ADDRESS_MISMATCH
    /// Merchant configuration not found or incorrect.
    case MERCHANT_CONFIG_NOT_FOUND
    /// Merchant-side technical issue.
    case MERCHANT_ERROR

    // MARK: - Refund

    /// Insufficient balance to process the refund.
    case REFUND_BREACHED

    // MARK: - Cryptography / checksums

    /// Checksum mismatch.
    case CHECKSUM_MISMATCH
    /// Invalid encryption key.
    case INVALID_KEY
    /// Encryption processing error.
    case ENCRYPTION_ERROR
    /// Decryption processing error.
    case DECRYPTION_ERROR

    // MARK: - System / network

    /// Internal server error on PhonePe's side.
    case INTERNAL_SERVER_ERROR
    /// Connection timeout.
    case CONNECTION_TIMEOUT
    /// Transaction timed out.
    case TRANSACTION_TIME_OUT
    /// Customer cancelled or did not complete authentication.
    case CANCELLED_BY_USER
    /// Customer's transaction limit exceeded (card flows).
    case TRANSACTION_LIMIT_EXCEEDED
    /// NPCI generic error.
    case GENERIC_NPCI_ERROR
    /// Generic temporary technical error.
    case GENERIC_ERROR
    /// Technical issue (general).
    case TECHNICAL_ISSUE

    // MARK: - SDK-internal

    /// The server returned an empty response body.
    ///
    /// This is an SDK-internal code not returned by PhonePe; it is synthesised
    /// when the response body has zero readable bytes.
    case EMPTY_RESPONSE

    // MARK: - Unknown / future codes

    /// A code returned by PhonePe that is not yet listed in this enum.
    ///
    /// This case ensures that unknown or future error codes don't crash JSON
    /// decoding. Inspect the associated value to read the raw code string.
    case unknown(String)

    // MARK: - Codable

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        self = PhonePeCode(rawValue: raw) ?? .unknown(raw)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    /// The raw string value as returned by the PhonePe API.
    public var rawValue: String {
        switch self {
        case .PAYMENT_INITIATED: return "PAYMENT_INITIATED"
        case .PAYMENT_SUCCESS: return "PAYMENT_SUCCESS"
        case .PAYMENT_ERROR: return "PAYMENT_ERROR"
        case .PAYMENT_PENDING: return "PAYMENT_PENDING"
        case .PAYMENT_DECLINED: return "PAYMENT_DECLINED"
        case .SUCCESS: return "SUCCESS"
        case .PENDING: return "PENDING"
        case .TRANSACTION_NOT_FOUND: return "TRANSACTION_NOT_FOUND"
        case .TXN_NOT_FOUND: return "TXN_NOT_FOUND"
        case .TXN_CANCELLED: return "TXN_CANCELLED"
        case .REQUEST_CANCEL_BY_REQUESTER: return "REQUEST_CANCEL_BY_REQUESTER"
        case .REQUEST_DECLINE_BY_REQUESTEE: return "REQUEST_DECLINE_BY_REQUESTEE"
        case .REQUEST_TIME_OUT: return "REQUEST_TIME_OUT"
        case .TXN_AUTO_FAILED: return "TXN_AUTO_FAILED"
        case .TXN_FAILED: return "TXN_FAILED"
        case .TXN_NOT_COMPLETED: return "TXN_NOT_COMPLETED"
        case .TXN_LIMIT_BREACHED: return "TXN_LIMIT_BREACHED"
        case .TXN_FREQ_LIMIT_BREACHED: return "TXN_FREQ_LIMIT_BREACHED"
        case .TXN_BLOCKED: return "TXN_BLOCKED"
        case .TXN_NOT_ALLOWED: return "TXN_NOT_ALLOWED"
        case .TIMED_OUT: return "TIMED_OUT"
        case .TXN_AMOUNT_MISMATCH: return "TXN_AMOUNT_MISMATCH"
        case .REQUEST_NOT_FOUND: return "REQUEST_NOT_FOUND"
        case .DUPLICATE_TRANSACTION: return "DUPLICATE_TRANSACTION"
        case .ORDER_EXPIRED: return "ORDER_EXPIRED"
        case .ORDER_CANCELLED_BY_USER: return "ORDER_CANCELLED_BY_USER"
        case .AUTHENTICATION_FAILED: return "AUTHENTICATION_FAILED"
        case .AUTHORIZATION_FAILED: return "AUTHORIZATION_FAILED"
        case .KEY_NOT_CONFIGURED: return "KEY_NOT_CONFIGURED"
        case .INVALID_MPIN: return "INVALID_MPIN"
        case .MPIN_LIMIT_BREACHED: return "MPIN_LIMIT_BREACHED"
        case .MPIN_NOT_SET: return "MPIN_NOT_SET"
        case .AUTH_TIMEOUT: return "AUTH_TIMEOUT"
        case .HASH_MISMATCH: return "HASH_MISMATCH"
        case .MAX_AUTH_EXCEEDED: return "MAX_AUTH_EXCEEDED"
        case .INVALID_CARD_NUMBER: return "INVALID_CARD_NUMBER"
        case .INVALID_CARD_DETAILS: return "INVALID_CARD_DETAILS"
        case .INVALID_CVV_EXPIRY: return "INVALID_CVV_EXPIRY"
        case .CARD_BLOCKED: return "CARD_BLOCKED"
        case .CARD_EXPIRED: return "CARD_EXPIRED"
        case .INVALID_CARD_TYPE: return "INVALID_CARD_TYPE"
        case .CARD_BIN_NOT_SUPPORTED: return "CARD_BIN_NOT_SUPPORTED"
        case .INVALID_CARD_NAME: return "INVALID_CARD_NAME"
        case .INVALID_CARD: return "INVALID_CARD"
        case .WRONG_PIN: return "WRONG_PIN"
        case .ONLINE_TRANSACTIONS_DISABLED: return "ONLINE_TRANSACTIONS_DISABLED"
        case .INTERNATIONAL_TXN_NOT_ALLOWED: return "INTERNATIONAL_TXN_NOT_ALLOWED"
        case .INSUFFICIENT_BALANCE: return "INSUFFICIENT_BALANCE"
        case .ACCOUNT_NOT_ELIGIBLE: return "ACCOUNT_NOT_ELIGIBLE"
        case .ACCOUNT_BLOCKED: return "ACCOUNT_BLOCKED"
        case .ACCOUNT_DOES_NOT_EXIST: return "ACCOUNT_DOES_NOT_EXIST"
        case .ACCOUNT_INACTIVE: return "ACCOUNT_INACTIVE"
        case .USER_BLACKLISTED: return "USER_BLACKLISTED"
        case .BANK_TECHNICAL_ISSUE: return "BANK_TECHNICAL_ISSUE"
        case .BANK_ERROR: return "BANK_ERROR"
        case .BANK_NOT_ABLE_TO_PROCESS: return "BANK_NOT_ABLE_TO_PROCESS"
        case .BANK_MERCHANT_CONFIG: return "BANK_MERCHANT_CONFIG"
        case .TECHNICAL_ISSUE_BANK: return "TECHNICAL_ISSUE_BANK"
        case .TRANSACTION_DECLINED: return "TRANSACTION_DECLINED"
        case .TRANSACTION_DECLINED_PG: return "TRANSACTION_DECLINED_PG"
        case .UNSUPPORTED_PAYMENT_MODE: return "UNSUPPORTED_PAYMENT_MODE"
        case .BUSINESS_RISK_RULES: return "BUSINESS_RISK_RULES"
        case .PROCESSOR_ERROR: return "PROCESSOR_ERROR"
        case .INTERNAL_SECURITY_BLOCK: return "INTERNAL_SECURITY_BLOCK"
        case .INVALID_VPA: return "INVALID_VPA"
        case .DEVICE_FINGERPRINT_MISMATCH: return "DEVICE_FINGERPRINT_MISMATCH"
        case .BAD_REQUEST: return "BAD_REQUEST"
        case .INVALID_REQUEST: return "INVALID_REQUEST"
        case .INVALID_FIELDS: return "INVALID_FIELDS"
        case .INVALID_AMOUNT: return "INVALID_AMOUNT"
        case .INVALID_CURRENCY: return "INVALID_CURRENCY"
        case .INVALID_TXN_ID: return "INVALID_TXN_ID"
        case .INVALID_TXN: return "INVALID_TXN"
        case .INVALID_DATE: return "INVALID_DATE"
        case .INVALID_BANK_CODE: return "INVALID_BANK_CODE"
        case .INVALID_PARAMETERS: return "INVALID_PARAMETERS"
        case .INVALID_CUSTOMER_ID: return "INVALID_CUSTOMER_ID"
        case .INVALID_DETAILS_MERCHANT: return "INVALID_DETAILS_MERCHANT"
        case .INVALID_DETAILS: return "INVALID_DETAILS"
        case .ADDRESS_MISMATCH: return "ADDRESS_MISMATCH"
        case .MERCHANT_CONFIG_NOT_FOUND: return "MERCHANT_CONFIG_NOT_FOUND"
        case .MERCHANT_ERROR: return "MERCHANT_ERROR"
        case .REFUND_BREACHED: return "REFUND_BREACHED"
        case .CHECKSUM_MISMATCH: return "CHECKSUM_MISMATCH"
        case .INVALID_KEY: return "INVALID_KEY"
        case .ENCRYPTION_ERROR: return "ENCRYPTION_ERROR"
        case .DECRYPTION_ERROR: return "DECRYPTION_ERROR"
        case .INTERNAL_SERVER_ERROR: return "INTERNAL_SERVER_ERROR"
        case .CONNECTION_TIMEOUT: return "CONNECTION_TIMEOUT"
        case .TRANSACTION_TIME_OUT: return "TRANSACTION_TIME_OUT"
        case .CANCELLED_BY_USER: return "CANCELLED_BY_USER"
        case .TRANSACTION_LIMIT_EXCEEDED: return "TRANSACTION_LIMIT_EXCEEDED"
        case .GENERIC_NPCI_ERROR: return "GENERIC_NPCI_ERROR"
        case .GENERIC_ERROR: return "GENERIC_ERROR"
        case .TECHNICAL_ISSUE: return "TECHNICAL_ISSUE"
        case .EMPTY_RESPONSE: return "EMPTY_RESPONSE"
        case .unknown(let raw): return raw
        }
    }

    /// Creates a `PhonePeCode` from its raw string value.
    ///
    /// Returns `nil` for the ``unknown(_:)`` case (use the `Decodable` initialiser
    /// for resilient decoding that maps unknowns to ``unknown(_:)``).
    public init?(rawValue: String) {
        switch rawValue {
        case "PAYMENT_INITIATED": self = .PAYMENT_INITIATED
        case "PAYMENT_SUCCESS": self = .PAYMENT_SUCCESS
        case "PAYMENT_ERROR": self = .PAYMENT_ERROR
        case "PAYMENT_PENDING": self = .PAYMENT_PENDING
        case "PAYMENT_DECLINED": self = .PAYMENT_DECLINED
        case "SUCCESS": self = .SUCCESS
        case "PENDING": self = .PENDING
        case "TRANSACTION_NOT_FOUND": self = .TRANSACTION_NOT_FOUND
        case "TXN_NOT_FOUND": self = .TXN_NOT_FOUND
        case "TXN_CANCELLED": self = .TXN_CANCELLED
        case "REQUEST_CANCEL_BY_REQUESTER": self = .REQUEST_CANCEL_BY_REQUESTER
        case "REQUEST_DECLINE_BY_REQUESTEE": self = .REQUEST_DECLINE_BY_REQUESTEE
        case "REQUEST_TIME_OUT": self = .REQUEST_TIME_OUT
        case "TXN_AUTO_FAILED": self = .TXN_AUTO_FAILED
        case "TXN_FAILED": self = .TXN_FAILED
        case "TXN_NOT_COMPLETED": self = .TXN_NOT_COMPLETED
        case "TXN_LIMIT_BREACHED": self = .TXN_LIMIT_BREACHED
        case "TXN_FREQ_LIMIT_BREACHED": self = .TXN_FREQ_LIMIT_BREACHED
        case "TXN_BLOCKED": self = .TXN_BLOCKED
        case "TXN_NOT_ALLOWED": self = .TXN_NOT_ALLOWED
        case "TIMED_OUT": self = .TIMED_OUT
        case "TXN_AMOUNT_MISMATCH": self = .TXN_AMOUNT_MISMATCH
        case "REQUEST_NOT_FOUND": self = .REQUEST_NOT_FOUND
        case "DUPLICATE_TRANSACTION": self = .DUPLICATE_TRANSACTION
        case "ORDER_EXPIRED": self = .ORDER_EXPIRED
        case "ORDER_CANCELLED_BY_USER": self = .ORDER_CANCELLED_BY_USER
        case "AUTHENTICATION_FAILED": self = .AUTHENTICATION_FAILED
        case "AUTHORIZATION_FAILED": self = .AUTHORIZATION_FAILED
        case "KEY_NOT_CONFIGURED": self = .KEY_NOT_CONFIGURED
        case "INVALID_MPIN": self = .INVALID_MPIN
        case "MPIN_LIMIT_BREACHED": self = .MPIN_LIMIT_BREACHED
        case "MPIN_NOT_SET": self = .MPIN_NOT_SET
        case "AUTH_TIMEOUT": self = .AUTH_TIMEOUT
        case "HASH_MISMATCH": self = .HASH_MISMATCH
        case "MAX_AUTH_EXCEEDED": self = .MAX_AUTH_EXCEEDED
        case "INVALID_CARD_NUMBER": self = .INVALID_CARD_NUMBER
        case "INVALID_CARD_DETAILS": self = .INVALID_CARD_DETAILS
        case "INVALID_CVV_EXPIRY": self = .INVALID_CVV_EXPIRY
        case "CARD_BLOCKED": self = .CARD_BLOCKED
        case "CARD_EXPIRED": self = .CARD_EXPIRED
        case "INVALID_CARD_TYPE": self = .INVALID_CARD_TYPE
        case "CARD_BIN_NOT_SUPPORTED": self = .CARD_BIN_NOT_SUPPORTED
        case "INVALID_CARD_NAME": self = .INVALID_CARD_NAME
        case "INVALID_CARD": self = .INVALID_CARD
        case "WRONG_PIN": self = .WRONG_PIN
        case "ONLINE_TRANSACTIONS_DISABLED": self = .ONLINE_TRANSACTIONS_DISABLED
        case "INTERNATIONAL_TXN_NOT_ALLOWED": self = .INTERNATIONAL_TXN_NOT_ALLOWED
        case "INSUFFICIENT_BALANCE": self = .INSUFFICIENT_BALANCE
        case "ACCOUNT_NOT_ELIGIBLE": self = .ACCOUNT_NOT_ELIGIBLE
        case "ACCOUNT_BLOCKED": self = .ACCOUNT_BLOCKED
        case "ACCOUNT_DOES_NOT_EXIST": self = .ACCOUNT_DOES_NOT_EXIST
        case "ACCOUNT_INACTIVE": self = .ACCOUNT_INACTIVE
        case "USER_BLACKLISTED": self = .USER_BLACKLISTED
        case "BANK_TECHNICAL_ISSUE": self = .BANK_TECHNICAL_ISSUE
        case "BANK_ERROR": self = .BANK_ERROR
        case "BANK_NOT_ABLE_TO_PROCESS": self = .BANK_NOT_ABLE_TO_PROCESS
        case "BANK_MERCHANT_CONFIG": self = .BANK_MERCHANT_CONFIG
        case "TECHNICAL_ISSUE_BANK": self = .TECHNICAL_ISSUE_BANK
        case "TRANSACTION_DECLINED": self = .TRANSACTION_DECLINED
        case "TRANSACTION_DECLINED_PG": self = .TRANSACTION_DECLINED_PG
        case "UNSUPPORTED_PAYMENT_MODE": self = .UNSUPPORTED_PAYMENT_MODE
        case "BUSINESS_RISK_RULES": self = .BUSINESS_RISK_RULES
        case "PROCESSOR_ERROR": self = .PROCESSOR_ERROR
        case "INTERNAL_SECURITY_BLOCK": self = .INTERNAL_SECURITY_BLOCK
        case "INVALID_VPA": self = .INVALID_VPA
        case "DEVICE_FINGERPRINT_MISMATCH": self = .DEVICE_FINGERPRINT_MISMATCH
        case "BAD_REQUEST": self = .BAD_REQUEST
        case "INVALID_REQUEST": self = .INVALID_REQUEST
        case "INVALID_FIELDS": self = .INVALID_FIELDS
        case "INVALID_AMOUNT": self = .INVALID_AMOUNT
        case "INVALID_CURRENCY": self = .INVALID_CURRENCY
        case "INVALID_TXN_ID": self = .INVALID_TXN_ID
        case "INVALID_TXN": self = .INVALID_TXN
        case "INVALID_DATE": self = .INVALID_DATE
        case "INVALID_BANK_CODE": self = .INVALID_BANK_CODE
        case "INVALID_PARAMETERS": self = .INVALID_PARAMETERS
        case "INVALID_CUSTOMER_ID": self = .INVALID_CUSTOMER_ID
        case "INVALID_DETAILS_MERCHANT": self = .INVALID_DETAILS_MERCHANT
        case "INVALID_DETAILS": self = .INVALID_DETAILS
        case "ADDRESS_MISMATCH": self = .ADDRESS_MISMATCH
        case "MERCHANT_CONFIG_NOT_FOUND": self = .MERCHANT_CONFIG_NOT_FOUND
        case "MERCHANT_ERROR": self = .MERCHANT_ERROR
        case "REFUND_BREACHED": self = .REFUND_BREACHED
        case "CHECKSUM_MISMATCH": self = .CHECKSUM_MISMATCH
        case "INVALID_KEY": self = .INVALID_KEY
        case "ENCRYPTION_ERROR": self = .ENCRYPTION_ERROR
        case "DECRYPTION_ERROR": self = .DECRYPTION_ERROR
        case "INTERNAL_SERVER_ERROR": self = .INTERNAL_SERVER_ERROR
        case "CONNECTION_TIMEOUT": self = .CONNECTION_TIMEOUT
        case "TRANSACTION_TIME_OUT": self = .TRANSACTION_TIME_OUT
        case "CANCELLED_BY_USER": self = .CANCELLED_BY_USER
        case "TRANSACTION_LIMIT_EXCEEDED": self = .TRANSACTION_LIMIT_EXCEEDED
        case "GENERIC_NPCI_ERROR": self = .GENERIC_NPCI_ERROR
        case "GENERIC_ERROR": self = .GENERIC_ERROR
        case "TECHNICAL_ISSUE": self = .TECHNICAL_ISSUE
        case "EMPTY_RESPONSE": self = .EMPTY_RESPONSE
        default: return nil
        }
    }
}
