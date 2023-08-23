//
//  RatingDesign.swift
//  Notation
//
//  Created by AppsPanel on 21/04/2022.
//

import Foundation
import UIKit

struct RatingStyle: Decodable {
    
    private let buttonFontName: String
    private let buttonFontSize: CGFloat
    let buttonRadius: CGFloat
    private let dialogMessageColorHex: String
    private let dialogMessageFontName: String
    private let dialogMessageFontSize: CGFloat
    let dialogRadius: CGFloat
    private let dialogTitleColorHex: String
    private let dialogTitleFontName: String
    private let dialogTitleFontSize: CGFloat
    private let disabledButtonColorHex: String
    private let disabledButtonTextColorHex: String
    private let primaryButtonColorHex: String
    private let primaryButtonTextColorHex: String
    private let ratingCriteriaColorHex: String
    private let ratingCriteriaFontName: String
    private let ratingCriteriaFontSize: CGFloat
    private let secondaryButtonColorHex: String
    private let secondaryButtonTextColorHex: String
    private let starOffColorHex: String
    private let starOnColorHex: String
    
    init() {
        self.starOnColorHex = "#2c65ad"
        self.starOffColorHex = "#7088ac"
        self.dialogRadius = 64
        self.dialogTitleColorHex = "#5c636e"
        self.dialogTitleFontName = "Poppins-Bold"
        self.dialogTitleFontSize = 20
        self.ratingCriteriaColorHex = "#5c636e"
        self.ratingCriteriaFontName = "Poppins-Bold"
        self.ratingCriteriaFontSize = 20
        self.buttonRadius = 30
        self.buttonFontName = "Poppins-Bold"
        self.buttonFontSize = 16
        self.primaryButtonColorHex = "#2c65ad"
        self.primaryButtonTextColorHex = "#ffffff"
        self.disabledButtonColorHex = "#cfdae8"
        self.disabledButtonTextColorHex = "#7088ac"
        self.secondaryButtonColorHex = "#89bcfa"
        self.secondaryButtonTextColorHex = "#2c65ad"
        self.dialogMessageColorHex = "#2c65ad"
        self.dialogMessageFontName = "Poppins"
        self.dialogMessageFontSize = 14
    }
    
    private enum CodingKeys : String, CodingKey {
        case starOnColorHex = "starOnColor"
        case starOffColorHex = "starOffColor"
        case dialogRadius
        case dialogTitleColorHex = "dialogTitleColor"
        case dialogTitleFontName = "dialogTitleFont"
        case dialogTitleFontSize
        case ratingCriteriaColorHex = "ratingCriteriaColor"
        case ratingCriteriaFontName = "ratingCriteriaFont"
        case ratingCriteriaFontSize
        case buttonRadius
        case buttonFontName = "buttonFont"
        case buttonFontSize
        case primaryButtonColorHex = "primaryButtonColor"
        case primaryButtonTextColorHex = "primaryButtonTextColor"
        case disabledButtonColorHex = "disabledButtonColor"
        case disabledButtonTextColorHex = "disabledButtonTextColor"
        case secondaryButtonColorHex = "secondaryButtonColor"
        case secondaryButtonTextColorHex = "secondaryButtonTextColor"
        case dialogMessageColorHex = "dialogMessageColor"
        case dialogMessageFontName = "dialogMessageFont"
        case dialogMessageFontSize
    }
    
}

extension RatingStyle {
    
    var starOnColor: UIColor {
        return UIColor(hex: starOnColorHex) ?? .black
    }
    
    var starOffColor: UIColor {
        return UIColor(hex: starOffColorHex) ?? .black
    }
    
    var dialogTitleColor: UIColor {
        return UIColor(hex: dialogTitleColorHex) ?? .black
    }
        
    var dialogTitleFont: UIFont {
        if let font = UIFont(name: dialogTitleFontName, size: dialogTitleFontSize) {
            return font
        } else {
            return UIFont.systemFont(ofSize: dialogTitleFontSize)
        }
    }
    
    var ratingCriteriaColor: UIColor {
        return UIColor(hex: ratingCriteriaColorHex) ?? .black
    }
        
    var ratingCriteriaFont: UIFont {
        if let font = UIFont(name: ratingCriteriaFontName, size: ratingCriteriaFontSize) {
            return font
        } else {
            return UIFont.systemFont(ofSize: ratingCriteriaFontSize)
        }
    }
        
    var buttonFont: UIFont {
        if let font = UIFont(name: buttonFontName, size: buttonFontSize) {
            return font
        } else {
            return UIFont.systemFont(ofSize: buttonFontSize)
        }
    }
    
    var primaryButtonColor: UIColor {
        return UIColor(hex: primaryButtonColorHex) ?? .black
    }
        
    var primaryButtonTextColor: UIColor {
        return UIColor(hex: primaryButtonTextColorHex) ?? .white
    }
        
    var disabledButtonColor: UIColor {
        return UIColor(hex: disabledButtonColorHex) ?? .black
    }
        
    var disabledButtonTextColor: UIColor {
        return UIColor(hex: disabledButtonTextColorHex) ?? .white
    }
        
    var secondaryButtonColor: UIColor {
        return UIColor(hex: secondaryButtonColorHex) ?? .black
    }
    
    var secondaryButtonTextColor: UIColor {
        return UIColor(hex: secondaryButtonTextColorHex) ?? .white
    }
        
    var dialogMessageColor: UIColor {
        return UIColor(hex: dialogMessageColorHex) ?? .black
    }
        
    var dialogMessageFont: UIFont {
        if let font = UIFont(name: dialogMessageFontName, size: dialogMessageFontSize) {
            return font
        } else {
            return UIFont.systemFont(ofSize: dialogMessageFontSize)
        }
    }
    
}
