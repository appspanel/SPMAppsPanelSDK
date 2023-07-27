//
//  FileUploadResponse.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 10/12/2019.
//  Copyright © 2019 Apps Panel. All rights reserved.
//

import Foundation

public struct FileUploadResponse: Response {

    public let uploadedFile: UploadedFile
    public let data: Data
    public let statusCode: Int
    public let request: URLRequest
    public let response: HTTPURLResponse

    init(uploadedFile: UploadedFile, response: Response) {
        self.uploadedFile = uploadedFile
        self.data = response.data
        self.statusCode = response.statusCode
        self.request = response.request
        self.response = response.response
    }

}

public struct UploadedFile: Codable {

    public let url: URL

}
