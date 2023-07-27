//
//  Data+Crypto.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 18/01/2019.
//  Copyright © 2019 Apps Panel. All rights reserved.
//

import Foundation

extension Data {

    func encrypted(secret: String, iv: String) throws -> Data {
        let aes = try AES256(key: secret, iv: iv)
        let encryptedData = try aes.encrypt(self)

        // Base64 encode the encrypted data before sending it
        return encryptedData.base64EncodedData()
    }

    func decrypted(secret: String, iv: String) throws -> Data {
        // Base64 decode the encrypted data before decrypting it
        guard let decodedData = Data(base64Encoded: self) else {
            throw DecryptionError.invalidData
        }

        do {
            let aes = try AES256(key: secret, iv: iv)
            return try aes.decrypt(decodedData)
        } catch {
            throw DecryptionError.decryptionFailed(error: error)
        }
    }

}
