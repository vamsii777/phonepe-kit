//
//  PhonePeAPIRoute.swift
//
//
//  Created by Vamsi Madduluri on 29/12/23.
//

import Foundation
import NIOHTTP1

/// A protocol that defines the structure of a PhonePe API route.
public protocol PhonePeAPIRoute {
    /// The headers to be sent with the request.
    var headers: HTTPHeaders { get set }
    
    /// Adds the specified headers to the existing headers.
    /// - Parameter headers: The headers to be added.
    /// - Returns: The updated instance of `PhonePeAPIRoute`.
    mutating func addHeaders(_ headers: HTTPHeaders) -> Self
}

extension PhonePeAPIRoute {
    /// Adds the specified headers to the existing headers.
    /// - Parameter headers: The headers to be added.
    /// - Returns: The updated instance of `PhonePeAPIRoute`.
    public mutating func addHeaders(_ headers: HTTPHeaders) -> Self {
        headers.forEach { self.headers.replaceOrAdd(name: $0.name, value: $0.value) }
        return self
    }
}
