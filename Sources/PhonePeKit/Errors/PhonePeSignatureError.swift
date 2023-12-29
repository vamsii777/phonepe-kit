//
//  PhonePeSignatureError.swift
//
//
//  Created by Vamsi Madduluri on 29/12/23.
//

/// An error returned when verifying signatures for PhonePe webhooks.
public enum PhonePeSignatureError: Error, CustomStringConvertible {
    public var description: String {
        switch self {
        case .unableToParseHeader:
            return "The supplied header could not be parsed in the appropriate format 't=xxx,v1=yyy'."
        case .noMatchingSignatureFound:
            return "No signatures were found that matched the expected signature."
        case .timestampNotTolerated:
            return "The timestamp was outside of the tolerated time difference."
        }
    }

    /// The supplied header could not be parsed in the appropriate format 't=xxx,v1=yyy'.
    case unableToParseHeader
    /// No signatures were found that matched the expected signature.
    case noMatchingSignatureFound
    /// The timestamp was outside of the tolerated time difference.
    case timestampNotTolerated
}
