//
//  FeedbackManager.swift
//  AppsPanelSDK
//
//  Copyright © 2022 Apps Panel. All rights reserved.
//

import Foundation
import UIKit

public class FeedbackManager {

    public static let shared = FeedbackManager()
    
    private var configuration: RemoteConfiguration.FeedbackConfiguration? = nil
    
    private var store = RatingStore()
    
    // MARK: - Configure Module
    
    func configure(with configuration: RemoteConfiguration.FeedbackConfiguration) {
        self.configuration = configuration
        
        guard configuration.isEnabled else {
            return
        }
    }
    
    func getUIConfiguration(completionHandler: @escaping (Result<FeedbackUIConfiguration, Error>) -> Void) {
        AppsPanel.shared.sdkRequestManager
            .request(endpoint: WebService.getFeedbackConfiguration)
            .responseObject(FeedbackUIConfiguration.self, jsonDecoder: .default)
        { result in
            switch result {
            case .success(let response):
                completionHandler(.success(response.object))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    func sendFeedback(_ feedback: Feedback, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        AppsPanel.shared.sdkRequestManager
            .request(endpoint: WebService.postFeedback)
            .setBody(feedback, jsonEncoder: .default)
            .responseData
        { result in
            switch result {
            case .success:
                completionHandler(.success(()))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    private func presentFeedback(with configuration: FeedbackUIConfiguration) {
        let feedbackVC = FeedbackViewController(configuration: configuration)
        let navigationController = UINavigationController(rootViewController: feedbackVC)
        navigationController.modalPresentationStyle = .overFullScreen
        UIApplication.shared.activeWindow?.topMostController()?.present(navigationController, animated: true)
    }
    
    public func presentFeedback() {
        getUIConfiguration { [weak self] result in
            guard let self else {
                return
            }
            
            switch result {
            case .success(let uiConfiguration):
                self.presentFeedback(with: uiConfiguration)
            case .failure(let error):
                print("[Feedback] Unable to get UI configuration")
                print(error)
            }
        }
    }
    
}
