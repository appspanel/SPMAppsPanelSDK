//
//  DeviceInfoManager.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 19/04/2021.
//  Copyright © 2021 Apps Panel. All rights reserved.
//

import UIKit

public class DeviceInfoManager {
    
    public static let shared = DeviceInfoManager()
        
    private var configuration: RemoteConfiguration.DeviceInfoConfiguration?
    
    private let requestManager = AppsPanel.shared.sdkRequestManager
    
    private let store = DeviceInfoStore()
        
    private let minumumDataFreshness = TimeInterval(days: 1)
    
    // MARK: -
    
    private init() {
        
    }
        
    // MARK: - Configure Module

    func configure(with configuration: RemoteConfiguration.DeviceInfoConfiguration) {        
        self.configuration = configuration

        guard configuration.isEnabled else {
            return
        }
        
        sendDeviceInfo()
    }
    
    // MARK: - Post device info
    
    private func shouldSendDeviceInfoWithData(for deviceInfo: DeviceInfo) -> Bool {
        // Is device identifier different
        if DeviceIdentifier.identifier() != store.latestSentDeviceIdentifier {
            return true
        // Is last sending older than 24 hours
        } else if (store.latestSuccessfulSendingDate ?? Date(timeIntervalSince1970: 0)).timeIntervalSinceNow < -minumumDataFreshness {
            return true
        // Is data different
        } else {
            if let oldDeviceInfoDict = DocumentHelper.readValue(forKey: "deviceInfo") as? NSDictionary {
                do {
                    let data = try JSONSerialization.data(withJSONObject: oldDeviceInfoDict as Any, options: [])
                    let oldDeviceInfo = try JSONDecoder.default.decode(DeviceInfo.self, from: data)
                    return oldDeviceInfo != deviceInfo
                } catch {
                    return true
                }
            } else {
                return true
            }
        }
    }
    
    private func sendDeviceInfo() {
        let deviceInfo = DeviceInfo()
        
        let sendsData = shouldSendDeviceInfoWithData(for: deviceInfo)
        let endpoint = WebService.postDevice(sendsData ? deviceInfo : nil)
        
        requestManager.request(endpoint: endpoint).responseData { result in
            guard case .success = result else {
                return
            }
            
            self.handleSuccessSending(for: deviceInfo, withData: sendsData)
        }
    }
    
    func handleSuccessSending(for deviceInfo: DeviceInfo, withData: Bool) {
        guard withData else {
            return
        }
        
        guard let dict = deviceInfo.dictionary else {
            return
        }
        
        DocumentHelper.write(value: dict, forKey: "deviceInfo")
        self.store.latestSentDeviceIdentifier = DeviceIdentifier.identifier()
        self.store.latestSuccessfulSendingDate = Date()
    }

}
