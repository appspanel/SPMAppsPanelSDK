//
//  Keychain.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 29/08/2018.
//  Copyright © 2018 Apps Panel. All rights reserved.
//

import KeychainAccess
import UIKit

extension Keychain {

    static var sdk: Keychain {
        return Keychain(service: "com.appspanel.sdk")
    }

    static var app: Keychain = {
        if let appBundleID = Bundle.main.bundleIdentifier {
            let service = "\(appBundleID).appspanel-token"
            return Keychain(service: service)
        }
        return Keychain()
    }()

}
