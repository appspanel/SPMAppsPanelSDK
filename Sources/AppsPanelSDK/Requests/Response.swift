//
//  Response.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 27/07/2018.
//  Copyright © 2018 Apps Panel. All rights reserved.
//

import Foundation

public protocol Response {

    var data: Data { get }
    var statusCode: Int { get }
    var request: URLRequest { get }
    var response: HTTPURLResponse { get }

}

public struct DataResponse: Response {

    public let data: Data
    public let statusCode: Int
    public let request: URLRequest
    public let response: HTTPURLResponse

}

public struct ObjectResponse<T: Decodable>: Response {

    public let object: T
    public let data: Data
    public let statusCode: Int
    public let request: URLRequest
    public let response: HTTPURLResponse

    init(object: T, response: Response) {
        self.object = object
        self.data = response.data
        self.statusCode = response.statusCode
        self.request = response.request
        self.response = response.response
    }

}
