//
//  RequestInfo.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 22/02/2019.
//  Copyright © 2019 Apps Panel. All rights reserved.
//

import Foundation

extension Stats {

    struct RequestInfo: Codable {

        let sessionID: Session.ID
        let startDate: Date
        let endDate: Date
        let endpoint: String
        let method: String
        let httpCode: Int
        let result: Data?
        let resultLength: Int
        let body: Data?
        let bodyLength: Int
        let success: Bool

        init(response: DataResponse, startDate: Date, sessionID: Session.ID) {
            self.sessionID = sessionID
            self.startDate = startDate
            self.endDate = Date() // TODO
            if let url = response.request.url {
                self.endpoint = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            } else {
                self.endpoint = ""
            }
            self.method = response.request.httpMethod ?? "GET"
            self.httpCode = response.statusCode
            self.result = nil
            self.resultLength = response.data.count
            self.body = nil
            self.bodyLength = response.request.httpBody?.count ?? 0
            self.success = true
        }

//        init(error: RequestError, sessionID: Session.ID) {
//            self.sessionID = sessionID
//            self.startDate = Date() // TODO
//            self.endDate = Date() // TODO
//            if let url = response.request.url {
//                self.endpoint = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
//            } else {
//                self.endpoint = ""
//            }
//            self.method = error.request?.httpMethod ?? "GET"
//            self.httpCode = error.statusCode
//            self.httpCode = response.statusCode
//        }

        enum ErrorIdentifier: String, Codable {
            case noConnection
            case timeout
            case system // network => NSError.Code
            case encoding
            case decoding
            case encryption
            case decryption
            case tokenMissing
            case unknown
        }

        struct ErrorInfo: Codable {
            let identifier: ErrorIdentifier
            let message: String?
            let code: Int
            let domaine: String
        }

    }

}
