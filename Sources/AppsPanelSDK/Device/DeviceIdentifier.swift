//
//  DeviceIdentifier.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 29/08/2018.
//  Copyright © 2018 Apps Panel. All rights reserved.
//

import Foundation
import KeychainAccess
import UIKit

struct DeviceIdentifier {
    
    private static var store = DeviceIdentifierStore()
    
    private static var _identifier: String?

    static func identifier() -> String {
        if let identifier = _identifier {
            return identifier
        } else {
            if usesLegacyIdentifier,
                !isSavedIdentifierLegacy {
                _identifier = legacyIdentifier() ?? ""
            } else if let id = savedIdentifier() {
                _identifier = id
            } else {
                _identifier = randomUUID()
            }
            save()
            return _identifier!
        }
    }
    
    static var usesLegacyIdentifier: Bool = false

    // MARK: Get the identifier
    
    /// Returns an device identifier in the same way the sdk v4 did
    private static func legacyIdentifier() -> String? {
        let id = UIDevice.current.identifierForVendor?.uuidString
        return id?.md5
    }

    private static func savedIdentifier() -> String? {
        return store.deviceUID
    }
    
    private static var isSavedIdentifierLegacy: Bool {
        return store.isDeviceUIDLegacy
    }

    private static func randomUUID() -> String {
        return UUID().uuidString
    }

    // MARK: Save the identifier

    private static func save() {
        guard let id = _identifier,
              !id.isEmpty // The identifier can be empty if it is a legacy identifier
        else {
            return
        }
        
        store.deviceUID = id
        store.isDeviceUIDLegacy = usesLegacyIdentifier
    }
    
}
