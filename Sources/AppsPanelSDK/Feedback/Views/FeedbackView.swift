//
//  FeedbackView.swift
//  Notation
//
//  Created by AppsPanel on 24/03/2022.
//

import Foundation
import UIKit

protocol FeedbackViewDelegate {
    func didSubmitFeedback(_ feedback: Feedback)
}

class FeedbackView: UIView {
    
    private var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 32
        return stackView
    }()
    
    private var formStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 16
        return stackView
    }()
    
    private var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private var padding: CGFloat = 32
    
    private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private var sendButton = RatingButton()
    
    private var configuration: FeedbackUIConfiguration
    
    private var feedbackSubjectsView: FeedbackSubjectsView
    private var feedbackCommentView: FeedbackCommentView
    private var feedbackContactView: FeedbackContactView
    
    private var categoryID: FeedbackCategory.ID?
    private var comment: String = ""
    private var contact: String?
    
    var delegate: FeedbackViewDelegate?
    
    init(configuration: FeedbackUIConfiguration) {
        self.configuration = configuration
        self.feedbackSubjectsView = FeedbackSubjectsView(configuration: configuration)
        self.feedbackCommentView = FeedbackCommentView(configuration: configuration)
        self.feedbackContactView = FeedbackContactView(configuration: configuration)
        super.init(frame: .zero)
        
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension FeedbackView {
    
    func setupUI() {
        
        feedbackSubjectsView.delegate = self
        feedbackCommentView.delegate = self
        feedbackContactView.delegate = self
        
        setupScrollView()
        setupDescriptionPart()
        setupButton()
        setupContentPart()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else {
            // if keyboard size is not available for some reason, dont do anything
            return
        }
        
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height , right: 0.0)
        
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    func setupDescriptionPart() {
        let style = configuration.style
        descriptionLabel.text = configuration.feedbackIntroduction
        descriptionLabel.textColor = style.introductionColor
        descriptionLabel.font = style.introductionFont
        descriptionLabel.adjustsFontSizeToFitWidth = false
        descriptionLabel.numberOfLines = 0
    }
    
    func setupButton() {
        let style = configuration.style
        sendButton.setTitle(configuration.feedbackButtonTitle, for: .normal)
        sendButton.primaryTextColor = style.buttonTextColor
        sendButton.disabledTextColor = style.disabledButtonTextColor
        sendButton.primaryBackgroundColor = style.buttonColor
        sendButton.disabledBackgroundColor = style.disabledButtonColor
        sendButton.titleLabel?.font = style.buttonFont
        sendButton.layer.cornerRadius = style.buttonRadius
        sendButton.isEnabled = false
        sendButton.addTarget(self, action: #selector(sendFeedback), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            sendButton.heightAnchor.constraint(equalToConstant: 64)
        ])
    }
    
    @objc
    func sendFeedback() {
        guard isFormValid() else {
            return
        }
        
        let feedback = Feedback(categoryID: categoryID ?? 0, comment: comment, contact: contact)
        delegate?.didSubmitFeedback(feedback)
    }
    
    func setupScrollView() {
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            contentView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(scrollView)
            scrollView.addSubview(contentView)
            scrollView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            scrollView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
            scrollView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        }
    
    func setupContentPart() {
        
        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector (removeFocus)))
        
        formStackView.addArrangedSubview(feedbackSubjectsView)
        formStackView.addArrangedSubview(feedbackCommentView)
        formStackView.addArrangedSubview(feedbackContactView)
        
        contentStackView.addArrangedSubview(descriptionLabel)
        contentStackView.addArrangedSubview(formStackView)
        contentStackView.addArrangedSubview(sendButton)
        
        contentView.addSubview(contentStackView)
        
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            contentView.bottomAnchor.constraint(equalTo: contentStackView.bottomAnchor, constant: padding),
            contentView.trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor, constant: padding)
        ])
    }
    
    @objc
    func removeFocus() {
        endEditing(true)
    }
    
    func updateSendButton() {
        sendButton.isEnabled = isFormValid()
    }
    
    func isFormValid() -> Bool {
        return categoryID != nil && !comment.isEmpty
    }
}

extension FeedbackView: FeedbackSubjectsViewDelegate {
    func didSelectCategory(_ category: FeedbackCategory) {
        categoryID = category.id
        updateSendButton()
    }
}

extension FeedbackView: FeedbackCommentDelegate {
    func didChangeComment(_ comment: String) {
        self.comment = comment
        updateSendButton()
    }
}

extension FeedbackView: FeedbackContactViewDelegate {
    func didChangeContact(_ contact: String) {
        let trimmedContact = contact.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedContact.isEmpty {
            self.contact = nil
        } else {
            self.contact = trimmedContact
        }
    }
}
