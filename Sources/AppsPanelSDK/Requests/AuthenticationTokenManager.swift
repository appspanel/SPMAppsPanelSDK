//
//  AuthenticationTokenManager.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 19/11/2018.
//  Copyright © 2018 Apps Panel. All rights reserved.
//

import KeychainAccess

public struct AuthenticationTokenManager {

    public enum Error: Swift.Error {
        case emptyToken
    }

    private static let tokenKey = "APToken"

    public static func token() -> String? {
        return Keychain.app[tokenKey]
    }

    public static func saveToken(_ token: String) throws {
        guard !token.isEmpty else {
            throw Error.emptyToken
        }

        return Keychain.app[tokenKey] = token
    }

    public static func deleteToken() {
        return Keychain.app[tokenKey] = nil
    }

}
