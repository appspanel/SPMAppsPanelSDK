//
//  TextManagerStorage.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 15/04/2021.
//  Copyright © 2021 Apps Panel. All rights reserved.
//

import Foundation

struct TextManagerStorage {
    
    private enum Key {
        static let forcedLanguage = "TextManagerForcedLanguage"
    }
    
    // MARK: - 
    
    static let shared = TextManagerStorage()
    
    private let userDefaults = UserDefaults.appsPanel
    
    // MARK: -
    
    var forcedLanguage: String? {
        get {
            return userDefaults.string(forKey: Key.forcedLanguage)
        }
        set {
            userDefaults.set(newValue, forKey: Key.forcedLanguage)
            userDefaults.synchronize()
        }
    }
    
}
