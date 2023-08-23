//
//  DataRequest.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 07/09/2018.
//  Copyright © 2018 Apps Panel. All rights reserved.
//

import Foundation

public typealias DownloadProgressHandler = (Progress) -> Void

public typealias DataCompletionHandler = (Result<DataResponse, RequestError>) -> Void
public typealias ObjectCompletionHandler<T: Decodable> = (Result<ObjectResponse<T>, RequestError>) -> Void
public typealias FileUploadCompletionHandler = (Result<FileUploadResponse, RequestError>) -> Void
public typealias ImageUploadCompletionHandler = (Result<ImageUploadResponse, RequestError>) -> Void

public class DataRequest {

    public let requestManager: RequestManager

    public private(set) var urlRequest: URLRequest
    public private(set) var task: URLSessionTask?

    public private(set) var body: Data?
    var contentType: ContentType = .json
    public var security = Security()
    public var timeout: TimeInterval?
    public var downloadProgress: DownloadProgressHandler?

    public var error: RequestError.Cause?

    init(requestManager: RequestManager, request: URLRequest, error: RequestError.Cause? = nil) {
        self.requestManager = requestManager
        self.urlRequest = request
        self.error = error
        self.security.options = requestManager.defaultSecurityOptions
    }

    private func setError(_ error: RequestError.Cause) {
        if self.error == nil {
            self.error = error
        }
    }

    // MARK: - Configure the request

    @discardableResult
    public func setBody<T: Encodable>(_ object: T, jsonEncoder: JSONEncoder = JSONEncoder()) -> DataRequest {
        do {
            body = try jsonEncoder.encode(object)
            contentType = .json
        } catch {
            setError(.encodingFailed(context: .body, error: error))
        }
        return self
    }

    @discardableResult
    public func setBody(_ array: [String: Any]) -> DataRequest {
        do {
            body = try JSONSerialization.data(withJSONObject: array, options: [])
            contentType = .json
        } catch {
            setError(.encodingFailed(context: .body, error: error))
        }
        return self
    }

    @discardableResult
    public func setBody(_ dictionary: [[String: Any]]) -> DataRequest {
        do {
            body = try JSONSerialization.data(withJSONObject: dictionary, options: [])
            contentType = .json
        } catch {
            setError(.encodingFailed(context: .body, error: error))
        }
        return self
    }
    
    @discardableResult
    public func setBody(with formData: FormData) -> DataRequest {
        body = formData.data
        contentType = .multipartFormData(boundary: formData.boundary)
        return self
    }

    @discardableResult
    public func setHeaders(_ headers: Headers) -> DataRequest {
        urlRequest.allHTTPHeaderFields = headers
        return self
    }

    // MARK: Security

    @discardableResult
    public func secure(withOptions options: Security.Options) -> DataRequest {
        security.options = options
        return self
    }

    @discardableResult
    public func secureData<T: Encodable>(_ object: T, jsonEncoder: JSONEncoder = JSONEncoder()) -> DataRequest {
        do {
            security.secureData = try jsonEncoder.encode(object)
        } catch {
            setError(.encodingFailed(context: .secureData, error: error))
        }
        return self
    }

    @discardableResult
    public func secureData(_ array: [String: Any]) -> DataRequest {
        do {
            security.secureData = try JSONSerialization.data(withJSONObject: array, options: [])
        } catch {
            setError(.encodingFailed(context: .secureData, error: error))
        }
        return self
    }

    @discardableResult
    public func secureData(_ dictionary: [[String: Any]]) -> DataRequest {
        do {
            security.secureData = try JSONSerialization.data(withJSONObject: dictionary, options: [])
        } catch {
            setError(.encodingFailed(context: .secureData, error: error))
        }
        return self
    }

    @discardableResult
    public func useUserToken() -> DataRequest {
        security.usesUserToken = true
        return self
    }
    
    // MARK: Timeout
    
    @discardableResult
    public func setTimeout(_ timeout: TimeInterval) -> DataRequest {
        self.timeout = timeout
        return self
    }

    // MARK: Callbacks

    @discardableResult
    public func downloadProgress(_ progressHandler: @escaping DownloadProgressHandler) -> DataRequest {
        downloadProgress = progressHandler
        return self
    }

    // MARK: - Make calls

    private func sendRequest(completion: @escaping DataCompletionHandler) -> DataRequest {
        defer {
            if let errorCause = error {
                let requestError = RequestError(cause: errorCause)
                completion(Result.failure(requestError))
            }
        }

        guard error == nil else {
            return self
        }

        finalizeURLRequest()

        // Check the error again
        guard error == nil else {
            return self
        }
        
        task = requestManager.sendRequest(urlRequest, downloadProgress: downloadProgress, completion: { result in
            guard case let .success(response) = result else {
                completion(result)
                return
            }

            if self.security.options.contains(.encryptResponse) {
                do {
                    let decryptedData = try self.decrypt(data: response.data, httpResponse: response.response)
                    let decryptedResponse = DataResponse(data: decryptedData,
                                                         statusCode: response.statusCode,
                                                         request: response.request,
                                                         response: response.response)
                    completion(.success(decryptedResponse))
                } catch {
                    // `decrypt` only throws `DecryptionError` errors
                    let decryptionError = RequestError.Cause.decryptionFailed(error: error as! DecryptionError)
                    let responseError = RequestError(dataResponse: response, cause: decryptionError)
                    completion(Result.failure(responseError))
                    return
                }
            } else {
                completion(result)
            }
        })
        return self
    }

    @discardableResult
    public func responseData(_ completion: @escaping DataCompletionHandler) -> DataRequest {
        return sendRequest { result in
            completion(result)
        }
    }

