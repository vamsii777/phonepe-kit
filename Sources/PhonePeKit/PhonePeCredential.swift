//
//  PhonePeCredential.swift
//
//
//  Created for PhonePe v2 API support.
//

/// The authentication credential used when initialising ``PhonePeClient``.
///
/// PhonePe supports two authentication schemes:
///
/// ### V1 — HMAC X-VERIFY
/// The legacy scheme signs every request with an HMAC-SHA256 hash derived
/// from the Base64-encoded request body, the endpoint path, and your salt key.
/// The resulting signature is sent in the `X-VERIFY` request header.
///
/// ```swift
/// let credential = PhonePeCredential.v1(saltKey: "your-salt-key", saltIndex: "1")
/// ```
///
/// ### V2 — OAuth2 `O-Bearer`
/// The modern scheme exchanges your `clientId` and `clientSecret` for a short-lived
/// JWT via the `client_credentials` OAuth2 grant, then passes the token in an
/// `Authorization: O-Bearer <token>` header. Token fetching and caching is handled
/// automatically by ``PhonePeClient``.
///
/// ```swift
/// let credential = PhonePeCredential.v2(
///     clientId: "YOUR_CLIENT_ID",
///     clientSecret: "YOUR_CLIENT_SECRET"
/// )
/// ```
///
/// - Note: V2 is the recommended scheme for all new integrations. V1 credentials
///   remain supported for backward compatibility.
public enum PhonePeCredential {
    /// HMAC-based v1 authentication.
    ///
    /// - Parameters:
    ///   - saltKey: The salt key issued by PhonePe for your merchant account.
    ///   - saltIndex: The salt index that identifies which salt key to use (typically `"1"`).
    case v1(saltKey: String, saltIndex: String)

    /// OAuth2 Bearer–based v2 authentication.
    ///
    /// - Parameters:
    ///   - clientId: OAuth2 client identifier issued by PhonePe.
    ///   - clientSecret: OAuth2 client secret issued by PhonePe.
    ///   - clientVersion: Client version integer. Defaults to `1`.
    case v2(clientId: String, clientSecret: String, clientVersion: Int = 1)
}
