//
//  APVersion.swift
//  AppsPanelSDK
//
//  Created by Matteo Melis on 02/04/2024.
//  Copyright © 2024 Apps Panel. All rights reserved.
//

import Foundation

struct Version: Codable {
    let version: String
    let message: String
    let url: String?
    let force: Bool
    let okButton: String
    let cancelButton: String
    
    private enum CodingKeys: String, CodingKey {
        case version
        case message
        case url
        case force
        case okButton
        case cancelButton
    }
}
