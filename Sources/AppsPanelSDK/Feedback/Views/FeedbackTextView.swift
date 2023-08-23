//
//  FeedbackTextView.swift
//  Notation
//
//  Created by AppsPanel on 24/03/2022.
//

import Foundation
import UIKit

class FeedbackTextView: UITextView {
    
    private let padding = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    
    private var style: FeedbackStyle
    
    init(style: FeedbackStyle) {
        self.style = style
        super.init(frame: .zero, textContainer: nil)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension FeedbackTextView {
    
    func setupUI() {
        textContainerInset = padding
        layer.cornerRadius = style.editRadius
        font = style.editFont
        textColor = style.primaryColor
        layer.borderWidth = style.editBorderWidth
        layer.borderColor = style.secondaryColor.cgColor
        backgroundColor = style.secondaryBackgroundColor
    }
    
}
