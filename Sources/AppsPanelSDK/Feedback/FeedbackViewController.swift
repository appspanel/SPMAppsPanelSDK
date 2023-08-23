//
//  FeedbackViewController.swift
//  Notation
//
//  Created by AppsPanel on 24/03/2022.
//

import Foundation
import UIKit

class FeedbackViewController: UIViewController {
    
    private let loadingOverlay = LoadingOverlay()
    
    private var configuration: FeedbackUIConfiguration
    
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
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
}

private extension FeedbackViewController {
    
    func setupUI() {
        setupNavBarUI()
        view.backgroundColor = configuration.style.primaryBackgroundColor
        
        let feedbackView = FeedbackView(configuration: configuration)
        feedbackView.delegate = self
        view.addSubview(feedbackView)
        
        feedbackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            feedbackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            feedbackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            feedbackView.topAnchor.constraint(equalTo: view.topAnchor),
            feedbackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        view.addSubview(loadingOverlay)
        loadingOverlay.alpha = 0
        
        loadingOverlay.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            loadingOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            loadingOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setupNavBarUI() {
        title = configuration.feedbackTitle
        
        navigationItem.hidesBackButton = true
        let closeImage = UIImage(named: "navbar_close", in: .appsPanelResources, compatibleWith: nil)?
            .withRenderingMode(.alwaysTemplate)
        let closeButton = UIBarButtonItem(image: closeImage, style: .plain, target: self, action: #selector(cancel))
        navigationItem.leftBarButtonItem = closeButton
        
        let style = configuration.style
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.titleTextAttributes = [
                .foregroundColor: style.primaryColor,
                .font: style.titleFont
            ]
            appearance.backgroundColor = style.secondaryBackgroundColor

            navigationItem.standardAppearance = appearance
            navigationItem.scrollEdgeAppearance = appearance
        } else {
            let textAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: style.primaryColor,
                .font: style.titleFont
            ]
            navigationController?.navigationBar.titleTextAttributes = textAttributes
            navigationController?.navigationBar.backgroundColor = style.secondaryBackgroundColor
        }
        
        navigationController?.navigationBar.tintColor = style.primaryColor
    }
}

extension FeedbackViewController: FeedbackViewDelegate {
    func didSubmitFeedback(_ feedback: Feedback) {
        view.endEditing(true)
        sendFeedback(feedback)
    }
}

extension FeedbackViewController {
    
    func sendFeedback(_ feedback: Feedback) {
        loadingOverlay.alpha = 1
        
        FeedbackManager.shared.sendFeedback(feedback) { [weak self] result in
            self?.loadingOverlay.alpha = 0
            
            switch result {
            case .success:
                self?.showSuccessAlert()
            case .failure(let error):
                self?.showErrorAlert(error)
            }
        }
    }
    
    func showSuccessAlert() {
        let successVC = FeedbackAlertViewController(configuration: configuration)
        successVC.delegate = self
        successVC.modalTransitionStyle = .crossDissolve
        successVC.modalPresentationStyle = .overFullScreen
        present(successVC, animated: true)
    }
    
    func showErrorAlert(_ error: Error) {
        var errorMessage = TextManager.shared.string(forKey: "sdk_feedback_error_message")
        
        if let requestError = error as? RequestError,
           let backendInfo = requestError.backendInfo {
            errorMessage = backendInfo.message
        }
        
        showErrorAlert(withMessage: errorMessage)
    }
    
    func showErrorAlert(withMessage message: String) {
        let alert = UIAlertController(
            title: TextManager.shared.string(forKey: "sdk_feedback_error_title"),
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: TextManager.shared.string(forKey: "sdk_ok"),
            style: .default
        ))
        navigationController?.present(alert, animated: true)
    }
    
    @objc func cancel() {
        close()
    }
    
    func close() {
        navigationController?.dismiss(animated: true)
    }
}

extension FeedbackViewController: FeedbackAlertViewControllerDelegate {
    
    func feedbackAlertViewControllerDidClose(_ alert: FeedbackAlertViewController) {
        alert.dismiss(animated: true) {
            self.close()
        }
    }
    
}

//#if DEBUG
//import SwiftUI
//
//struct FeedbackViewControllerRepresentable: UIViewControllerRepresentable {
//    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
//        // leave this empty
//    }
//    
//    @available(iOS 13.0.0, *)
//    func makeUIViewController(context: Context) -> UIViewController {
//        FeedbackViewController(configuration: FeedbackUIConfiguration())
//    }
//}
//
//@available(iOS 13.0, *)
//struct FeedbackViewControllerPreview: PreviewProvider {
//    static var previews: some View {
//        FeedbackViewControllerRepresentable()
//    }
//}
//#endif
