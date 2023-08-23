//
//  FileUpload.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 10/12/2019.
//  Copyright © 2019 Apps Panel. All rights reserved.
//

import Foundation

public struct FileUpload {

    public let file: File
    public let entity: UploadEntity?
    public var timeout: TimeInterval?
    
    public init(file: File, entity: UploadEntity? = nil) {
        self.file = file
        self.entity = entity
    }

    public init(data: Data, entity: UploadEntity? = nil) {
        self.file = File(data: data)
        self.entity = entity
    }

}

extension FormData {

    init(fileUpload: FileUpload) {
        self.init()

        self.append(fileUpload.file.data,
                    fileName: fileUpload.file.fileName,
                    mimeType: fileUpload.file.mimeType)

        if let entity = fileUpload.entity {
            appendEntity(entity)
        }
    }

}
