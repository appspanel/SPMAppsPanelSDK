//
//  DeviceInfoStore.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 17/11/2021.
//  Copyright © 2021 Apps Panel. All rights reserved.
//

import Foundation

class DeviceInfoStore {
    
    private enum Key {
        static let latestSentDeviceIdentifier = "DeviceInfoLatestSentDeviceIdentifier"
        static let latestSuccessfulSendingDate = "DeviceInfoLatestSuccessfulSendingDate"
    }
    
    // MARK: -
        
    private let userDefaults = UserDefaults.appsPanel
    
    // MARK: -
    
    var latestSentDeviceIdentifier: String? {
        get {
            return userDefaults.string(forKey: Key.latestSentDeviceIdentifier)
        }
        set {
            userDefaults.set(newValue, forKey: Key.latestSentDeviceIdentifier)
        }
    }
    
    private var latestSuccessfulSendingTimestamp: TimeInterval?  {
        get {
            return userDefaults.double(forKey: Key.latestSuccessfulSendingDate)
        }
        set {
            if let timestamp = newValue {
                userDefaults.set(timestamp, forKey: Key.latestSuccessfulSendingDate)
            } else {
                userDefaults.removeObject(forKey: Key.latestSuccessfulSendingDate)
            }
        }
    }
    
    var latestSuccessfulSendingDate: Date? {
        get {
            return latestSuccessfulSendingTimestamp.flatMap(Date.init(timeIntervalSince1970:))
        }
        set {
            latestSuccessfulSendingTimestamp = newValue?.timeIntervalSince1970
        }
    }

}
