//
//  RemoteConfiguration.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 17/08/2018.
//  Copyright © 2018 Apps Panel. All rights reserved.
//

import Foundation

protocol Enableable {
    var isEnabled: Bool { get }
}

protocol Delayable {
    var delay: Int { get }
}

public struct RemoteConfiguration: Decodable {

    public let appName: String
    public let timeout: TimeInterval

    public let deviceInfoConfiguration: DeviceInfoConfiguration
    public let textManagerConfiguration: TextManagerConfiguration
    public let pushNotificationConfiguration: PushNotificationConfiguration
    public let statConfiguration: StatConfiguration
    public let logConfiguration: LogConfiguration?
    public let dialogConfiguration: DialogConfiguration?
    public let interstitialConfiguration: InterstitialConfiguration?
    public let ratingConfiguration: RatingConfiguration?
    public let feedbackConfiguration: FeedbackConfiguration?
    public let versionConfiguration: VersionConfiguration?

    public internal(set) var applicationParameters: [String: Any]? = nil

    // MARK: - Codable

    enum RootKeys: String, CodingKey {
        case appName
        case timeout
        case components
    }

    enum ComponentKeys: String, CodingKey {
        case deviceInfo = "device"
        case push
        case stat
        case log
        case dialog
        case interstitial
        case textManager
        case rating
        case feedback
        case version
    }

    public init(from decoder: Decoder) throws {
        // Root
        let container = try decoder.container(keyedBy: RootKeys.self)
        appName = try container.decode(String.self, forKey: .appName)
        timeout = try container.decode(TimeInterval.self, forKey: .timeout)

        // Components
        let componentsContainer = try container.nestedContainer(keyedBy: ComponentKeys.self, forKey: .components)
        deviceInfoConfiguration = try componentsContainer.decode(DeviceInfoConfiguration.self, forKey: .deviceInfo)
        textManagerConfiguration = try componentsContainer.decode(TextManagerConfiguration.self, forKey: .textManager)
        pushNotificationConfiguration = try componentsContainer.decode(PushNotificationConfiguration.self, forKey: .push)
        statConfiguration = try componentsContainer.decode(StatConfiguration.self, forKey: .stat)

        do {
            logConfiguration = try componentsContainer.decode(LogConfiguration.self, forKey: .log)
        } catch {
            logConfiguration = nil
            print("[Remote Configuration] Log configuration is missing or invalid.")
        }

        do {
            dialogConfiguration = try componentsContainer.decode(DialogConfiguration.self, forKey: .dialog)
        } catch {
            dialogConfiguration = nil
            print("[Remote Configuration] Dialog configuration is missing or invalid.")
        }

        do {
            interstitialConfiguration = try componentsContainer.decode(InterstitialConfiguration.self, forKey: .interstitial)
        } catch {
            interstitialConfiguration = nil
            print("[Remote Configuration] Interstitial configuration is missing or invalid.")
        }
        
        do {
            ratingConfiguration = try componentsContainer.decode(RatingConfiguration.self, forKey: .rating)
        } catch {
            ratingConfiguration = nil
            print("[Remote Configuration] Rating configuration is missing or invalid.")
        }
        
        do {
            feedbackConfiguration = try componentsContainer.decode(FeedbackConfiguration.self, forKey: .feedback)
        } catch {
            feedbackConfiguration = nil
            print("[Remote Configuration] Feedback configuration is missing or invalid.")
        }
        
        do {
            versionConfiguration = try componentsContainer.decode(VersionConfiguration.self, forKey: .version)
        } catch {
            versionConfiguration = nil
            print("[Remote Configuration] Version configuration is missing or invalid.")
        }
    }

}

extension RemoteConfiguration {

    public struct DeviceInfoConfiguration: Enableable, Codable {

        public let isEnabled: Bool

        enum CodingKeys: String, CodingKey {
            case isEnabled = "active"
        }
    }

    public struct PushNotificationConfiguration: Enableable, Codable {

        public let isEnabled: Bool
        public let delay: Int
        public let auto: Bool

        enum CodingKeys: String, CodingKey {
            case isEnabled = "active"
            case delay
            case auto
        }
    }

    public struct StatConfiguration: Enableable, Codable {

        public let isEnabled: Bool

        enum CodingKeys: String, CodingKey {
            case isEnabled = "active"
        }
    }

    public struct LogConfiguration: Enableable, Codable {

        public struct ContextConfiguration: Enableable, Codable {

            public let isEnabled: Bool
            public let consoleEnabled: Bool
            public let streamEnabled: Bool
            public let level: String //APLogger.Level

            enum CodingKeys: String, CodingKey {
                case isEnabled = "active"
                case consoleEnabled = "display"
                case streamEnabled = "stream"
                case level
            }

        }

        public let isEnabled: Bool
        public let app: ContextConfiguration
        public let sdk: ContextConfiguration
        public let ws: ContextConfiguration

        enum CodingKeys: String, CodingKey {
            case isEnabled = "active"
            case app
            case sdk
            case ws
        }

    }

    public struct DialogConfiguration: Enableable, Delayable, Codable {

        public let isEnabled: Bool
        public let delay: Int

        enum CodingKeys: String, CodingKey {
            case isEnabled = "active"
            case delay
        }

    }

    public struct InterstitialConfiguration: Enableable, Delayable, Codable {

        public let isEnabled: Bool
        public let auto: Bool
        public let delay: Int
        public let displayLimit: TimeInterval

        enum CodingKeys: String, CodingKey {
            case isEnabled = "active"
            case auto
            case delay
            case displayLimit
        }

    }

    public struct TextManagerConfiguration: Enableable, Codable {

        public let isEnabled: Bool

        enum CodingKeys: String, CodingKey {
            case isEnabled = "active"
        }

    }

    public struct RatingConfiguration: Enableable, Codable {
        
        public let isEnabled: Bool
        public let minTimeSinceLastView: TimeInterval
        public let minLaunchNumberSinceLastView: Int
        
        enum CodingKeys: String, CodingKey {
            case isEnabled = "active"
            case minTimeSinceLastView
            case minLaunchNumberSinceLastView
        }
    }
    
    public struct FeedbackConfiguration: Enableable, Codable {
        
        public let isEnabled: Bool
        
        enum CodingKeys: String, CodingKey {
            case isEnabled = "active"
        }
    }
    
    public struct VersionConfiguration: Enableable, Delayable, Codable {
        public let isEnabled: Bool
        public let delay: Int
        
        enum CodingKeys: String, CodingKey {
            case isEnabled = "active"
            case delay
        }
    }
}
