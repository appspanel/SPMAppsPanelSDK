//
//  File.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 27/07/2018.
//  Copyright © 2018 Apps Panel. All rights reserved.
//

import Foundation

public struct File {

    public let data: Data
    public let mimeType: String
    public let fileName: String

    public init(data: Data, mimeType: String? = nil, fileName: String? = nil) {
        self.data = data
        let fileType = data.fileType()
        self.mimeType = mimeType ?? fileType.mimeType
        self.fileName = fileName ?? "file." + fileType.fileExtension
    }

}
