//
//  PushNotificationInfo.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 21/06/2019.
//  Copyright © 2019 Apps Panel. All rights reserved.
//

import Foundation
import UIKit

extension Stats {

    struct PushNotificationEvent: Codable {

        enum Action: String, Codable {
            case received = "AP_PUSH_RECEIVED"
            case clicked = "AP_PUSH_CLICKED"

            init(for applicationState: UIApplication.State) {
                self = applicationState == .active ? .received : .clicked
            }
        }

        var id: Int
        var date: Date
        var action: Action

    }

}
