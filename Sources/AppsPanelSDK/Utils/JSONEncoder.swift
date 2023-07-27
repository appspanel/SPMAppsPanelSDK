//
//  JSONEncoder.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 21/06/2019.
//  Copyright © 2019 Apps Panel. All rights reserved.
//

import Foundation

extension JSONEncoder {

    static let `default`: JSONEncoder = {
        let encode = JSONEncoder()
        encode.keyEncodingStrategy = .convertToSnakeCase
        encode.dateEncodingStrategy = .secondsSince1970
        return encode
    }()

}
