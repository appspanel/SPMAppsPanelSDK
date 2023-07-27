//
//  NullEncodable.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 15/04/2021.
//  Copyright © 2021 Apps Panel. All rights reserved.
//

import Foundation

@propertyWrapper
struct NullEncodable<T>: Encodable where T: Encodable {
    
    var wrappedValue: T?

    init(wrappedValue: T?) {
        self.wrappedValue = wrappedValue
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch wrappedValue {
        case .some(let value):
            try container.encode(value)
        case .none:
            try container.encodeNil()
        }
    }
    
}

extension NullEncodable: Decodable where T: Decodable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = try container.decode(T.self)
    }
    
}
