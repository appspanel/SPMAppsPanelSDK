//
//  AppsPanelNotificationServiceExtension.swift
//  AppsPanelSDK
//
//  Created by Théo Cauffour on 14/04/2025.
//  Copyright © 2025 Apps Panel. All rights reserved.
//

import UserNotifications
import AppsPanelSDKCore

open class AppsPanelNotificationServiceExtension: UNNotificationServiceExtension {
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    open func getAppsPanelConfiguration() -> (appName: String, appKey: String, privateKey: String)? {
        return nil
    }
    
    override open func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        guard let config = getAppsPanelConfiguration() else {
            contentHandler(request.content)
            return
        }
        
        try? AppsPanel.shared.configure(withAppName: config.appName, appKey: config.appKey, privateKey: config.privateKey)
        
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        guard let notification = try? PushNotificationUserInfo(from: request) else {
            if let bestAttemptContent =  bestAttemptContent {
                contentHandler(bestAttemptContent)
            }
            return
        }

        PushNotificationManager.shared.sendStatistic(notification: notification)

        if let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
    override open func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
