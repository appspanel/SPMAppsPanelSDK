//
//  RatingAlertViewController.swift
//  AppsPanelSDK
//
//  Copyright © 2022 Apps Panel. All rights reserved.
//

import Foundation
import UIKit

protocol FeedbackAlertViewControllerDelegate: AnyObject {
    func feedbackAlertViewControllerDidClose(_ alert: FeedbackAlertViewController)
}

class FeedbackAlertViewController: UIViewController {
    
    private var thanksView: FeedbackThanksView!
    private let loadingOverlay = LoadingOverlay()
    private var configuration: FeedbackUIConfiguration
    
    var delegate: FeedbackAlertViewControllerDelegate?
    
    init(configuration: FeedbackUIConfiguration) {
        self.configuration = configuration
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

private extension FeedbackAlertViewController {
    
    func setupUI() {
        thanksView = FeedbackThanksView(configuration: configuration)
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
        let alert = UIAlertController(
            title: TextManager.shared.string(forKey: "sdk_feedback_error_title"),
            message: TextManager.shared.string(forKey: "sdk_feedback_error_message"),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: TextManager.shared.string(forKey: "sdk_ok"),
            style: .default
        ))
        present(alert, animated: true)
    }
}

extension FeedbackAlertViewController: FeedbackThanksViewDelegate {
    func close() {
        delegate?.feedbackAlertViewControllerDidClose(self)
    }
}
