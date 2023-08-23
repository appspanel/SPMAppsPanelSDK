//
//  CustomTextField.swift
//  Notation
//
//  Created by AppsPanel on 24/03/2022.
//

import Foundation
import UIKit

class FeedbackTextField: UITextField {
    
    private let padding = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    
    private var style: FeedbackStyle
    
    @IBInspectable var rightImage: UIImage? {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var rightPadding: CGFloat = 0
    
    @IBInspectable var color: UIColor = UIColor.lightGray {
        didSet {
            updateView()
        }
    }
    
    init(style: FeedbackStyle, placeholder: String) {
        self.style = style
        super.init(frame: .zero)
        self.setupUI(placeholder: placeholder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: padding.top, left: padding.left, bottom: padding.bottom, right: padding.right + rightPadding))
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: padding.top, left: padding.left, bottom: padding.bottom, right: padding.right + rightPadding))
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: padding.top, left: padding.left, bottom: padding.bottom, right: padding.right + rightPadding))
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.rightViewRect(forBounds: bounds)
        textRect.origin.x -= rightPadding
        return textRect
    }
    
    func updateView() {
        if let image = rightImage {
            rightViewMode = UITextField.ViewMode.always
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
            imageView.tintColor = color
            rightView = imageView
        } else {
            rightViewMode = UITextField.ViewMode.never
            rightView = nil
        }
    }
}

private extension FeedbackTextField {
    
    func setupUI(placeholder: String) {
        layer.cornerRadius = style.editRadius
        font = style.editFont
        layer.borderColor = style.secondaryColor.cgColor
        layer.borderWidth = style.editBorderWidth
        backgroundColor = style.secondaryBackgroundColor
        textColor = style.secondaryColor
        attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: style.secondaryColor,
                .font: style.editFont
            ]
        )
    }
}
