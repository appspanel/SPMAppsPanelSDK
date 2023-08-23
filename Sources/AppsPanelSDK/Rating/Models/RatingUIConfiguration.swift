//
//  RatingUIConfiguration.swift
//  Notation
//
//  Created by AppsPanel on 23/03/2022.
//

import Foundation
import UIKit

struct RatingUIConfiguration: Decodable {
    var ratingTitle: String
    var ratingClose: String
    var ratingSend: String
    var thanksTitle: String
    var thanksMessage: String
    var thanksMessageFeedback: String
    var thanksClose: String
    var thanksFeedback: String
    var style: RatingStyle
    var criteria: [RatingCriterion]
    
    private enum CodingKeys: String, CodingKey {
        case ratingTitle
        case ratingClose
        case ratingSend
        case thanksTitle
        case thanksMessage
        case thanksMessageFeedback
        case thanksClose
        case thanksFeedback
        case style = "design"
        case criteria
    }
}
