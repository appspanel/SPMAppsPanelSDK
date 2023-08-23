//
//  StarStackView.swift
//  Notation
//
//  Created by AppsPanel on 26/04/2022.
//

import Foundation
import UIKit

class StarStackView: UIStackView {
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        executeButtonAction(touches, with: event)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        executeButtonAction(touches, with: event)
    }
    
    private func executeButtonAction(_ touches: Set<UITouch>, with event: UIEvent? ) {
        if let touch = touches.first {
            let position = touch.location(in: self)
            
            guard let firstView = subviews.filter({ view in
                let newPoint = convert(position, to: view)
                return view.point(inside: newPoint, with: event)
            }).first else {
                return
            }
            
            if let button = firstView.subviews.first as? UIButton {
                button.sendActions(for: .touchUpInside)
            }
        }
    }
}
