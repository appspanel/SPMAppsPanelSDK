//
//  Interstitial.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 01/06/2020.
//  Copyright © 2020 Apps Panel. All rights reserved.
//

import Foundation

struct Interstitial: Decodable {

    let id: Int
    let kind: Kind
    let portraitPictureURL: URL?
    let landscapePictureURL: URL?
    let redirectURL: URL?
    let webViewURL: URL?

    enum CodingKeys: String, CodingKey {
        case id
        case kind = "type"
        case portraitPictureURL = "portraitPictureUrl"
        case landscapePictureURL = "landscapePictureUrl"
        case redirectURL = "redirectUrl"
        case webViewURL = "webviewUrl"
    }

}

extension Interstitial {

    enum Kind: String, Codable {
        case image
        case webView = "webview"
    }

}
