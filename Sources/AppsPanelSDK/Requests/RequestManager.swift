//
//  RequestManager.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 27/07/2018.
//  Copyright © 2018 Apps Panel. All rights reserved.
//

import Alamofire
import Foundation

public typealias Parameters = [String: Any]
public typealias Headers = [String: String]

public enum HTTPMethod: String, Codable {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case put = "PUT"
    case delete = "DELETE"
}

public class RequestManager {

    typealias SessionManager = Alamofire.Session
    private let sessionManager: SessionManager
    
    let baseURL: URL
    public var inhibitsCancellationErrors: Bool = true
    public var defaultSecurityOptions: Security.Options = .jsonWebToken
    var defaultTimeout: TimeInterval?

    private static var _default: RequestManager?
    public static var `default`: RequestManager {
        if _default == nil {
            _default = RequestManager(baseURL: AppsPanel.shared.configuration.baseURL)
        }
        return _default!
    }
    
    static var customHeaders: Headers?

    // MARK: Initialize a request manager

    public init(baseURL: URL) {
        self.baseURL = baseURL
        self.sessionManager = SessionManager()
    }

    // MARK: Make a request

    @discardableResult
    public func request(_ path: String,
                        method: HTTPMethod,
                        parameters: Parameters? = nil) -> DataRequest
    {
        do {
            let urlRequest = try self.urlRequest(path: path, method: method, parameters: parameters)
            return DataRequest(requestManager: self, request: urlRequest)
        } catch {
            let urlRequest = self.urlRequest(path: path, method: method)
            return DataRequest(requestManager: self, request: urlRequest)
        }
    }

    @discardableResult
    func uploadRequest(_ fileUpload: FileUpload) -> DataRequest {
        let urlRequest = self.urlRequest(fileUpload: fileUpload)
        let dataRequest = DataRequest(requestManager: self, request: urlRequest)
        dataRequest.useUserToken()
        dataRequest.timeout = fileUpload.timeout
        return dataRequest
    }

    func uploadRequest(_ imageUpload: ImageUpload) -> DataRequest {
        let urlRequest = self.urlRequest(imageUpload: imageUpload)
        let dataRequest = DataRequest(requestManager: self, request: urlRequest)
        dataRequest.useUserToken()
        dataRequest.timeout = imageUpload.timeout
        return dataRequest
    }

    @discardableResult
    public func upload(_ fileUpload: FileUpload, completion completionHandler: @escaping FileUploadCompletionHandler) -> URLSessionTask? {
        let request = uploadRequest(fileUpload).responseObject(UploadedFile.self) { result in
            switch result {
            case .success(let response):
                let fileUploadResponse = FileUploadResponse(uploadedFile: response.object, response: response)
                completionHandler(.success(fileUploadResponse))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
        return request.task
    }

    @discardableResult
    public func upload(_ imageUpload: ImageUpload, completion completionHandler: @escaping ImageUploadCompletionHandler) -> URLSessionTask? {
        let request = uploadRequest(imageUpload).responseObject(UploadedImage.self) { result in
            switch result {
            case .success(let response):
                let fileUploadResponse = ImageUploadResponse(uploadedImage: response.object, response: response)
                completionHandler(.success(fileUploadResponse))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
        return request.task
    }

    @discardableResult
    func sendRequest(_ request: URLRequest,
                     downloadProgress downloadProgressHandler: DownloadProgressHandler? = nil,
                     completion completionHandler: @escaping DataCompletionHandler) -> URLSessionTask?
    {
        // Prevent AF error if the response is empty with an inappropriate HTTP code
        let responseSerializer = DataResponseSerializer(emptyResponseCodes: Set(200..<300))
        
        let dataRequest = sessionManager.request(request)
            .validate() // 200..<300
            .response(responseSerializer: responseSerializer) { response in
                let result = self.result(for: response)

                if case let .failure(error) = result,
                    error.isCancelledError,
                    self.inhibitsCancellationErrors {
                    return
                }

                completionHandler(result)
            }
            .downloadProgress { progress in
                downloadProgressHandler?(progress)
            }

        return dataRequest.task
    }

    // MARK: Handle the request's result

    private func result(for dataResponse: AFDataResponse<Data>) -> Result<DataResponse, RequestError> {
        switch dataResponse.result {
        case .success(let data):
            guard let response = dataResponse.response,
                let request = dataResponse.request else
            {
                let requestError = RequestError(request: dataResponse.request,
                                                response: dataResponse.response,
                                                data: data,
                                                cause: RequestError.Cause.unknown)
                return Swift.Result.failure(requestError)
            }

            let dataResponse = DataResponse(data: data,
                                            statusCode: response.statusCode,
                                            request: request,
                                            response: response)
            return Swift.Result.success(dataResponse)

        case .failure(let error):
            let cause = RequestError.Cause(from: error)
            let requestError = RequestError(request: dataResponse.request,
                                            response: dataResponse.response,
                                            data: dataResponse.data,
                                            cause: cause)
            return Swift.Result.failure(requestError)
        }
    }

}

// MARK: -

extension RequestManager {

    func urlRequest(path: String,
                    method: HTTPMethod,
                    parameters: Parameters?) throws -> URLRequest
    {
        let urlRequest = self.urlRequest(path: path, method: method)

        // Add query params
        if let parameters = parameters {
            let urlEncoding = URLEncoding(destination: .queryString, arrayEncoding: .brackets, boolEncoding: .literal)
            return try urlEncoding.encode(urlRequest, with: parameters)
        } else {
            return urlRequest
        }
    }

    func urlRequest(path: String,
                    method: HTTPMethod) -> URLRequest
    {
        let url = baseURL.appendingPathComponent(path)

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        return urlRequest
    }

    private func urlRequest(fileUpload: FileUpload) -> URLRequest {
        let url = baseURL.appendingPathComponent("files/upload")
        let formData = FormData(fileUpload: fileUpload)

        return urlRequest(withURL: url, formData: formData)
    }

    private func urlRequest(imageUpload: ImageUpload) -> URLRequest {
        let url = baseURL.appendingPathComponent("images/upload")
        let formData = FormData(imageUpload: imageUpload)

        return urlRequest(withURL: url, formData: formData)
    }

    private func urlRequest(withURL url: URL, formData: FormData) -> URLRequest {
        var request = URLRequest(url: url)

        request.httpMethod = HTTPMethod.post.rawValue
        request.addValue("multipart/form-data; boundary=\(formData.boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = formData.data

        return request
    }

}
