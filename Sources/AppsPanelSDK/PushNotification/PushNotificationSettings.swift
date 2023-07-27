//
//  PushNotificationSettings.swift
//  AppsPanelSDK
//
//  Created by Pierre Grimault on 05/03/2019.
//  Copyright © 2019 Apps Panel. All rights reserved.
//


struct PushNotificationSettings: Encodable {
    
    @NullEncodable var token: String?
    var enabled: Bool
   
    enum CodingKeys: String, CodingKey {
        case token
        case enabled
    }
    
}
