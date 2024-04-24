//
//  Stats.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 22/02/2019.
//  Copyright © 2019 Apps Panel. All rights reserved.
//

import Foundation

public struct Stats: Codable {

    var sessions: [Session]?
    var kpis: [KPI]?
    var lastRequests: [RequestInfo]?
    var pushNotifications: [PushNotificationEvent]?
    var durations: [APDurationKpi]?

    enum CodingKeys: String, CodingKey {
        case sessions
        case kpis
        case lastRequests
        case pushNotifications = "pushes"
        case durations
    }

}

extension Stats {

    var isEmpty: Bool {
        let emptinesses = [
            sessions?.isEmpty,
            kpis?.isEmpty,
            lastRequests?.isEmpty,
            pushNotifications?.isEmpty,
            durations?.isEmpty
        ].compactMap({ $0 })
        return !emptinesses.contains(false)
    }

}
