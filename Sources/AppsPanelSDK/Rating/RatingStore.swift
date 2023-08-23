//
//  RatingStore.swift
//  AppsPanelSDK
//
//  Copyright © 2022 Apps Panel. All rights reserved.
//

import Foundation

struct RatingStore {
    
    private enum Key {
        static let latestRatingShowingTimestamp = "LatestRatingShowingTimestamp"
        static let numberOfLaunchesSinceLastRatingShowing = "NumberOfLaunchesSinceLastRatingShowing"
    }
    
    // MARK: -
        
    private let userDefaults = UserDefaults.appsPanel
    
    // MARK: -
    
    var latestRatingShowingDate: Date {
        get {
            return Date(timeIntervalSince1970: latestRatingShowingTimestamp)
        }
        set {
            latestRatingShowingTimestamp = newValue.timeIntervalSince1970
        }
    }
    
    private var latestRatingShowingTimestamp: TimeInterval  {
        get {
            return userDefaults.double(forKey: Key.latestRatingShowingTimestamp)
        }
        set {
            userDefaults.set(newValue, forKey: Key.latestRatingShowingTimestamp)
        }
    }
    
    var numberOfLaunchesSinceLastRatingShowing: Int {
        get {
            return userDefaults.integer(forKey: Key.numberOfLaunchesSinceLastRatingShowing)
        }
        set {
            userDefaults.set(newValue, forKey: Key.numberOfLaunchesSinceLastRatingShowing)
        }
    }
    
    init() {
        if latestRatingShowingTimestamp == 0 {
            latestRatingShowingDate = Date()
        }
        
        //        store.ratingLastViewDate = Date()
        //        store.launchNumberSinceRatingLastView = 0
    }
    
}
