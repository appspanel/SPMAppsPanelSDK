//
//  ApplicationSessionManager.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 16/04/2021.
//  Copyright © 2021 Apps Panel. All rights reserved.
//

import Foundation
import UIKit

class ApplicationSessionManager {
    
    static let shared = ApplicationSessionManager()
    
    weak var delegate: ApplicationSessionManagerDelegate?
    
    private(set) var session = Session()
    
    // MARK: -
    
    init() {
        subscribeAppLifeCycleNotifications()
    }
    
    deinit {
        unsubscribeAppLifeCycleNotifications()
    }
    
    // MARK: - Application Life Cycle Notifications
    
    private func subscribeAppLifeCycleNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    private func unsubscribeAppLifeCycleNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    // Also triggered when the app is killed from foreground
    @objc private func appDidEnterBackground() {
        closeSession()
    }
    
    @objc private func appWillEnterForeground() {
        startSession()
    }
    
    // MARK: -
    
    private func closeSession() {
        session.close()
        
        delegate?.applicationSessionManager(self, didCloseSession: session)
    }
    
    private func startSession() {
        session = Session()
    }
    
}

protocol ApplicationSessionManagerDelegate: AnyObject {
    
    func applicationSessionManager(_ applicationSessionManager: ApplicationSessionManager, didCloseSession session: Session)
    
}
