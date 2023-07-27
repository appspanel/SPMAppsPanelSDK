//
//  Session.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 22/02/2019.
//  Copyright © 2019 Apps Panel. All rights reserved.
//

import Foundation

struct Session: Codable {
    
    typealias ID = String
    
    let id: ID
    let startDate: Date
    private(set) var endDate: Date?
    
    var isClosed: Bool {
        return endDate != nil
    }
    
    init() {
        self.id = UUID().uuidString
        self.startDate = Date()
    }
    
    mutating func close() {
        guard !isClosed else {
            return
        }
        
        endDate = Date()
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case startDate = "start"
        case endDate = "end"
    }
    
}
