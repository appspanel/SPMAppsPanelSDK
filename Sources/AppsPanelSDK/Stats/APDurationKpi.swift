//
//  KPI.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 22/02/2019.
//  Copyright © 2019 Apps Panel. All rights reserved.
//

import Foundation

extension Stats {

    struct APDurationKpi: Codable {

        let sessionID: Session.ID
        let start: Date
        let end: Date?
        let tag: String
        let context: Context?

        init(tag: String, context: Context? = nil, sessionID: Session.ID, start: Date = Date(), end: Date? = nil) {
            self.tag = tag
            self.sessionID = sessionID
            self.start = start
            self.end = end
            self.context = context
        }

        enum CodingKeys: String, CodingKey {
            case sessionID = "sessionId"
            case start
            case end
            case tag
            case context
        }

    }

}
