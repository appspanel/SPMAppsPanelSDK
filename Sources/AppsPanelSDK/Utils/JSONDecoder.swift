//
//  JSONDecoder.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 14/11/2018.
//  Copyright © 2018 Apps Panel. All rights reserved.
//

import Foundation

extension JSONDecoder {

    static let `default`: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }()

}
