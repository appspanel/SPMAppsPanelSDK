//
//  RatingManager.swift
//  AppsPanelSDK
//
//  Created by AppsPanel on 22/04/2022.
//  Copyright © 2022 Apps Panel. All rights reserved.
//

import Foundation
import UIKit

public class RatingManager {

    public static let shared = RatingManager()
    
    private var configuration: RemoteConfiguration.RatingConfiguration? = nil
    private var feedbackConfiguration: RemoteConfiguration.FeedbackConfiguration? = nil

    private var store = RatingStore()
    
    // MARK: - Configure Module
    
    func configure(
        with configuration: RemoteConfiguration.RatingConfiguration,
        feedbackConfiguration: RemoteConfiguration.FeedbackConfiguration?
    ) {
        self.configuration = configuration
        self.feedbackConfiguration = feedbackConfiguration
        
        store.numberOfLaunchesSinceLastRatingShowing += 1
                
        guard configuration.isEnabled else {
            return
        }
        
        let numberOfLaunches = store.numberOfLaunchesSinceLastRatingShowing
        let lastDate = store.latestRatingShowingDate
        
        if numberOfLaunches > 1,
           numberOfLaunches >= configuration.minLaunchNumberSinceLastView,
           -lastDate.timeIntervalSinceNow >= configuration.minTimeSinceLastView
        {
            presentRating()
        }
    }
    
    func getUIConfiguration(forCampaignID compaignID: Int? = nil, completionHandler: @escaping (Result<RatingUIConfiguration, Error>) -> Void) {
        AppsPanel.shared.sdkRequestManager.request(endpoint: WebService.getRatingsConfiguration(campaignID: compaignID)).responseObject(RatingUIConfiguration.self, jsonDecoder: .default) { result in
            switch result {
            case .success(let response):
                completionHandler(.success(response.object))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    func sendRatingScores(_ scores: [RatingCriterionScore], completionHandler: @escaping (Result<Void, Error>) -> Void) {
        AppsPanel.shared.sdkRequestManager
            .request(endpoint: WebService.postRatings)
            .setBody(["criteria": scores.map { try! $0.asDictionary(jsonEncoder: .default) }])
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
    
    private func showRating(uiConfiguration: RatingUIConfiguration) {
        store.latestRatingShowingDate = Date()
        store.numberOfLaunchesSinceLastRatingShowing = 0
        
        let isFeedbackEnabled = feedbackConfiguration?.isEnabled ?? false
        
        let vc = RatingViewController(configuration: uiConfiguration, isFeedbackEnabled: isFeedbackEnabled)
        let topVC = UIApplication.shared.activeWindow?.topMostController()
        let navC = UINavigationController(rootViewController: vc)
        navC.modalTransitionStyle = .crossDissolve
        navC.modalPresentationStyle = .overFullScreen
        topVC?.present(navC, animated: true)
    }
    
    func presentRating(forCampaignID campaignID: Int?) {
        getUIConfiguration(forCampaignID: campaignID) { result in
            switch result {
            case .success(let uiConfiguration):
                self.showRating(uiConfiguration: uiConfiguration)
            case .failure(let error):
                print("[Rating] Unable to get UI configuration")
                print(error)
            }
        }
    }
    
    public func presentRating() {
        presentRating(forCampaignID: nil)
    }
    
}
