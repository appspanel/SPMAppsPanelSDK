//
//  RatingThanksView.swift
//  Notation
//
//  Created by AppsPanel on 23/03/2022.
//

import Foundation
import UIKit

protocol RatingThanksViewDelegate {
    func gotToFeedback()
    func cancelThanks()
}

class RatingThanksView: UIView {
    
    private var cancelButton = RatingButton()
    private var feedbackButton = RatingButton()
    private var contentStackView = UIStackView()
    private var titleLabel = UILabel()
    private var textLabel = UILabel()
    
    let contentView = UIView()
    
    private var popupView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        return stackView
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private var padding: CGFloat = 32
    
    private var contentSpacing: CGFloat = 16
    private var ratingContainerSpacing: CGFloat = 32
    private var buttonHeight: CGFloat = 64
    
    private var configuration: RatingUIConfiguration
    
    private var isFeedbackEnabled: Bool
    
    var delegate: RatingThanksViewDelegate?
    
    init(configuration: RatingUIConfiguration, isFeedbackEnabled: Bool) {
        self.configuration = configuration
        self.isFeedbackEnabled = isFeedbackEnabled
        super.init(frame: .zero)
        self.setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension RatingThanksView {
    
    func setupUI() {
        backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        setupTitlePart()
        setupTextPart()
        setupButtonsPart()
        
        setupContentPart()
        setupPopup()
    }
    
    func setupButtonsPart() {
        let style = configuration.style
        
        feedbackButton.setTitle(configuration.thanksFeedback, for: .normal)
        feedbackButton.primaryTextColor = .white
        feedbackButton.disabledTextColor = style.disabledButtonTextColor
        feedbackButton.primaryBackgroundColor = style.primaryButtonColor
        feedbackButton.disabledBackgroundColor = style.disabledButtonColor
        feedbackButton.titleLabel?.font = style.buttonFont
        feedbackButton.isEnabled = true
        feedbackButton.addTarget(self, action: #selector(gotToFeedback), for: .touchUpInside)
        feedbackButton.layer.cornerRadius = style.buttonRadius
        feedbackButton.isHidden = !isFeedbackEnabled
        
        cancelButton.setTitle(configuration.thanksClose, for: .normal)
        cancelButton.primaryTextColor = style.secondaryButtonTextColor
        cancelButton.disabledTextColor = style.disabledButtonTextColor
        cancelButton.titleLabel?.font = style.buttonFont
        cancelButton.disabledBackgroundColor = style.disabledButtonColor
        cancelButton.primaryBackgroundColor = style.secondaryButtonColor
        cancelButton.isEnabled = true
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        cancelButton.layer.cornerRadius = style.buttonRadius
        
        buttonStackView.addArrangedSubview(feedbackButton)
        buttonStackView.addArrangedSubview(cancelButton)
    }
    
    @objc
    func cancel() {
        delegate?.cancelThanks()
    }
    
    @objc
    func gotToFeedback() {
        //TODO
        delegate?.gotToFeedback()
    }
    
    func setupTitlePart() {
        titleLabel.text = configuration.thanksTitle
        titleLabel.font = configuration.style.dialogTitleFont
        titleLabel.textColor = configuration.style.dialogTitleColor
        titleLabel.numberOfLines = 0
    }
    
    func setupTextPart() {
        if isFeedbackEnabled {
            textLabel.text = configuration.thanksMessageFeedback
        } else {
            textLabel.text = configuration.thanksMessage
        }
        textLabel.font = configuration.style.dialogMessageFont
        textLabel.textColor = configuration.style.dialogMessageColor
        textLabel.numberOfLines = 0
    }
    
    func setupContentPart() {
        contentStackView.axis = .vertical
        contentStackView.distribution = .fill
        contentStackView.spacing = contentSpacing
        
        contentView.addSubview(contentStackView)
        contentView.addSubview(buttonStackView)
        
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            contentView.trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor, constant: padding),
            
            buttonStackView.topAnchor.constraint(equalTo: contentStackView.bottomAnchor, constant: 32),
            
            buttonStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            contentView.trailingAnchor.constraint(equalTo: buttonStackView.trailingAnchor, constant: padding),
            contentView.bottomAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: padding),
            
            feedbackButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            cancelButton.heightAnchor.constraint(equalToConstant: buttonHeight)
        ])
        
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(textLabel)
        
        scrollView.layer.cornerRadius = configuration.style.dialogRadius
        scrollView.addSubview(contentView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor, constant: 0)
        ])
    }
    
    func setupPopup() {
        popupView.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: popupView.topAnchor),
            scrollView.rightAnchor.constraint(equalTo: popupView.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: popupView.bottomAnchor),
            scrollView.leftAnchor.constraint(equalTo: popupView.leftAnchor)
        ])
        
        popupView.layer.cornerRadius = configuration.style.dialogRadius
        addSubview(popupView)
        
        popupView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            popupView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor, multiplier: 0.8),
            popupView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
            popupView.centerXAnchor.constraint(equalTo: centerXAnchor),
            popupView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
}
