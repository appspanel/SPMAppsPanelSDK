//
//  DeviceInfo.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 20/08/2018.
//  Copyright © 2018 Apps Panel. All rights reserved.
//

import Alamofire
import CoreTelephony
import Foundation
import UIKit

struct DeviceInfo: Codable, Equatable {

    // App & SDK
    let appID: String
    let appVersion: String
    let sdkVersion: String

    // OS
    let os: String
    let osVersion: String

    // Locale & Timezone
    let language: String
    let timeZone: String

    // Hardware
    let manufacturer: String
    let name: String
    let model: String
    let modelVersion: String

    let screenResolution: String
    let pixelRatio: CGFloat
    let carrier: String?
    
    init() {
        self.appID = Bundle.main.infoDictionary?["CFBundleIdentifier"] as! String
        self.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        self.sdkVersion = AppsPanel.shared.version

        self.os = "iOS"
        self.osVersion = UIDevice.current.systemVersion

        self.language = Locale.preferredLanguages[0]
        self.timeZone = TimeZone.current.identifier

        self.manufacturer = "Apple"
        self.name = UIDevice.current.name
        self.model = UIDevice.current.model
        self.modelVersion = {
            var systemInfo = utsname()
            uname(&systemInfo)
            let machineMirror = Mirror(reflecting: systemInfo.machine)
            return machineMirror.children.reduce("") { identifier, element in
                guard let value = element.value as? Int8, value != 0 else { return identifier }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }
        }()

        self.screenResolution = "\(Int(UIScreen.main.bounds.width))*\(Int(UIScreen.main.bounds.height))"
        self.pixelRatio = UIScreen.main.scale
        self.carrier = {
            #if targetEnvironment(simulator)
            return nil
            #else
            return CTTelephonyNetworkInfo().subscriberCellularProvider?.carrierName
            #endif
        }()
    }

    enum CodingKeys: String, CodingKey {
        case appID = "appId"
        case appVersion
        case sdkVersion
        case os
        case osVersion
        case language
        case timeZone
        case manufacturer
        case name
        case model
        case modelVersion
        case screenResolution
        case pixelRatio
        case carrier
    }

}
