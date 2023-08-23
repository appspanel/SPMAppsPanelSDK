//
//  RatingStarView.swift
//  Notation
//
//  Created by AppsPanel on 23/03/2022.
//

import Foundation
import UIKit

protocol RatingPropositionDelegate {
    func starSelected(value: Int, criterion: RatingCriterion)
}

class RatingPropositionView: UIView {
    private var titleLabel = UILabel()
    private var contentStackView = UIStackView()
    
    private var contentSpacing: CGFloat = 8
    
    private var style: RatingStyle
    
    var delegate: RatingPropositionDelegate?
    private var criterion: RatingCriterion
    
    
    init(style: RatingStyle, criterion: RatingCriterion) {
        self.style = style
        self.criterion = criterion
        super.init(frame: CGRect.zero)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentStackView.axis = .vertical
        contentStackView.spacing = contentSpacing
        contentStackView.distribution = .fillProportionally
        
        addSubview(contentStackView)
        
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor),
            bottomAnchor.constraint(equalTo: contentStackView.bottomAnchor)
        ])
        
        titleLabel.font = style.ratingCriteriaFont
        titleLabel.textColor = style.ratingCriteriaColor
        titleLabel.text = criterion.name
        
        contentStackView.addArrangedSubview(titleLabel)
        
        let starsView = RatingStarsView(style: style)
        starsView.delegate = self
        contentStackView.addArrangedSubview(starsView)
        
    }

}

extension RatingPropositionView: RatingStarsViewDelegate {
    func starSelected(value: Int) {
        delegate?.starSelected(value: value, criterion: criterion)
    }
}
