//
//  ValidateOptionsStubsV2.swift
//
//
//  Created for PhonePe v2 API support.
//

import Foundation
import NIOHTTP1

/// Stub conformance of ``ValidateRoutes`` for v2 clients.
///
/// VPA (Virtual Payment Address) validation is a v1-only feature.
/// The PhonePe v2 API does not expose an equivalent endpoint.
///
/// Calling ``vpa(request:)`` on a v2 ``PhonePeClient`` will always throw a
/// ``PhonePeError`` with a descriptive message. If you need VPA validation,
/// create a v1 client using ``PhonePeCredential/v1(saltKey:saltIndex:)``.
public struct PhonePeValidateRoutesV2: ValidateRoutes {

    /// Additional HTTP headers (unused; present for protocol conformance).
    public var headers: HTTPHeaders = [:]

    /// Always throws — VPA validation is not available in v2 mode.
    ///
    /// - Throws: ``PhonePeError`` with `code` `.BAD_REQUEST` and a message
    ///   explaining that this method requires a v1 client.
    public func vpa(request: VPAValidateRequest) async throws -> PhonePeResponse<VPAValidateResponse> {
        throw PhonePeError(
            success: false,
            code: .BAD_REQUEST,
            message: "VPA validation is not available in v2 mode. Use a v1 client (PhonePeCredential.v1) for this feature."
        )
    }
}

/// Stub conformance of ``OptionsRoutes`` for v2 clients.
///
/// The payment options discovery endpoint is a v1-only feature.
/// The PhonePe v2 API does not expose an equivalent endpoint.
///
/// Calling ``payment(merchantId:)`` on a v2 ``PhonePeClient`` will always throw a
/// ``PhonePeError`` with a descriptive message. If you need payment options, create a
/// v1 client using ``PhonePeCredential/v1(saltKey:saltIndex:)``.
public struct PhonePeOptionsRoutesV2: OptionsRoutes {

    /// Additional HTTP headers (unused; present for protocol conformance).
    public var headers: HTTPHeaders = [:]

    /// Always throws — payment options discovery is not available in v2 mode.
    ///
    /// - Throws: ``PhonePeError`` with `code` `.BAD_REQUEST` and a message
    ///   explaining that this method requires a v1 client.
    public func payment(merchantId: String) async throws -> PhonePeResponse<PaymentOptionsResponse> {
        throw PhonePeError(
            success: false,
            code: .BAD_REQUEST,
            message: "Payment options discovery is not available in v2 mode. Use a v1 client (PhonePeCredential.v1) for this feature."
        )
    }
}
