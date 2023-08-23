//
//  FeedbackSubjectsView.swift
//  Notation
//
//  Created by AppsPanel on 24/03/2022.
//

import Foundation
import UIKit

protocol FeedbackSubjectsViewDelegate {
    func didSelectCategory(_ category: FeedbackCategory)
}

class FeedbackSubjectsView: UIView {
    
    private var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    private var titleLabel = UILabel()
    private var picker = UIPickerView()
    
    private var textField: FeedbackTextField!
    
    private var categories: [FeedbackCategory]
    
    private var selectedCategory: FeedbackCategory?
    
    private var configuration: FeedbackUIConfiguration
    
    var delegate: FeedbackSubjectsViewDelegate?
    
    init(configuration: FeedbackUIConfiguration) {
        self.configuration = configuration
        self.categories = configuration.categories
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


private extension FeedbackSubjectsView {
    
    func setupUI() {
        setupTitlePart()
        setupSelectionPart()
        setupContent()
    }
    
    func setupTitlePart() {
        titleLabel.text = configuration.feedbackCategoryTitle
        titleLabel.numberOfLines = 0
        titleLabel.font = configuration.style.headerTitleFont
        titleLabel.textColor = configuration.style.primaryColor
    }
    
    func setupSelectionPart() {
        picker.delegate = self
        picker.dataSource = self
        
        textField = FeedbackTextField(style: configuration.style, placeholder: configuration.feedbackCategoryPlaceholder)
        textField.delegate = self
        textField.inputView = picker
        textField.rightImage = UIImage(named: "icon-drop-down")
        textField.rightPadding = 16
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = .white
        toolBar.sizeToFit()

        let flexButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePicker))
        
        doneButton.tintColor = configuration.style.primaryColor
        
        toolBar.setItems([flexButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true

        textField.inputAccessoryView = toolBar
        
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc
    func donePicker() {
        endEditing(true)
        
        updateSelection()
    }
    
    func updateSelection() {
        // Prevent crash if `categories` is empty
        guard !categories.isEmpty else {
            return
        }
        
        let row = picker.selectedRow(inComponent: 0)
        let category = categories[row]
        
        selectedCategory = category
        textField.text = category.name
        
        delegate?.didSelectCategory(category)
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

extension FeedbackSubjectsView: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSelection()
    }
}

extension FeedbackSubjectsView: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

    }
}

extension FeedbackSubjectsView: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
}
