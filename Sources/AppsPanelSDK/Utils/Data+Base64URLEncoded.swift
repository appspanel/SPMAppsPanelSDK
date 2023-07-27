//
//  Data+Base64URLEncoded.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 25/01/2019.
//  Copyright © 2019 Apps Panel. All rights reserved.
//

import Foundation

extension Data {

    func base64URLEncodedString() -> String {
        let result = self.base64EncodedString()
        return result.replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    init?(base64URLEncoded: String) {
        let paddingLength = 4 - base64URLEncoded.count % 4
        let padding = (paddingLength < 4) ? String(repeating: "=", count: paddingLength) : ""
        let base64EncodedString = base64URLEncoded
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
            + padding
        self.init(base64Encoded: base64EncodedString)
    }

}
