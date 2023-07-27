//
//  KPI.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 22/02/2019.
//  Copyright © 2019 Apps Panel. All rights reserved.
//

import Foundation

extension Stats {

    public typealias Context = [String: AnyCodable]

    struct KPI: Codable {

        enum Kind: String, Codable {
            case event
            case view
        }

        let sessionID: Session.ID
        let kind: Kind
        let date: Date
        let tag: String
        let context: Context?

        init(kind: Kind, tag: String, context: Context?, sessionID: Session.ID) {
            self.kind = kind
            self.tag = tag
            self.sessionID = sessionID
            self.date = Date()
            self.context = context
        }

        enum CodingKeys: String, CodingKey {
            case sessionID = "sessionId"
            case kind = "type"
            case date
            case tag
            case context
        }

    }

}
