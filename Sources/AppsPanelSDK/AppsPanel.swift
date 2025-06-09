//
//  AppsPanel.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 17/08/2018.
//  Copyright © 2018 Apps Panel. All rights reserved.
//

import Foundation
import UIKit

public class AppsPanel {

    public static let shared = AppsPanel()

    public weak var delegate: AppsPanelDelegate?

    private let userDefaults = UserDefaults.standard
    
    static let bundleIdentifier = "com.appspanel.sdk"

    public var deviceIdentifier: String {
        return DeviceIdentifier.identifier()
    }
    
    public var usesLegacyDeviceIdentifier: Bool {
        get {
            return DeviceIdentifier.usesLegacyIdentifier
        }
        set {
            DeviceIdentifier.usesLegacyIdentifier = newValue
        }
    }
    
    public var customHeaders: Headers? {
        get {
            return RequestManager.customHeaders
        }
        set {
            RequestManager.customHeaders = newValue
        }
    }
    
    // MARK: - Configuration

    private var _configuration: AppsPanel.Configuration?
    public var configuration: AppsPanel.Configuration {
        if !AppsPanel.shared.isConfigured {
            preconditionFailure("You have to configure the Apps Panel SDK before doing anything with it.")
        }
        return _configuration!
    }

    var isConfigured: Bool {
        return _configuration != nil
    }
    
    private var apiConfigurations: [String: APIConfig] = [:]
    
    // MARK: -
    
    private var didStartSession: Bool = false
    
    // MARK: -
    
    private var didEnterBackgroundAtLeastOnce: Bool = false

    // MARK: - SDK's RequestManager

    lazy var sdkRequestManager: RequestManager = {
        return RequestManager(baseURL: AppsPanel.shared.configuration.sdkBaseURL)
    }()

    // MARK: - Remote Configuration

    public internal(set) var remoteConfiguration: RemoteConfiguration?
    private lazy var remoteConfigurationManager = RemoteConfigurationManager(requestManager: sdkRequestManager)

    private lazy var dialogManager = DialogManager()
    private lazy var interstitialManager = InterstitialManager.shared
    
    // MARK: -

    private init() {
        addNotificationObservers()
    }

    public func configure(withAppName appName: String,
                          appKey: String,
                          privateKey: String,
                          baseURL: URL? = nil,
                          sdkBaseURL: URL? = nil,
                          appGroupIdentifier: String? = nil) throws
    {
        _configuration = try Configuration(appName: appName,
                                           appKey: appKey,
                                           privateKey: privateKey,
                                           baseURL: baseURL,
                                           sdkBaseURL: sdkBaseURL,
                                           appGroupIdentifier: appGroupIdentifier)
    }

    public func startSession() throws {
        guard isConfigured else {
            throw Error.missingConfiguration
        }
        
        didStartSession = true

        try getRemoteConfiguration()
    }

    private func getRemoteConfiguration() throws {
        guard isConfigured else {
            throw Error.missingConfiguration
        }

        remoteConfigurationManager.getConfiguration { [unowned self] result in
            guard case let .success(configuration) = result else {
                print("Unable to get the SDK configuration")
                return
            }
            self.remoteConfiguration = configuration

            self.delegate?.appsPanel(self, didReceiveRemoteConfiguration: configuration)

            self.configureModules(with: configuration)
        }
    }

    private func configureModules(with configuration: RemoteConfiguration) {
        RequestManager.default.defaultTimeout = configuration.timeout
        DeviceInfoManager.shared.configure(with: configuration.deviceInfoConfiguration)
        TextManager.shared.configure(with: configuration.textManagerConfiguration)
        StatsManager.shared.configure(with: configuration.statConfiguration)
        PushNotificationManager.shared.configure(
            with: configuration.pushNotificationConfiguration,
            deviceInfoConfiguration: configuration.deviceInfoConfiguration
        )
        
        if let dialogConfiguration = configuration.dialogConfiguration {
            self.dialogManager.configure(with: dialogConfiguration)
        }
        
        if let interstitialConfiguration = configuration.interstitialConfiguration {
            self.interstitialManager.configure(with: interstitialConfiguration)
        }
        
        if let ratingConfiguration = configuration.ratingConfiguration {
            RatingManager.shared.configure(with: ratingConfiguration, feedbackConfiguration: configuration.feedbackConfiguration)
        }
        
        if let versionConfiguration = configuration.versionConfiguration {
            VersionManager.shared.configure(with: versionConfiguration)
        }
    }

    // MARK: -
    
    private func addNotificationObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    @objc private func appMovedToForeground() {
        // `willEnterForegroundNotification` is posted at launch
        // We want to prevent from getting the remote configuration twice
        guard didEnterBackgroundAtLeastOnce else {
            return
        }
                
        guard didStartSession else {
            return
        }
                
        do {
            try getRemoteConfiguration()
        } catch {
            print("Unable to get remote configuration because the SDK has not been configured.")
        }
    }
    
    @objc private func appMovedToBackground() {
        didEnterBackgroundAtLeastOnce = true
    }

}

public protocol AppsPanelDelegate: AnyObject {

    func appsPanel(_ appsPanel: AppsPanel, didReceiveRemoteConfiguration remoteConfiguration: RemoteConfiguration)

}

public extension AppsPanelDelegate {

    func appsPanel(_ appsPanel: AppsPanel, didReceiveRemoteConfiguration remoteConfiguration: RemoteConfiguration) {}

}

extension AppsPanel {

    enum Error: LocalizedError {
        case missingConfiguration

        var errorDescription: String? {
            switch self {
            case .missingConfiguration:
                return "No configuration has been provided."
            }
        }
    }

}

extension AppsPanel {

    func assertIsSDKConfigured() {
        if !AppsPanel.shared.isConfigured {
            notConfiguredFailure()
        }
    }

    func notConfiguredFailure() -> Never {
        preconditionFailure("You have to configure the Apps Panel SDK before doing anything with it.")
    }
    
    public func registerAPIConfiguration(named name: String, config: APIConfig) {
        apiConfigurations[name] = config
    }

    public func getAPIConfiguration(named name: String) -> APIConfig? {
        return apiConfigurations[name]
    }

}

extension String {

    func isValidAppName() -> Bool {
        let regex = "^[a-z0-9\\-]+$"
        return range(of: regex, options: .regularExpression) != nil
    }

}
