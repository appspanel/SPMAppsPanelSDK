//
//  PushNotificationManager.swift
//  AppsPanelSDK
//
//  Created by Pierre Grimault on 16/11/2018.
//  Copyright © 2018 Apps Panel. All rights reserved.
//

import UserNotifications
import UIKit

public class PushNotificationManager {
    
    public static let shared = PushNotificationManager()
        
    private var storage = PushNotificationStorage.shared

    private var pushNotificationConfiguration: RemoteConfiguration.PushNotificationConfiguration?
    private var deviceInfoConfiguration: RemoteConfiguration.DeviceInfoConfiguration?
    
    // MARK: - Configure Module

    func configure(with pushNotificationConfiguration: RemoteConfiguration.PushNotificationConfiguration, deviceInfoConfiguration: RemoteConfiguration.DeviceInfoConfiguration) {
        let isFirstConfiguration = self.pushNotificationConfiguration == nil // Basically launch
        
        self.pushNotificationConfiguration = pushNotificationConfiguration
        self.deviceInfoConfiguration = deviceInfoConfiguration

        guard pushNotificationConfiguration.isEnabled else {
            return
        }

        let previousStatus = storage.previousAuthorizationStatus

        if isFirstConfiguration { // Launch
            if pushNotificationConfiguration.auto {
                registerForPushNotifications(application: UIApplication.shared)
            } else {
                requestTokenIfAutorizationStatusIsDetermined()
            }
        } else { // Entered to foreground
            getAuthorizationStatus { status in
                if status != previousStatus {
                    self.requestTokenIfAutorizationStatusIsDetermined()
                }
            }
        }
        
        updateAuthorizationStatus()
    }
    
    // MARK: - Authorization status
    
    private func getAuthorizationStatus(completionHandler: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completionHandler(settings.authorizationStatus)
            }
        }
    }
    
    private func updateAuthorizationStatus() {
        getAuthorizationStatus { status in
            self.storage.previousAuthorizationStatus = status
        }
    }
    
    // MARK: Register devices
    
    private func requestTokenIfAutorizationStatusIsDetermined() {
        getAuthorizationStatus { status in
            if status != .notDetermined {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    public func registerDevice(token: Data) {
        let tokenParts = token.map { data -> String in
            return String(format: "%02X", data)
        }
        let deviceToken = tokenParts.joined()
        print("[PushNotificationManager] Device Token: \(deviceToken)")
        
        getAuthorizationStatus { status in
            if self.shouldSendDeviceToken(deviceToken, withAuthorizationStatus: status) {
                let isEnabled = status == .authorized
                self.sendDeviceToken(deviceToken, enabled: isEnabled)
            }
        }
    }
    
    private func sendDeviceToken(_ deviceToken: String?, enabled: Bool) {
        let isDeviceInfoEnabled = deviceInfoConfiguration?.isEnabled ?? true
        
        guard isDeviceInfoEnabled else {
            return
        }
        
        let settings = PushNotificationSettings(token: deviceToken, enabled: enabled)
        AppsPanel.shared.sdkRequestManager.request(endpoint: WebService.patchDevice(settings: settings)).responseData { result in
            switch result {
            case .success:
                if enabled {
                    print("[PushNotificationManager] Register device token successfully")
                } else {
                    print("[PushNotificationManager] Disable push notification service successfully")
                }
                self.storage.deviceToken = deviceToken
                self.storage.latestSuccessfulSendingDate = Date()
                self.storage.authorized = enabled
            case .failure(let error):
                print("[PushNotificationManager] Unable to register device token. This call will be retried at next launch.")
                print(error)
            }
        }
    }

    private func shouldSendDeviceToken(_ token: String?, withAuthorizationStatus authorizationStatus: UNAuthorizationStatus) -> Bool {
        let previousToken = storage.deviceToken
        let previouslyAuthorized = storage.authorized
        let authorized = authorizationStatus == .authorized
        let authorizationChanged = authorized != previouslyAuthorized
        
        if previousToken != token { // The token has changed
            return true
        } else if authorizationChanged {
            return true
        } else {
            let latestPatchDeviceCallDate = storage.latestSuccessfulSendingDate ?? Date(timeIntervalSince1970: 0)
            let nextCallDate = latestPatchDeviceCallDate.addingTimeInterval(7 * 24 * 60 * 60)
            let now = Date()
            
            return nextCallDate < now // More than one week since last success call
        }
    }

    @available(iOS 10.0, *)
    public func registerForPushNotifications(application: UIApplication) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("[PushNotificationManager] Permission granted: \(granted)")
            
            self.updateAuthorizationStatus()
            
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
    }
    
    // MARK: Manage notifications
    
    public func checkReceivedNotification(launchOptions: [UIApplication.LaunchOptionsKey: Any]?, state: UIApplication.State) {
        if let launchOptions = launchOptions,
            let notification = launchOptions[.remoteNotification] as? [String:Any]
        {
            guard let userNotification = try? PushNotificationUserInfo(from: notification) else { return }
            manageUserNotification(userNotification, show: false, state: state, completionHandler: nil)
        }
    }
    
    @available(iOS 10.0, *)
    public func manageNotification(_ notification: UNNotification, show: Bool, state: UIApplication.State,  completionHandler: @escaping ((UNNotificationPresentationOptions) -> Void)) {
        guard let userNotification = try? PushNotificationUserInfo(from: notification.request) else { return }
        manageUserNotification(userNotification, show: show, state: state, completionHandler: completionHandler)
    }
    
    @available(iOS 10.0, *)
    private func manageUserNotification(_ userNotification: PushNotificationUserInfo, show: Bool, state: UIApplication.State, completionHandler: ((UNNotificationPresentationOptions) -> Void)?) {
        guard userNotification.sender == .apnl else {
            print("[PushNotificationManager] Try to manage not apnl push notification")
            return
        }

        if show, let completionHandler = completionHandler {
            completionHandler([.alert, .sound])
        }

        sendStatistic(id: userNotification.id, applicationState: state)
    }

    // MARK: Statistics

    private func sendStatistic(id: Int, action: Stats.PushNotificationEvent.Action) {
        let event = Stats.PushNotificationEvent(id: id, date: Date(), action: action)
        AppsPanel.shared.sdkRequestManager.request(endpoint: WebService.postPushStatistic(event)).responseData { (result) in
            switch result {
            case .success( _):
                print("[PushNotification] Push notification event sent.")
            case .failure(let error):
                print("[PushNotification] Could not send push notification event. \(error)")
                StatsManager.shared.savePushNotificationEvent(event)
            }
        }
    }

    private func sendStatistic(id: Int, applicationState: UIApplication.State) {
        let action = Stats.PushNotificationEvent.Action(for: applicationState)
        sendStatistic(id: id, action: action)
    }

    public func sendStatistic(notification: PushNotificationUserInfo) {
        sendStatistic(id: notification.id, action: .received)
    }

}
