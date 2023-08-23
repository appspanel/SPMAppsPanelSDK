//
//  FeedbackContactView.swift
//  Notation
//
//  Created by AppsPanel on 24/03/2022.
//

import Foundation
import UIKit

protocol FeedbackContactViewDelegate {
    func didChangeContact(_ contact: String)
}

class FeedbackContactView: UIView {
    
    private var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    private var titleLabel = UILabel()
    
    private var textField: FeedbackTextField!
    
    private var configuration: FeedbackUIConfiguration
    
    var delegate: FeedbackContactViewDelegate?
    
    init(configuration: FeedbackUIConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isFirstResponder: Bool {
        return textField.isFirstResponder
    }
}

private extension FeedbackContactView {
    
    func setupUI() {
        setupTitlePart()
        setupContactPart()
        setupContent()
    }
    
    func setupTitlePart() {
        titleLabel.text = configuration.feedbackContactTitle
        titleLabel.numberOfLines = 0
        titleLabel.font = configuration.style.headerTitleFont
        titleLabel.textColor = configuration.style.primaryColor
    }
    
    func setupContactPart() {
        textField = FeedbackTextField(style: configuration.style, placeholder: configuration.feedbackContactPlaceholder)
        textField.delegate = self
        
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func setupContent() {
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(textField)
        
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

extension FeedbackContactView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let style = configuration.style
        textField.layer.borderColor = string.isEmpty ? style.secondaryColor.cgColor : style.primaryColor.cgColor
        titleLabel.textColor = string.isEmpty ? style.secondaryColor : style.primaryColor
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.didChangeContact(textField.text ?? "")
    }
}
