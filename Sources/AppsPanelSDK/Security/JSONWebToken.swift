//
//  JSONWebToken.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 07/12/2018.
//  Copyright © 2018 Apps Panel. All rights reserved.
//

import Foundation
import SwiftJWT

private struct APClaims: Claims {

    let appName: String
    let expiration: Int
    let sec: SecurityOptions
    let userToken: String?
    let data: Data?

    init(appName: String, expirationDate: Date, securityOptions: Security.Options, userToken: String?, data: Data?) {
        self.appName = appName
        self.expiration = Int(expirationDate.timeIntervalSince1970)
        self.sec = SecurityOptions(securityOptions: securityOptions)
        self.userToken = userToken
        self.data = data
    }

//    func encode() throws -> String {
//        let jsonEncoder = JSONEncoder()
//        jsonEncoder.dateEncodingStrategy = .secondsSince1970
//        let data = try jsonEncoder.encode(self)
//        return data.base64URLEncodedString()
//    }

    enum CodingKeys: String, CodingKey {
        case expiration = "exp"
        case sec
        case appName = "appname"
        case userToken = "utoken"
        case data
    }

}

extension APClaims {

    struct SecurityOptions: Codable {
        let encryptRequest: Bool
        let encryptResponse: Bool

        init(securityOptions: Security.Options) {
            encryptRequest = securityOptions.contains(.encryptRequest)
            encryptResponse = securityOptions.contains(.encryptResponse)
        }

        enum CodingKeys: String, CodingKey {
            case encryptRequest = "secure_parameter"
            case encryptResponse = "secure_answer"
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(encryptRequest ? 1 : 0, forKey: .encryptRequest)
            try container.encode(encryptResponse ? 1 : 0, forKey: .encryptResponse)
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let encryptRequestInt = try container.decode(Int.self, forKey: .encryptRequest)
            let encryptResponseInt = try container.decode(Int.self, forKey: .encryptResponse)
            encryptRequest = encryptRequestInt == 1
            encryptResponse = encryptResponseInt == 1
        }

    }

}

struct JSONWebToken {

    let appName: String
    let appKey: String
    let secret: String
    let iv: String

    init(appName: String, appKey: String, secret: String, iv: String) {
        self.appName = appName
        self.appKey = appKey
        self.secret = secret
        self.iv = iv
    }

    func produce(userToken: String?, secureData: Data?, securityOptions: Security.Options) throws -> String {
        let header = Header()
        let expirationDate = Date(timeIntervalSinceNow: 300)
        let claims = APClaims(appName: appName,
                              expirationDate: expirationDate,
                              securityOptions: securityOptions,
                              userToken: userToken,
                              data: secureData)

        var jwt = JWT(header: header,
                      claims: claims)

        let jwtSigner = JWTSigner.hs256(key: Data(secret.utf8))
        let signedJWT = try jwt.sign(using: jwtSigner)

        do {
            let jwtData = Data(signedJWT.utf8)
            let encryptedJWT = try jwtData.encrypted(secret: secret, iv: iv)
            return String(data: encryptedJWT, encoding: .utf8)!
        } catch {
            throw Error.encryptionFailed(error: error)
        }
    }

}

extension JSONWebToken {

    enum Error: Swift.Error {
        case encryptionFailed(error: Swift.Error)
    }

}
