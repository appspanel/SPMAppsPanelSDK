//
//  PushNotificationLegacyUserInfo.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 02/02/2022.
//  Copyright © 2022 Apps Panel. All rights reserved.
//

import Foundation
import UserNotifications

public struct PushNotificationLegacyUserInfo: Decodable {
    
    let sender: PushNotificationUserInfo.Sender
    let data: [String: AnyCodable]?
    fileprivate let urlRedirectString: String?
    var urlRedirect: URL? {
        return urlRedirectString.flatMap { URL(string: $0) }
    }
    let id: String
    
    public init(from request: UNNotificationRequest) throws {
        let userInfo = request.content.userInfo as? [String: Any]
        try self.init(from: userInfo ?? [:])
    }
    
    public init(from userInfo: [String: Any]) throws {
        let data = try JSONSerialization.data(withJSONObject: userInfo as Any, options: [])
        self = try JSONDecoder.default.decode(PushNotificationLegacyUserInfo.self, from: data)
    }
    
    public init(from decoder: Decoder) throws {
        // Root
        let container = try decoder.container(keyedBy: RootKeys.self)
        sender = try container.decode(PushNotificationUserInfo.Sender.self, forKey: .sender)
        data = try? container.decodeIfPresent([String: AnyCodable].self, forKey: .data)

        // APS
        let apsContainer = try container.nestedContainer(keyedBy: APSCodingKeys.self, forKey: .aps)
        urlRedirectString = try apsContainer.decodeIfPresent(String.self, forKey: .urlRedirectString)
        id = try apsContainer.decode(String.self, forKey: .id)
    }
    
    enum RootKeys: String, CodingKey {
        case sender
        case data = "datas"
        case aps
    }
    
    enum APSCodingKeys: String, CodingKey {
        case urlRedirectString = "type"
        case id
    }
    
}

extension PushNotificationUserInfo {
    
    init?(legacy legacyUserInfo: PushNotificationLegacyUserInfo) {
        guard let id = Int(legacyUserInfo.id) else {
            return nil
        }
        
        self.id = id
        self.sender = legacyUserInfo.sender
        self.urlRedirect = legacyUserInfo.urlRedirectString
        self.data = legacyUserInfo.data
        self.priority = 0
        self.image = nil
        self.picture = nil
    }
    
}
