//
//  TimeIntervalExtensions.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 17/11/2021.
//  Copyright © 2021 Apps Panel. All rights reserved.
//

import Foundation

extension TimeInterval {
    
    init(seconds: Int) {
        self.init(seconds)
    }
    
    init(minutes: Int) {
        self.init(seconds: minutes * 60)
    }
    
    init(hours: Int) {
        self.init(minutes: hours * 60)
    }
    
    init(days: Int) {
        self.init(hours: days * 24)
    }
    
    init(days: Int = 0, hours: Int = 0, minutes: Int, seconds: Int) {
        var total = TimeInterval(seconds: seconds)
        total += TimeInterval(minutes: minutes)
        total += TimeInterval(hours: hours)
        total += TimeInterval(days: days)
        self.init(total)
    }
    
    init(days: Int, hours: Int) {
        var total = TimeInterval(hours: hours)
        total += TimeInterval(days: days)
        self.init(total)
    }
    
    init(hours: Int, minutes: Int) {
        var total = TimeInterval(minutes: minutes)
        total += TimeInterval(hours: hours)
        self.init(total)
    }
    
}
