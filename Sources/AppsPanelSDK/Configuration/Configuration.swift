//
//  Configuration.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 29/08/2018.
//  Copyright © 2018 Apps Panel. All rights reserved.
//

import Foundation

public extension AppsPanel {

    struct Configuration {

        enum ConfigurationError: LocalizedError {
            case invalidAppName
            case missingCustomBaseURL
            case baseURLInitializationFailed
            case sdkBaseURLInitializationFailed

            // swiftlint:disable line_length
            var errorDescription: String? {
                switch self {
                case .invalidAppName:
                    return "The app name should be combinaison of lowercased letters, numbers and dashs."
                case .missingCustomBaseURL:
                    return "You specified a custom SDK base URL without providing a base URL. Please add a custom base URL or remove your SDK base URL."
                case .baseURLInitializationFailed, .sdkBaseURLInitializationFailed:
                    return "Unabled to initialized the base URL or the SDK base URL. Please check your app name."
                }
            }
            // swiftlint:enable line_length
        }

        public let appName: String
        public let appKey: String
        public let privateKey: String
        public let baseURL: URL
        public let sdkBaseURL: URL
        public let appGroupIdentifier: String?

        init(appName: String,
             appKey: String,
             privateKey: String,
             baseURL: URL? = nil,
             sdkBaseURL: URL? = nil,
             appGroupIdentifier: String? = nil) throws
        {
            guard appName.isValidAppName() else {
                throw ConfigurationError.invalidAppName
            }

            self.appName = appName
            self.appKey = appKey
            self.privateKey = privateKey
            self.appGroupIdentifier = appGroupIdentifier

            if sdkBaseURL != nil && baseURL == nil {
                throw ConfigurationError.missingCustomBaseURL
            }

            if let baseURL = baseURL {
                self.baseURL = baseURL
            } else if let defaultBaseURL = AppsPanel.baseURL(forAppName: appName) {
                self.baseURL = defaultBaseURL
            } else {
                throw ConfigurationError.baseURLInitializationFailed
            }

            if let sdkBaseURL = sdkBaseURL {
                self.sdkBaseURL = sdkBaseURL
            } else if let defaultSDKBaseURL = AppsPanel.sdkBaseURL(forAppName: appName) {
                self.sdkBaseURL = defaultSDKBaseURL
            } else {
                throw ConfigurationError.sdkBaseURLInitializationFailed
            }
        }

    }

}

extension AppsPanel {

    static func baseURL(forAppName appName: String) -> URL? {
        return URL(string: "https://\(appName).ap-api.com")
    }

    static func sdkBaseURL(forAppName appName: String) -> URL? {
        return URL(string: "https://\(appName).ap-sdk.com")
    }

}
