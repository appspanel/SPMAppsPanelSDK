//
//  Bundle+SDK.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 02/06/2020.
//  Copyright © 2020 Apps Panel. All rights reserved.
//

import Foundation

extension Bundle {

    static var appsPanel: Bundle {
        return Bundle(for: AppsPanel.self)
    }
    
    static var appsPanelResources: Bundle {
        let resourcesBundleName = "AppsPanelResources"
        if let bundlePath = Bundle.appsPanel.path(forResource: resourcesBundleName, ofType: "bundle"),
            let bundle = Bundle(path: bundlePath) {
            return bundle
        } else if let bundlePath = Bundle.main.path(forResource: resourcesBundleName, ofType: "bundle"),
            let bundle = Bundle(path: bundlePath) {
            return bundle
        } else if let bundlePath = Bundle.appsPanel.path(forResource: "AppsPanelSDK", ofType: "bundle"),
            let bundle = Bundle(path: bundlePath) {
            return bundle
        } else {
            return Bundle.appsPanel
        }
    }

}
