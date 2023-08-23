//
//  ImageInterstitialViewController.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 01/06/2020.
//  Copyright © 2020 Apps Panel. All rights reserved.
//

import Foundation
import UIKit

class ImageInterstitialViewController: UIViewController {

    private let activityIndicatorView: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView(style: .white)
        loader.color = UIColor.white
        loader.hidesWhenStopped = true
        return loader
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "close", in: Bundle.module, compatibleWith: nil), for: .normal)
        return button
    }()

    private let interstitial: Interstitial

    private var currentImageURL: URL?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    init(interstitial: Interstitial) {
        self.interstitial = interstitial
        super.init(nibName: nil, bundle: nil)
        setUpView()
        setUpConstraints()
        addNotificationObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: -

    private func setUpView() {
        view.addSubview(activityIndicatorView)

        view.addSubview(imageView)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(redirect))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)

        view.addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)

        view.backgroundColor = UIColor.black
    }

    private func setUpConstraints() {
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        let layoutGuide: UILayoutGuide
        if #available(iOS 11.0, *) {
            layoutGuide = view.safeAreaLayoutGuide
        } else {
            layoutGuide = view.layoutMarginsGuide
        }

        let constraints = [
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: view.rightAnchor),

            closeButton.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: 10),
            closeButton.rightAnchor.constraint(equalTo: layoutGuide.rightAnchor, constant: -10),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
        ]
        NSLayoutConstraint.activate(constraints)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateImage()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        updateImage()
    }

    // MARK: -

    private func addNotificationObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    @objc private func appMovedToBackground() {
        dismiss(animated: false)
    }

    // MARK: -

    private func updateImage() {
        guard let url = imageURL(forLandscapeOrientation: UIDevice.current.orientation.isLandscape) else {
            return
        }

        currentImageURL = url

        showLoaderWithDelay(1)

        self.imageView.setImage(from: url) { [weak self] _ in
            self?.hideLoader()
        }
    }

    private func imageURL(forLandscapeOrientation landscapeOrientation: Bool) -> URL? {
        if landscapeOrientation {
            return interstitial.landscapePictureURL ?? interstitial.portraitPictureURL
        } else {
            return interstitial.portraitPictureURL ?? interstitial.landscapePictureURL
        }
    }

    // MARK: - Loader

    private func showLoaderWithDelay(_ delay: TimeInterval) {
        perform(#selector(self.showLoader), with: nil, afterDelay: delay)
    }

    @objc private func showLoader() {
        activityIndicatorView.startAnimating()
    }

    private func hideLoader() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.showLoader), object: nil)
        activityIndicatorView.stopAnimating()
    }

    // MARK: - Actions

    @IBAction private func redirect() {
        guard let url = interstitial.redirectURL else {
            return
        }

        StatsManager.shared.logEvent("SDK_INTERSTITIAL_\(interstitial.id)_CLICK", context: ["url": AnyCodable(url)])

        UIApplication.shared.open(url) { success in
            self.close()
            print("redirected")
        }
    }

    @IBAction private func close() {
        dismiss(animated: false)
    }

}
