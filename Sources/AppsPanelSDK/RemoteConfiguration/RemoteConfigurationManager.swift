//
//  RemoteConfigurationManager.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 17/08/2018.
//  Copyright © 2018 Apps Panel. All rights reserved.
//

import Foundation

class RemoteConfigurationManager {

    private let requestManager: RequestManager
    
    private let savedFileName = "RemoteConfiguration.json"

    private let defaultFileName = "DefaultRemoteConfiguration.json"
    
    init(requestManager: RequestManager) {
        self.requestManager = requestManager
    }

    func getConfiguration(completion: @escaping (Result<RemoteConfiguration, RequestError>) -> Void) {
        requestManager.request(endpoint: WebService.getConfiguration)
            .responseObject(RemoteConfiguration.self, jsonDecoder: JSONDecoder.default)
        { result in
            switch result {
            case let .success(response):
                self.saveRemoteConfiguration(response.data)
                
                var configuration = response.object
                configuration.applicationParameters = self.applicationParameters(forRemoteConfiguration: response.data)
                completion(.success(configuration))
            case let .failure(error):
                guard let fallbackConfiguration = self.fallbackRemoteConfiguration() else {
                    completion(.failure(error))
                    return
                }
                
                completion(.success(fallbackConfiguration))
            }
        }
    }

    private func applicationParameters(forRemoteConfiguration data: Data) -> [String: Any]? {
        guard let configuration = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            return nil
        }

        return configuration["parameters"] as? [String: Any]
    }
    
    // MARK: -
    
    private func saveRemoteConfiguration(_ data: Data) {
        let fileManager = FileManager.default
        
        do {
            let directoryURL = fileManager.sdkApplicationSupportDirectoryURL
            let fileURL = directoryURL.appendingPathComponent(savedFileName)

            // Create directory
            try! fileManager.createDirectory(at: directoryURL)
            
            // Write to file
            try data.write(to: fileURL, options: .atomic)
            
            print("[Remote Configuration] Saved")
        } catch {
            print("[Remote Configuration] Unabled to save the remote configuration")
        }
    }
    
    private func savedRemoteConfigurationData() -> Data? {
        let fileManager = FileManager.default
        let fileURL = fileManager.sdkApplicationSupportDirectoryURL.appendingPathComponent(savedFileName)
        
        do {
            return try Data(contentsOf: fileURL)
        } catch {
            return nil
        }
    }
    
    private func savedRemoteConfiguration() -> RemoteConfiguration? {
        guard let data = savedRemoteConfigurationData() else {
            return nil
        }
        
        do {
            return try JSONDecoder.default.decode(RemoteConfiguration.self, from: data)
        } catch {
            return nil
        }
    }
    
    private func defaultRemoteConfiguration() -> RemoteConfiguration? {
        let bundle = Bundle.appsPanelResources
        
        guard let url = bundle.url(forResource: defaultFileName, withExtension: nil) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder.default.decode(RemoteConfiguration.self, from: data)
        } catch {
            return nil
        }
    }
    
    private func fallbackRemoteConfiguration() -> RemoteConfiguration? {
        if let savedConfiguration = savedRemoteConfiguration() {
            print("[Remote Configuration] Using a saved remote configuration")
            return savedConfiguration
        } else if let defaultConfiguration = defaultRemoteConfiguration() {
            print("[Remote Configuration] Using the saved remote configuration")
            return defaultConfiguration
        } else {
            print("[Remote Configuration] Unable to get the default remote configuration")
            return nil
        }
    }
    
}
