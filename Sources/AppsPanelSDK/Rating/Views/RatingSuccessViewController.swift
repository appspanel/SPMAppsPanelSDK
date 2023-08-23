//
//  RatingSuccessViewController.swift
//  AppsPanelSDK
//
//  Copyright © 2022 Apps Panel. All rights reserved.
//

import Foundation
import UIKit

class RatingSuccessViewController: UIViewController {
    
    private var thanksView: RatingThanksView!
    private let loadingOverlay = LoadingOverlay()
    private var configuration: RatingUIConfiguration
    private var isFeedbackEnabled: Bool
        
    init(configuration: RatingUIConfiguration, isFeedbackEnabled: Bool) {
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

private extension RatingSuccessViewController {
    
    func setupUI() {
        thanksView = RatingThanksView(configuration: configuration, isFeedbackEnabled: isFeedbackEnabled)
        thanksView.delegate = self
        view.addSubview(thanksView)
        
        thanksView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            thanksView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            thanksView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            thanksView.topAnchor.constraint(equalTo: view.topAnchor),
            thanksView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        thanksView.contentView.addSubview(loadingOverlay)
        loadingOverlay.alpha = 0
        
        loadingOverlay.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            loadingOverlay.leadingAnchor.constraint(equalTo: thanksView.contentView.leadingAnchor),
            loadingOverlay.trailingAnchor.constraint(equalTo: thanksView.contentView.trailingAnchor),
            loadingOverlay.topAnchor.constraint(equalTo: thanksView.contentView.topAnchor),
            loadingOverlay.bottomAnchor.constraint(equalTo: thanksView.contentView.bottomAnchor)
        ])
    }
    
    // MARK: - Feedback
    
    private func showFeedback() {
        loadingOverlay.alpha = 1
        
        FeedbackManager.shared.getUIConfiguration { [weak self] result in
            guard let self else {
                return
            }
            
            self.loadingOverlay.alpha = 0

            switch result {
            case .success(let uiConfiguration):
                self.pushFeedback(with: uiConfiguration)
            case .failure(let error):
                self.showErrorAlert(error)
            }
        }
    }
    
    private func pushFeedback(with configuration: FeedbackUIConfiguration) {
        let feedbackVC = FeedbackViewController(configuration: configuration)
        navigationController?.pushViewController(feedbackVC, animated: false)
    }
    
    func showErrorAlert(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true)
    }
}

extension RatingSuccessViewController: RatingThanksViewDelegate {
    func gotToFeedback() {
        showFeedback()
    }
    
    func cancelThanks() {
        dismiss(animated: true)
    }
}
