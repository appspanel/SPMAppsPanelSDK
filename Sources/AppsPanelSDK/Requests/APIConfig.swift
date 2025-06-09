//
//  APIConfig.swift
//  AppsPanelSDK
//
//  Created by Théo Cauffour on 19/03/2025.
//  Copyright © 2025 Apps Panel. All rights reserved.
//

public struct APIConfig {
    public let appName: String
    public let appKey: String
    public let appSecret: String
    
    public init(appName: String,
                appKey: String,
                appSecret: String) {
        self.appName = appName
        self.appKey = appKey
        self.appSecret = appSecret
    }
}
