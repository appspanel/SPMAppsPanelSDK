//
//  RatingView.swift
//  Notation
//
//  Created by AppsPanel on 22/03/2022.
//

import Foundation
import UIKit

protocol RatingViewDelegate {
    func didScore(_ score: Int, criterion: RatingCriterion)
    func validateRating(criteria: [RatingCriterion])
    func cancelRating()
}

class RatingView: UIView {
    
    let contentView = UIView()
    
    private var titleLabel = UILabel()
    private var cancelButton = RatingButton()
    var validateButton = RatingButton()
    private var contentStackView = UIStackView()
    private var ratingContainerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        return stackView
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
    private var criteria: [RatingCriterion]
    
    var delegate: RatingViewDelegate?
    
    init(configuration: RatingUIConfiguration) {
        self.configuration = configuration
        self.criteria = configuration.criteria
        super.init(frame: .zero)
        self.setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension RatingView {
    
    func setupUI() {
        backgroundColor = UIColor(white: 0, alpha: 0.5) //TODO
        
        setupTitlePart()
        setupRatingPart()
        setupButtonsPart()
        
        setupContentPart()
        setupPopup()
    }
    
    func setupTitlePart() {
        let style = configuration.style
        
        titleLabel.text = configuration.ratingTitle
        titleLabel.font = style.dialogTitleFont
        titleLabel.textColor = style.dialogTitleColor
        
        titleLabel.heightAnchor.constraint(equalToConstant: 28).isActive = true
    }
    
    func setupRatingPart() {
        ratingContainerStackView.spacing = ratingContainerSpacing
        
        let style = configuration.style
        
        criteria.forEach { criterion in
            let ratingStarView = RatingPropositionView(style: style, criterion: criterion)
            ratingStarView.delegate = self
            ratingContainerStackView.addArrangedSubview(ratingStarView)
        }
    }
    
    func setupButtonsPart() {
        let style = configuration.style
        
        validateButton.setTitle(configuration.ratingSend, for: .normal)
        validateButton.primaryTextColor = style.primaryButtonTextColor
        validateButton.disabledTextColor = style.disabledButtonTextColor
        validateButton.primaryBackgroundColor = style.primaryButtonColor
        validateButton.disabledBackgroundColor = style.disabledButtonColor
        validateButton.titleLabel?.font = style.buttonFont
        validateButton.isEnabled = false
        validateButton.addTarget(self, action: #selector(validateRating), for: .touchUpInside)
        validateButton.layer.cornerRadius = style.buttonRadius
        
        cancelButton.setTitle(configuration.ratingClose, for: .normal)
        cancelButton.primaryTextColor = style.secondaryButtonTextColor
        cancelButton.disabledTextColor = style.disabledButtonTextColor
        cancelButton.primaryBackgroundColor = style.secondaryButtonColor
        cancelButton.disabledBackgroundColor = style.disabledButtonColor
        cancelButton.titleLabel?.font = style.buttonFont
        
        cancelButton.isEnabled = true
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        cancelButton.layer.cornerRadius = style.buttonRadius
        
        buttonStackView.addArrangedSubview(validateButton)
        buttonStackView.addArrangedSubview(cancelButton)
    }
    
    @objc
    func cancel() {
        delegate?.cancelRating()
    }
    
    @objc
    func validateRating() {
        //TODO check if can validate
        delegate?.validateRating(criteria: criteria)
    }
    
    func setupContentPart() {
        
        contentStackView.axis = .vertical
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
            buttonStackView.heightAnchor.constraint(equalToConstant: buttonHeight * 2 + contentSpacing),
            
            buttonStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            contentView.trailingAnchor.constraint(equalTo: buttonStackView.trailingAnchor, constant: padding),
            contentView.bottomAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: padding)
        ])
        
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(ratingContainerStackView)
        
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
        let popupView = UIView()
        popupView.backgroundColor = .white
        popupView.layer.cornerRadius = configuration.style.dialogRadius
        popupView.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: popupView.topAnchor),
            scrollView.rightAnchor.constraint(equalTo: popupView.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: popupView.bottomAnchor),
            scrollView.leftAnchor.constraint(equalTo: popupView.leftAnchor)
        ])
        
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

extension RatingView: RatingPropositionDelegate {
    func starSelected(value: Int, criterion: RatingCriterion) {
        delegate?.didScore(value, criterion: criterion)
    }
}
