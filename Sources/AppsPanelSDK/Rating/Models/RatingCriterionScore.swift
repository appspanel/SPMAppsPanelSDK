//
//  RatingCriterionScore.swift
//  AppsPanelSDK
//
//  Copyright © 2022 Apps Panel. All rights reserved.
//

import Foundation

struct RatingCriterionScore: Encodable {
    let criterionID: RatingCriterion.ID
    let value: Int
    
    enum CodingKeys: String, CodingKey {
        case criterionID = "id"
        case value
    }
}
