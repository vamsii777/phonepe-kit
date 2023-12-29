//
//  PhonePeAPIRoute.swift
//
//
//  Created by Vamsi Madduluri on 29/12/23.
//

import Foundation
import NIOHTTP1

public protocol PhonePeAPIRoute {
    var headers: HTTPHeaders { get set }
    
    /// Headers to send with the request.
    mutating func addHeaders(_ headers: HTTPHeaders) -> Self
}

extension PhonePeAPIRoute {
    public mutating func addHeaders(_ headers: HTTPHeaders) -> Self {
        headers.forEach { self.headers.replaceOrAdd(name: $0.name, value: $0.value) }
        return self
    }
}
