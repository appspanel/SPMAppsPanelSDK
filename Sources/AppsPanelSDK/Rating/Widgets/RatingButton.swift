//
//  RatingButton.swift
//  Notation
//
//  Created by AppsPanel on 23/03/2022.
//

import Foundation
import UIKit

class RatingButton: UIButton {
    
    var primaryBackgroundColor: UIColor?
    var disabledBackgroundColor: UIColor?
    var primaryTextColor: UIColor?
    var disabledTextColor: UIColor?
    
    override var isEnabled: Bool {
        didSet {
            updateColors()
        }
    }
    
    private func updateColors() {
        if isEnabled {
            setTitleColor(primaryTextColor, for: .normal)
            backgroundColor = primaryBackgroundColor
        } else {
            setTitleColor(disabledTextColor, for: .normal)
            backgroundColor = disabledBackgroundColor
        }
    }
}
