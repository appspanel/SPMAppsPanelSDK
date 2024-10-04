//
//  FeedbackUIConfiguration.swift
//  Notation
//
//  Created by AppsPanel on 21/04/2022.
//

import Foundation

struct FeedbackUIConfiguration: Decodable {

    let feedbackButtonTitle: String
    let feedbackIntroduction: String
    let feedbackTitle: String
    let feedbackCommentTitle: String
    let feedbackCommentPlaceholder: String
    let feedbackContactTitle: String
    let feedbackContactPlaceholder: String
    let feedbackCategoryTitle: String
    let feedbackCategoryPlaceholder: String
    let thanksButtonTitle: String
    let thanksMessage: String
    let thanksTitle: String
    let categories: [FeedbackCategory]
    let style: FeedbackStyle

    enum CodingKeys: String, CodingKey {
        case style = "design"
        case categories
        case feedbackButtonTitle
        case feedbackIntroduction
        case feedbackTitle
        case feedbackCommentTitle
        case feedbackCommentPlaceholder
        case feedbackContactTitle
        case feedbackContactPlaceholder
        case feedbackCategoryTitle
        case feedbackCategoryPlaceholder
        case thanksButtonTitle
        case thanksMessage
        case thanksTitle
    }
}

struct FeedbackCategory: Identifiable, Decodable {
    typealias ID = Int
    
    let id: Int
    let name: String
}
