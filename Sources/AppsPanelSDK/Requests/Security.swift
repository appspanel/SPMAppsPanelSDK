//
//  Security.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 30/11/2018.
//  Copyright © 2018 Apps Panel. All rights reserved.
//

import Foundation

public struct Security {

    public internal(set) var options: Options = .jsonWebToken
    public internal(set) var usesUserToken: Bool = false
    public internal(set) var secureData: Data?
    public internal(set) var sendJWTAuthorization: Bool = true

}

extension Security {

    public struct Options: OptionSet {

        public typealias RawValue = Int

        public let rawValue: RawValue

        public static let none = Options([])
        public static let jsonWebToken = Options(rawValue: 1 << 0)
        static let encryptRequest = Options(rawValue: 1 << 1)
        static let encryptResponse = Options(rawValue: 1 << 2)

        public static let encryptAll: Options = [.encryptRequest, .encryptResponse]
        public static let all: Options = [.jsonWebToken, .encryptAll]

        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }

    }

}
