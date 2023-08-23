//
//  PushNotificationStorage.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 15/04/2021.
//  Copyright © 2021 Apps Panel. All rights reserved.
//

import Foundation
import UserNotifications

struct PushNotificationStorage {
    
    private enum Key {
        static let deviceToken = "PushNotificationDeviceToken"
        static let authorized = "PushNotificationAuthorized"
        static let latestSuccessfulSendingDate = "PushNotificationLatestSuccessfulSendingDate"
        static let previousAuthorizationStatus = "PushNotificationPreviousAuthorizationStatus"
    }
    
    // MARK: - 
    
    static let shared = PushNotificationStorage()
    
    private let userDefaults = UserDefaults.appsPanel
    
    // MARK: -
    
    var deviceToken: String? {
        get {
            return userDefaults.string(forKey: Key.deviceToken)
        }
        set {
            userDefaults.set(newValue, forKey: Key.deviceToken)
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
    
    var previousAuthorizationStatus: UNAuthorizationStatus {
        get {
            let rawValue = userDefaults.integer(forKey: Key.previousAuthorizationStatus)
            return UNAuthorizationStatus(rawValue: rawValue) ?? .notDetermined
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: Key.previousAuthorizationStatus)
        }
    }
    
    var authorized: Bool {
        get {
            return userDefaults.bool(forKey: Key.authorized)
        }
        set {
            userDefaults.set(newValue, forKey: Key.authorized)
        }
    }
    
}