    @discardableResult
    public func responseObject<T: Decodable>(_ type: T.Type,
                                             jsonDecoder: JSONDecoder = JSONDecoder(),
                                             completion: @escaping ObjectCompletionHandler<T>) -> DataRequest
    {
        return sendRequest { result in
            switch result {
            case .success(let response):
                do {
                    let decodedObject = try jsonDecoder.decode(T.self, from: response.data)
                    let objectResponse = ObjectResponse<T>(object: decodedObject, response: response)
                    completion(Result.success(objectResponse))
                } catch {
                    let responseError = RequestError(dataResponse: response, cause: .decodingFailed(error: error))
                    completion(Result.failure(responseError))
                }
            case .failure(let error):
                completion(Result.failure(error))
            }
        }
    }
    
    // MARK: - Default headers
    
    private func setGlobalCustomHeaders() {
        guard let headers = RequestManager.customHeaders else {
            return
        }
        
        // Prioritize request-level headers
        urlRequest.allHTTPHeaderFields?.merge(headers) { current, _ in current }
    }
    
    private func setDefaultHeaders() {
        var defaultHeaders: [String: String] = [:]

        defaultHeaders["X-AP-Key"] = AppsPanel.shared.configuration.appKey
        defaultHeaders["X-AP-RealTime"] = String(Int(Date().timeIntervalSince1970))
        defaultHeaders["X-AP-OS"] = "iOS"
        defaultHeaders["X-AP-DeviceUID"] = DeviceIdentifier.identifier()
        defaultHeaders["X-AP-SessionID"] = ApplicationSessionManager.shared.session.id

        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            defaultHeaders["X-AP-AppVersion"] = appVersion
        }
        
        if let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            defaultHeaders["X-AP-BuildVersion"] = buildVersion
        }

        defaultHeaders["X-AP-SDKVersion"] = AppsPanel.shared.version
        
        defaultHeaders["Accept-Charset"] = "utf-8"
        defaultHeaders["Accept-Language"] = TextManager.shared.language
        
        // Prioritize user-defined headers
        urlRequest.allHTTPHeaderFields?.merge(defaultHeaders) { current, _ in current }
    }

    // MARK: - Build the request

    // Modifies the URL request as it should be sent by setting the request's body and applying security with encryption and JWT.
    private func finalizeURLRequest() {
        setGlobalCustomHeaders()
        setDefaultHeaders()
        
        // Timeout
        if let timeout = timeout {
            urlRequest.timeoutInterval = timeout
        } else if let defaultTimeout = requestManager.defaultTimeout {
            urlRequest.timeoutInterval = defaultTimeout
        }
        
        let sec = secret(forPrivateKey: AppsPanel.shared.configuration.privateKey)
        let iv = randomString(length: 16)

        // Set body with encryption if wanted
        if let body = body {
            if let method = HTTPMethod(rawValue: urlRequest.httpMethod ?? ""),
                method == .get
            {
                print("Ignoring the body because the request's method is GET.")
            } else {
                if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                    urlRequest.setValue(contentType.headerValue, forHTTPHeaderField: "Content-Type")
                }

                if security.options.contains(.encryptRequest) {
                    do {
                        urlRequest.httpBody = try body.encrypted(secret: sec, iv: iv)
                    } catch {
                        setError(.encryptionFailed(error: error))
                    }
                } else {
                    urlRequest.httpBody = body
                }
            }
        }

        if security.options != .none {
            urlRequest.addValue(iv, forHTTPHeaderField: "X-AP-Secret")
        }

        // JWT
        if security.options.contains(.jsonWebToken) {
            let jwt = JSONWebToken(appName: AppsPanel.shared.configuration.appName,
                                   appKey: AppsPanel.shared.configuration.appKey,
                                   secret: sec,
                                   iv: iv)

            var userToken: String?
            if security.usesUserToken {
                if let token = AuthenticationTokenManager.token() {
                    userToken = token
                } else {
                    setError(.missingAuthenticationToken)
                }
            }

            do {
                let jwtHeader = try jwt.produce(userToken: userToken,
                                                secureData: security.secureData,
                                                securityOptions: security.options)
                urlRequest.addValue(jwtHeader, forHTTPHeaderField: "X-AP-Authorization")
            } catch {
                setError(.jsonWebTokenCreationFailed(error: error))
            }
        }
    }

    // MARK: - Decryption

    private func decrypt(data: Data, httpResponse: HTTPURLResponse) throws -> Data  {
        let secret = self.secret(forPrivateKey: AppsPanel.shared.configuration.privateKey)

        guard let iv = httpResponse.allHeaderFields["X-AP-Secret"] as? String else {
            throw DecryptionError.missingSecretHeader
        }

        return try data.decrypted(secret: secret, iv: iv)
    }

    // MARK: - Helpers

    private func secret(forPrivateKey privateKey: String!) -> String {
        let index = privateKey.index(privateKey.startIndex, offsetBy: 16)
        let firstpart = privateKey[..<index]

        return "\(firstpart)\(firstpart)"
    }

    private func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }

    // MARK: - Actions

    public func cancel() {
        task?.cancel()
    }

    public func resume() {
        task?.resume()
    }

    public func suspend() {
        task?.suspend()
    }

}

extension DataRequest {
    
    enum ContentType {
        case json
        case multipartFormData(boundary: String)
            
        var headerValue: String {
            switch self {
            case .json:
                return "application/json"
            case .multipartFormData(let boundary):
                return "multipart/form-data; boundary=\(boundary)"
            }
        }
    }
    
}
