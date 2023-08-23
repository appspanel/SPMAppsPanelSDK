//
//  RatingStarsView.swift
//  Notation
//
//  Created by AppsPanel on 23/03/2022.
//

import Foundation
import UIKit

protocol RatingStarsViewDelegate {
    func starSelected(value: Int)
}

class RatingStarsView: UIView {
    
    private var starsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.isUserInteractionEnabled = false
        
        return stackView
    }()
    
    private var starButtons: [UIButton] = []
    private var style: RatingStyle
    
    var delegate: RatingStarsViewDelegate?
    
    init(style: RatingStyle) {
        self.style = style
        super.init(frame: .zero)
        self.setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        executeButtonAction(touches, with: event)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        executeButtonAction(touches, with: event)
    }
}

private extension RatingStarsView {
    
    func executeButtonAction(_ touches: Set<UITouch>, with event: UIEvent? ) {
        if let touch = touches.first {
            let position = touch.location(in: self)
            
            guard let buttonPressed = starButtons.filter({ button in
                let newPoint = convert(position, to: button)
                return button.point(inside: newPoint, with: event)
            }).first else {
                return
            }
            
            pressStar(buttonPressed: buttonPressed)
        }
    }
    
    func setupUI() {
        setupContent()
        setupStarButtons()
    }
    
    func setupContent() {
        addSubview(starsStackView)
        
        starsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            starsStackView.topAnchor.constraint(equalTo: topAnchor),
            starsStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            starsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            starsStackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func setupStarButtons() {
        for _ in 0...4 {
            let starButton = UIButton()
            starButton.isUserInteractionEnabled = false
            starButton.tintColor = style.starOffColor
            let image = UIImage(named: "star_off", in: Bundle.module, compatibleWith: nil)?
                .withRenderingMode(.alwaysTemplate)
            starButton.setImage(image, for: .normal)
            starsStackView.addArrangedSubview(starButton)
            starButtons.append(starButton)
        }
    }
    
    func pressStar(buttonPressed: UIButton) {
        guard let indexButtonPressed = starButtons.firstIndex(of: buttonPressed) else {
            return
        }
            
        starButtons.forEach { button in
            if let index = starButtons.firstIndex(of: button) {
                if index <= indexButtonPressed {
                    let image = UIImage(named: "star_on", in: Bundle.module, compatibleWith: nil)?
                        .withRenderingMode(.alwaysTemplate)
                    button.setImage(image, for: .normal)
                    button.tintColor = style.starOnColor
                } else {
                    let image = UIImage(named: "star_off", in: Bundle.module, compatibleWith: nil)?
                        .withRenderingMode(.alwaysTemplate)
                    button.setImage(image, for: .normal)
                    button.tintColor = style.starOffColor
                }
            }
        }
        
        delegate?.starSelected(value: indexButtonPressed)
    }
}
