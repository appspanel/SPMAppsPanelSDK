//
//  RequestError.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 22/08/2018.
//  Copyright © 2018 Apps Panel. All rights reserved.
//

import Alamofire
import Foundation

public struct RequestError: Error {

    public let request: URLRequest?
    public let response: HTTPURLResponse?
    public let statusCode: Int?
    public let data: Data?
    public let cause: Cause
    public let backendInfo: BackendErrorInfo?

    public init(request: URLRequest?,
         response: HTTPURLResponse?,
         data: Data?,
         cause: Cause)
    {
        self.request = request
        self.response = response
        self.statusCode = response?.statusCode
        self.data = data
        self.cause = cause

        if let data = data {
            backendInfo = try? JSONDecoder().decode(BackendErrorInfo.self, from: data)
        } else {
            backendInfo = nil
        }
    }

}

extension RequestError {

    init(dataResponse: DataResponse? = nil, cause: Cause) {
        self.init(request: dataResponse?.request,
                  response: dataResponse?.response,
                  data: dataResponse?.data,
                  cause: cause)
    }

}

public extension RequestError {

    enum Cause: Error {
        case network(error: Error) // URLSession Error
        case invalidURL
        case encodingFailed(context: EncodingContext, error: Error)
        case decodingFailed(error: Error)
        case badStatusCode(_: Int)
        case missingAuthenticationToken
        case jsonWebTokenCreationFailed(error: Error)
        case encryptionFailed(error: Error)
        case decryptionFailed(error: DecryptionError)
        case unknown

        public enum EncodingContext {
            case queryString
            case body
            case secureData
            case multipart
        }
    }

}

public enum DecryptionError: Error {
    case missingSecretHeader
    case invalidData
    case decryptionFailed(error: Error)
}

extension RequestError.Cause {

    init(from error: Error) {
        if let error = error as? AFError {
            switch error {
            case .invalidURL(let url):
                print("Invalid URL: \(url) - \(error.localizedDescription)")
                self = RequestError.Cause.invalidURL
            case .parameterEncodingFailed(let reason):
                print("Parameter encoding failed: \(error.localizedDescription)")
                print("Failure Reason: \(reason)")
                self = RequestError.Cause.encodingFailed(context: .queryString, error: error)
            case .multipartEncodingFailed(let reason):
                print("Multipart encoding failed: \(error.localizedDescription)")
                print("Failure Reason: \(reason)")
                self = RequestError.Cause.encodingFailed(context: .multipart, error: error)
            case .responseValidationFailed(let reason):
                print("Response validation failed: \(error.localizedDescription)")
                print("Failure Reason: \(reason)")
                switch reason {
                case .unacceptableStatusCode(let code):
                    self = RequestError.Cause.badStatusCode(code)
                default:
                    self = RequestError.Cause.unknown
                    print("Unknown error: \(error)")
                }
            case .responseSerializationFailed(let reason):
                print("Response serialization failed: \(error.localizedDescription)")
                print("Failure Reason: \(reason)")
                self = RequestError.Cause.unknown
            default:
                self = RequestError.Cause.unknown
                print("Unknown error: \(error)")
            }

            print("Underlying error: \(String(describing: error.underlyingError))")
        } else if let error = error as? URLError {
            self = RequestError.Cause.network(error: error)
            print("URLError occurred: \(error)")
        } else {
            self = RequestError.Cause.unknown
            print("Unknown error: \(error)")
        }
    }

}

public extension RequestError {

    func isURLError(with code: URLError.Code) -> Bool {
        if case let .network(error) = self.cause,
            let urlError = error as? URLError
        {
            return urlError.code == code
        }
        return false
    }

    var isNoConnectionError: Bool {
        return isURLError(with: .notConnectedToInternet)
    }

    var isTimedOutError: Bool {
        return isURLError(with: .timedOut)
    }

    var isNoConnectionOrTimedOutError: Bool {
        return isNoConnectionError || isTimedOutError
    }

    var isCancelledError: Bool {
        return isURLError(with: .cancelled)
    }

}

public struct BackendErrorInfo: Codable {

    public let code: Int
    public let key: String
    public let message: String

    enum RootKeys: String, CodingKey {
        case error
    }

    enum ErrorKeys: String, CodingKey {
        case code
        case key
        case message
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKeys.self)
        let errorContainer = try container.nestedContainer(keyedBy: ErrorKeys.self, forKey: .error)
        self.code = try errorContainer.decode(Int.self, forKey: .code)
        self.key = try errorContainer.decode(String.self, forKey: .key)
        self.message = try errorContainer.decode(String.self, forKey: .message)
    }

}
