//
//  DeviceIdentifierStore.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 06/01/2022.
//  Copyright © 2022 Apps Panel. All rights reserved.
//

import Foundation
import KeychainAccess

struct DeviceIdentifierStore {
    
    private enum Key {
        static let deviceUID = "APDeviceUID"
        static let isDeviceUIDLegacy = "APDeviceUIDLegacy"
    }
    
    // MARK: -
    
    static let shared = DeviceIdentifierStore()
    
    private let userDefaults = UserDefaults.appsPanel
    
    private let keychain = Keychain.app.synchronizable(false)
    
    // MARK: -
    
    var deviceUID: String? {
        get {
            if let id = keychain[Key.deviceUID] {
                return id
            } else {
                return userDefaults.string(forKey: Key.deviceUID)
            }
        }
        set {
            keychain[Key.deviceUID] = newValue
            userDefaults.set(newValue, forKey: Key.deviceUID)
        }
    }
    
    var isDeviceUIDLegacy: Bool {
        get {
            return userDefaults.bool(forKey: Key.isDeviceUIDLegacy)
        }
        set {
            userDefaults.set(newValue, forKey: Key.isDeviceUIDLegacy)
        }
    }
    
}
