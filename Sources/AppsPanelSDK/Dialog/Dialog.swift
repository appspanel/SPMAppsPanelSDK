//
//  Dialog.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 10/10/2019.
//  Copyright © 2019 Apps Panel. All rights reserved.
//

import Foundation

struct Dialog: Codable {

    let title: String
    let message: String
    let url: URL?
    private(set) var killsAppOnAnyButtonTap: Bool = false
    let closeButtonTitle: String
    let redirectButtonTitle: String?

    enum CodingKeys: String, CodingKey {
        case title
        case message
        case url = "link"
        case killsAppOnAnyButtonTap = "killOnClick"
        case closeButtonTitle = "buttonKillText"
        case redirectButtonTitle = "buttonRedirectText"
    }

}
