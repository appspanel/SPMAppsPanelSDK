//
//  HTTPRequest.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 09/04/2018.
//  Copyright © 2018 Apps Panel. All rights reserved.
//

import Foundation

public protocol Endpoint {

    var path: String { get }

    var httpMethod: HTTPMethod { get }

    var parameters: Parameters? { get }

    var body: Parameters? { get }

    var headers: Headers? { get }

    var secureData: Data? { get }

    var securityOptions: Security.Options { get }

}

public extension Endpoint {

    var parameters: Parameters? {
        return nil
    }

    var body: Parameters? {
        return nil
    }

    var headers: Headers? {
        return nil
    }

    var secureData: Data? {
        return nil
    }

    var securityOptions: Security.Options {
        return .none
    }
}
