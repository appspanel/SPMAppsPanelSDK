//
//  RatingViewController.swift
//  AppsPanelSDK
//
//  Copyright © 2022 Apps Panel. All rights reserved.
//

import Foundation
import UIKit

class RatingViewController: UIViewController {
    
    private let ratingView: RatingView
    private let loadingOverlay = LoadingOverlay()
    private let configuration: RatingUIConfiguration
    private let isFeedbackEnabled: Bool
    
    private var scores: [RatingCriterion: Int] = [:]
        
    init(configuration: RatingUIConfiguration, isFeedbackEnabled: Bool) {
        self.ratingView = RatingView(configuration: configuration)
        self.configuration = configuration
        self.isFeedbackEnabled = isFeedbackEnabled
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

private extension RatingViewController {
    
    func setupUI() {
        ratingView.delegate = self
        view.addSubview(ratingView)
        ratingView.contentView.addSubview(loadingOverlay)
        loadingOverlay.alpha = 0
        
        ratingView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            ratingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            ratingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ratingView.topAnchor.constraint(equalTo: view.topAnchor),
            ratingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        loadingOverlay.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            loadingOverlay.leadingAnchor.constraint(equalTo: ratingView.contentView.leadingAnchor),
            loadingOverlay.trailingAnchor.constraint(equalTo: ratingView.contentView.trailingAnchor),
            loadingOverlay.topAnchor.constraint(equalTo: ratingView.contentView.topAnchor),
            loadingOverlay.bottomAnchor.constraint(equalTo: ratingView.contentView.bottomAnchor)
        ])
    }
    
    func displayRatingThanksView() {
        let successVC = RatingSuccessViewController(configuration: configuration, isFeedbackEnabled: isFeedbackEnabled)
        navigationController?.pushViewController(successVC, animated: false)
    }
    
    func updateSubmitButtonState() {
        ratingView.validateButton.isEnabled = isFormValid()
    }
    
    func isFormValid() -> Bool {
        return configuration.criteria.allSatisfy {
            scores.keys.contains($0)
        }
    }
}

extension RatingViewController: RatingViewDelegate {
    func didScore(_ score: Int, criterion: RatingCriterion) {
        scores[criterion] = score
        updateSubmitButtonState()
    }
    
    func validateRating(criteria: [RatingCriterion]) {
        guard isFormValid() else {
            return
        }
        
        let criterionScores: [RatingCriterionScore] = scores.map { (criterion, value) in
            return RatingCriterionScore(criterionID: criterion.id, value: value)
        }
        
        loadingOverlay.alpha = 1
        
        RatingManager.shared.sendRatingScores(criterionScores) { [weak self] result in
            self?.loadingOverlay.alpha = 0

            switch result {
            case .success:
                self?.displayRatingThanksView()
            case .failure(let error):
                self?.showErrorAlert(error)
            }
        }
    }
    
    func showErrorAlert(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true)
    }

    func cancelRating() {
        dismiss(animated: true)
    }
}

#if DEBUG
//import SwiftUI
//
//struct RatingViewControllerRepresentable: UIViewControllerRepresentable {
//    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
//        // leave this empty
//    }
//
//    @available(iOS 13.0.0, *)
//    func makeUIViewController(context: Context) -> UIViewController {
//        RatingViewController(viewModel: Rati, ratingUIConfiguration: RatingUIConfiguration())
//    }
//}
//
//@available(iOS 13.0, *)
//struct RatingViewControllerPreview: PreviewProvider {
//    static var previews: some View {
//        RatingViewControllerRepresentable()
//    }
//}
#endif
