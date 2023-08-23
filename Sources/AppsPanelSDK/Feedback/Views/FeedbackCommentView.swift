//
//  FeedbackCommentView.swift
//  Notation
//
//  Created by AppsPanel on 24/03/2022.
//

import Foundation
import UIKit

protocol FeedbackCommentDelegate {
    func didChangeComment(_ comment: String)
}

class FeedbackCommentView: UIView {
    
    private var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    private var textView: FeedbackTextView!
    
    private var titleLabel = UILabel()
    
    private var configuration: FeedbackUIConfiguration
    
    var delegate: FeedbackCommentDelegate?
    
    init(configuration: FeedbackUIConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isFirstResponder: Bool {
        return textView.isFirstResponder
    }
}

private extension FeedbackCommentView {
    
    func setupUI() {
        setupTitlePart()
        setupCommentPart()
        setupContent()
    }
    
    func setupTitlePart() {
        titleLabel.text = configuration.feedbackCommentTitle
        titleLabel.numberOfLines = 0
        titleLabel.font = configuration.style.headerTitleFont
        titleLabel.textColor = configuration.style.primaryColor
    }
    
    func setupCommentPart() {
        let style = configuration.style
        textView = FeedbackTextView(style: style)
        textView.delegate = self
        placeholderFont = style.editFont
        placeholderColor = style.secondaryColor
        placeholder = configuration.feedbackCommentPlaceholder
        
        NSLayoutConstraint.activate([
            textView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    func setupContent() {
        
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(textView)
        
        addSubview(contentStackView)
        
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
}

extension FeedbackCommentView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if let placeholderLabel = self.textView.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = !self.textView.text.isEmpty
        }
        
        let style = configuration.style
        
        textView.layer.borderColor = textView.text.isEmpty ? style.secondaryColor.cgColor : style.primaryColor.cgColor
        titleLabel.textColor = textView.text.isEmpty ? style.secondaryColor : style.primaryColor
        
        delegate?.didChangeComment(textView.text)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.didChangeComment(textView.text)
    }
}


//MARK: TextView placeholder
//https://tij.me/blog/adding-placeholders-to-uitextviews-in-swift/

private extension FeedbackCommentView {
    
    var placeholderLabel: UILabel? {
        get {
            return textView.viewWithTag(100) as? UILabel
        }
    }

    var placeholderFont: UIFont? {
        get {
            return placeholderLabel?.font
        }
        set {
            if let placeholderLabel = placeholderLabel {
                placeholderLabel.font = newValue
            } else {
                addPlaceholder()
                placeholderLabel?.font = newValue
            }
        }
    }

    var placeholderColor: UIColor? {
        get {
            return placeholderLabel?.textColor
        }
        set {
            if let placeholderLabel = placeholderLabel {
                placeholderLabel.textColor = newValue
            } else {
                addPlaceholder()
                placeholderLabel?.textColor = newValue
            }
        }
    }

    /// The UITextView placeholder text
    var placeholder: String? {
        get {
            return placeholderLabel?.text
        }
        set {
            if let placeholderLabel = placeholderLabel {
                placeholderLabel.text = newValue
                placeholderLabel.sizeToFit()
            } else {
                addPlaceholder(newValue!)
                updateUI()
            }
        }
    }

    func updateUI() {
        if let placeholderLabel = placeholderLabel {
            placeholderLabel.font = placeholderFont
            placeholderLabel.textColor = placeholderColor
        }
    }

    /// Adds a placeholder UILabel to this UITextView
    func addPlaceholder(_ placeholderText: String? = nil) {
        let placeholderLabel = UILabel()

        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()
        placeholderLabel.tag = 100

        placeholderLabel.isHidden = !textView.text.isEmpty

        textView.addSubview(placeholderLabel)

        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: textView.textContainerInset.top + 3), // Add 3 to place it correctly
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant:  textView.textContainerInset.left + 4), // Add 4 to place it correctly
            placeholderLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant:  textView.textContainerInset.right)
        ])
    }
}
