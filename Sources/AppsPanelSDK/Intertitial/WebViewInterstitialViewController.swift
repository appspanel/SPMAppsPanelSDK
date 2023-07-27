//
//  WebViewInterstitialViewController.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 01/06/2020.
//  Copyright © 2020 Apps Panel. All rights reserved.
//

import Foundation
import WebKit

class WebViewInterstitialViewController: UIViewController {

    private let activityIndicatorView: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView(style: .white)
        loader.color = UIColor.black
        loader.hidesWhenStopped = true
        return loader
    }()

    private let webView = WKWebView()

    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "close", in: Bundle.appsPanelResources, compatibleWith: nil), for: .normal)
        return button
    }()

    private let interstitial: Interstitial

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
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

    func setUpView() {
        view.addSubview(activityIndicatorView)
        view.addSubview(webView)
        view.addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)

        view.backgroundColor = UIColor.white
    }

    func setUpConstraints() {
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        webView.translatesAutoresizingMaskIntoConstraints = false
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

            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leftAnchor.constraint(equalTo: view.leftAnchor),
            webView.rightAnchor.constraint(equalTo: view.rightAnchor),

            closeButton.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: 10),
            closeButton.rightAnchor.constraint(equalTo: layoutGuide.rightAnchor, constant: -10),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
        ]
        NSLayoutConstraint.activate(constraints)
    }

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let url = interstitial.webViewURL else {
            return
        }

        showLoader()

        webView.navigationDelegate = self
        webView.isHidden = true
        let request = URLRequest(url: url)
        webView.load(request)
    }

    // MARK: -

    func addNotificationObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    @objc func appMovedToBackground() {
        dismiss(animated: false)
    }

    // MARK: - Loader

    private func showLoader() {
        activityIndicatorView.startAnimating()
    }

    private func hideLoader() {
        activityIndicatorView.stopAnimating()
    }

    // MARK: - Actions

    @IBAction func close() {
        dismiss(animated: false)
    }

}

extension WebViewInterstitialViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard
            navigationAction.navigationType == .linkActivated,
            let url = navigationAction.request.url
        else {
            decisionHandler(.allow)
            return
        }

        StatsManager.shared.logEvent("SDK_INTERSTITIAL_\(interstitial.id)_CLICK", context: ["url": AnyCodable(url)])

        UIApplication.shared.open(url)
        decisionHandler(.cancel)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.isHidden = false
        hideLoader()
    }

}
