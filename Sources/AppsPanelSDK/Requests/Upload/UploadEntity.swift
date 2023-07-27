//
//  UploadEntity.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 07/01/2020.
//  Copyright © 2020 Apps Panel. All rights reserved.
//

import Foundation

public struct UploadEntity {

    public let name: String
    public let id: String?

    public init(name: String, id: String? = nil) {
        self.name = name
        self.id = id
    }

}

extension FormData {

    mutating func appendEntity(_ entity: UploadEntity) {
        append(entity.name, withName: "entity_name")

        if let entityID = entity.id {
            append(entityID, withName: "entity_id")
        }
    }

}
