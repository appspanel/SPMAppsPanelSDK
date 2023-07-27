//
//  AES256.swift
//  SDKSecuritySwift
//
//  Created by Simon BRUILLOT on 30/08/2018.
//  Copyright © 2018 Apps Panel. All rights reserved.
//

import Foundation
import CommonCrypto

struct AES256 {

    private var key: Data
    private var iv: Data

    public init(key: String, iv: String) throws {
        guard key.count == kCCKeySizeAES256 else {
            throw Error.badKeyLength
        }
        
        guard iv.count == kCCBlockSizeAES128 else {
            throw Error.badInputVectorLength
        }
        
        self.key = Data(key.utf8)
        self.iv = Data(iv.utf8)
    }

    enum Error: Swift.Error {
        case keyGeneration(status: Int)
        case cryptoFailed(status: CCCryptorStatus)
        case badKeyLength
        case badInputVectorLength
    }

    func encrypt(_ digest: Data) throws -> Data {
        return try crypt(input: digest, operation: CCOperation(kCCEncrypt))
    }

    func decrypt(_ encrypted: Data) throws -> Data {
        return try crypt(input: encrypted, operation: CCOperation(kCCDecrypt))
    }

    private func crypt(input: Data, operation: CCOperation) throws -> Data {
        var outLength = Int(0)
        var outBytes = [UInt8](repeating: 0, count: input.count + kCCBlockSizeAES128)
        var status: CCCryptorStatus = CCCryptorStatus(kCCSuccess)
        
        input.withUnsafeBytes { inputPointer in
            let encryptedBytes = inputPointer.baseAddress!
            
            iv.withUnsafeBytes { ivPointer in
                let ivBytes = ivPointer.baseAddress!
                
                key.withUnsafeBytes { keyPointer in
                    let keyBytes = keyPointer.baseAddress!
                    
                    status = CCCrypt(
                        operation,
                        CCAlgorithm(kCCAlgorithmAES128),            // algorithm
                        CCOptions(kCCOptionPKCS7Padding),           // options
                        keyBytes,                                   // key
                        key.count,                                  // keylength
                        ivBytes,                                    // iv
                        encryptedBytes,                             // dataIn
                        input.count,                                // dataInLength
                        &outBytes,                                  // dataOut
                        outBytes.count,                             // dataOutAvailable
                        &outLength                                  // dataOutMoved
                    )
                }
            }
        }
        
        guard status == kCCSuccess else {
            throw Error.cryptoFailed(status: status)
        }
                
        return Data(bytes: &outBytes, count: outLength)
    }

    static func createKey(password: Data, salt: Data) throws -> Data {
        let length = kCCKeySizeAES256
        var status = Int32(0)
        var derivedBytes = [UInt8](repeating: 0, count: length)
        
        password.withUnsafeBytes { passwordPointer in
            let passwordRawBytes = passwordPointer.baseAddress!
            let passwordBytes = passwordRawBytes.assumingMemoryBound(to: Int8.self)
            
            salt.withUnsafeBytes { saltPointer in
                let saltRawBytes = saltPointer.baseAddress!
                let saltBytes = saltRawBytes.assumingMemoryBound(to: UInt8.self)
                
                status = CCKeyDerivationPBKDF(
                    CCPBKDFAlgorithm(kCCPBKDF2),                  // algorithm
                    passwordBytes,                                // password
                    password.count,                               // passwordLen
                    saltBytes,                                    // salt
                    salt.count,                                   // saltLen
                    CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA1),   // prf
                    10000,                                        // rounds
                    &derivedBytes,                                // derivedKey
                    length                                        // derivedKeyLen
                )
            }
        }
        
        guard status == 0 else {
            throw Error.keyGeneration(status: Int(status))
        }
        
        return Data(bytes: &derivedBytes, count: length)
    }

    static func randomIv() -> Data {
        return randomData(length: kCCBlockSizeAES128)
    }

    static func randomSalt() -> Data {
        return randomData(length: 8)
    }

    static func randomData(length: Int) -> Data {
        var data = Data(count: length)
        var mutableBytes: UnsafeMutableRawPointer!
        
        data.withUnsafeMutableBytes { rawBufferPointer in
            mutableBytes = rawBufferPointer.baseAddress!
        }
        
        let status = SecRandomCopyBytes(kSecRandomDefault, length, mutableBytes)
        assert(status == Int32(0))
        return data
    }
}
