//
//  ImageUploadResponse.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 10/12/2019.
//  Copyright © 2019 Apps Panel. All rights reserved.
//

import Foundation

public struct ImageUploadResponse: Response {

    public let uploadedImage: UploadedImage
    public let data: Data
    public let statusCode: Int
    public let request: URLRequest
    public let response: HTTPURLResponse

    init(uploadedImage: UploadedImage, response: Response) {
        self.uploadedImage = uploadedImage
        self.data = response.data
        self.statusCode = response.statusCode
        self.request = response.request
        self.response = response.response
    }

}

public struct UploadedImage: Codable {

    public let originalURL: URL
    public let smallURL: URL
    public let mediumURL: URL
    public let largeURL: URL

    enum CodingKeys: String, CodingKey {
        case originalURL = "original"
        case smallURL = "small"
        case mediumURL = "medium"
        case largeURL = "large"
    }

}
