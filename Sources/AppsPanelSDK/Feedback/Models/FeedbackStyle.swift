//
//  FeedbackStyle.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 18/11/2022.
//  Copyright © 2022 Apps Panel. All rights reserved.
//

import Foundation
import UIKit

struct FeedbackStyle: Decodable {
    private let buttonColorHex: String
    private let buttonFontName: String
    private let buttonFontSize: CGFloat
    let buttonRadius: CGFloat
    private let buttonTextColorHex: String
    private let dialogMessageFontName: String
    private let dialogMessageFontSize: CGFloat
    let dialogRadius: CGFloat
    private let dialogTitleFontName: String
    private let dialogTitleFontSize: CGFloat
    private let disabledButtonColorHex: String
    private let disabledButtonTextColorHex: String
    let editBorderWidth: CGFloat
    private let editFontName: String
    private let editFontSize: CGFloat
    let editRadius: CGFloat
    private let headerTitleFontName: String
    private let headerTitleFontSize: CGFloat
    private let introductionColorHex: String
    private let introductionFontName: String
    private let introductionFontSize: CGFloat
    private let primaryBackgroundColorHex: String
    private let primaryColorHex: String
    private let secondaryBackgroundColorHex: String
    private let secondaryColorHex: String
    private let titleFontName: String
    private let titleFontSize: CGFloat

    enum CodingKeys: String, CodingKey {
        case buttonColorHex = "buttonColor"
        case buttonFontName = "buttonFont"
        case buttonFontSize
        case buttonRadius
        case buttonTextColorHex = "buttonTextColor"
        case dialogMessageFontName = "dialogMessageFont"
        case dialogMessageFontSize
        case dialogRadius
        case dialogTitleFontName = "dialogTitleFont"
        case dialogTitleFontSize
        case disabledButtonColorHex = "disabledButtonColor"
        case disabledButtonTextColorHex = "disabledButtonTextColor"
        case editBorderWidth
        case editFontName = "editFont"
        case editFontSize
        case editRadius
        case headerTitleFontName = "headerTitleFont"
        case headerTitleFontSize
        case introductionColorHex = "introductionColor"
        case introductionFontName = "introductionFont"
        case introductionFontSize
        case primaryBackgroundColorHex = "primaryBackgroundColor"
        case primaryColorHex = "primaryColor"
        case secondaryBackgroundColorHex = "secondaryBackgroundColor"
        case secondaryColorHex = "secondaryColor"
        case titleFontName = "titleFont"
        case titleFontSize
    }
}

extension FeedbackStyle {
    var buttonColor: UIColor {
        return UIColor(hex: buttonColorHex) ?? .black
    }
    
    var buttonFont: UIFont {
        if let font = UIFont(name: buttonFontName, size: buttonFontSize) {
            return font
        } else {
            return UIFont.systemFont(ofSize: buttonFontSize)
        }
    }
    
    var buttonTextColor: UIColor {
        return UIColor(hex: buttonTextColorHex) ?? .black
    }
    
    var dialogMessageFont: UIFont {
        if let font = UIFont(name: dialogMessageFontName, size: dialogMessageFontSize) {
            return font
        } else {
            return UIFont.systemFont(ofSize: dialogMessageFontSize)
        }
    }
    
    var dialogTitleFont: UIFont {
        if let font = UIFont(name: dialogTitleFontName, size: dialogTitleFontSize) {
            return font
        } else {
            return UIFont.systemFont(ofSize: dialogTitleFontSize)
        }
    }
    
    var disabledButtonColor: UIColor {
        return UIColor(hex: disabledButtonColorHex) ?? .black
    }
    
    var disabledButtonTextColor: UIColor {
        return UIColor(hex: disabledButtonTextColorHex) ?? .black
    }
    
    var editFont: UIFont {
        if let font = UIFont(name: editFontName, size: editFontSize) {
            return font
        } else {
            return UIFont.systemFont(ofSize: editFontSize)
        }
    }
    
    var headerTitleFont: UIFont {
        if let font = UIFont(name: headerTitleFontName, size: headerTitleFontSize) {
            return font
        } else {
            return UIFont.systemFont(ofSize: headerTitleFontSize)
        }
    }
    
    var introductionColor: UIColor {
        return UIColor(hex: introductionColorHex) ?? .black
    }
    
    var introductionFont: UIFont {
        if let font = UIFont(name: introductionFontName, size: introductionFontSize) {
            return font
        } else {
            return UIFont.systemFont(ofSize: introductionFontSize)
        }
    }
    
    var primaryBackgroundColor: UIColor {
        return UIColor(hex: primaryBackgroundColorHex) ?? .black
    }
    
    var primaryColor: UIColor {
        return UIColor(hex: primaryColorHex) ?? .black
    }
    
    var secondaryBackgroundColor: UIColor {
        return UIColor(hex: secondaryBackgroundColorHex) ?? .black
    }
    
    var secondaryColor: UIColor {
        return UIColor(hex: secondaryColorHex) ?? .black
    }
    
    var titleFont: UIFont {
        if let font = UIFont(name: titleFontName, size: titleFontSize) {
            return font
        } else {
            return UIFont.systemFont(ofSize: titleFontSize)
        }
    }
    
}
