//
//  Encodable+Dictionary.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 20/08/2018.
//  Copyright © 2018 Apps Panel. All rights reserved.
//

import Foundation

extension Encodable {

    func asDictionary(jsonEncoder: JSONEncoder = JSONEncoder()) throws -> [String: Any] {
        let data = try jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
    }

}

extension Encodable {

    var dictionary: [String: Any]? {
        let encoder = JSONEncoder.default
        guard let data = try? encoder.encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }

}
