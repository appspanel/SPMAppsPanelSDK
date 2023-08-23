//
//  InterstitialManager.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 01/06/2020.
//  Copyright © 2020 Apps Panel. All rights reserved.
//

import Foundation
import UIKit

public class InterstitialManager {

    public static let shared = InterstitialManager()

    private(set) var configuration: RemoteConfiguration.InterstitialConfiguration?

    private let application: UIApplication

    private(set) var interstitialToPresentManually: Interstitial?

    init(application: UIApplication = .shared) {
        self.application = application
    }

    func configure(with configuration: RemoteConfiguration.InterstitialConfiguration) {
        self.configuration = configuration

        guard configuration.isEnabled else {
            return
        }

        let lastPresentationTimeInterval = UserDefaults.standard.value(forKey: "LastInterstitialPresentationDate") as? TimeInterval ?? 0
        let now = Date().timeIntervalSince1970

        guard lastPresentationTimeInterval + configuration.displayLimit < now else {
            print("[Interstitial] Skipping interstitial since it was presented recently")
            return
        }

        let delay = configuration.delay
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay)) { [weak self] in
            self?.run()
        }
    }

    // Called when the configuration is received and `isEnabled == true`
    private func run() {
        AppsPanel.shared.sdkRequestManager.request("sdk/interstitial", method: .get)
            .responseObject(Interstitial.self, jsonDecoder: JSONDecoder.default)
        { [weak self] result in
            switch result {
            case let .success(response):
                self?.presentInterstitial(response.object)
            case .failure(_):
                break
            }
        }
    }

    // MARK: - Displaying the interstitial

    private func presentInterstitial(_ interstitial: Interstitial) {
        guard let topViewController = application.activeWindow?.topMostController() else {
            return
        }

        guard
            let configuration = configuration,
            configuration.auto
        else {
            interstitialToPresentManually = interstitial
            return
        }

        presentInterstitial(interstitial, from: topViewController)
    }

    private func presentInterstitial(_ interstitial: Interstitial, from viewController: UIViewController) {
        let interstitialViewController: UIViewController
        switch interstitial.kind {
        case .image:
            interstitialViewController = ImageInterstitialViewController(interstitial: interstitial)
        case .webView:
            interstitialViewController = WebInterstitialViewController(interstitial: interstitial)
        }
        interstitialViewController.modalPresentationStyle = .fullScreen
        viewController.present(interstitialViewController, animated: false)

        StatsManager.shared.logView("SDK_INTERSTITIAL_\(interstitial.id)_VIEW")

        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "LastInterstitialPresentationDate")
    }

    public func presentInterstitial(from viewController: UIViewController) {
        guard let configuration = configuration else {
            print("[Interstitial] The remote configuration has not been loaded.")
            return
        }

        guard !configuration.auto else {
            print("[Interstitial] Interstitial can't be showed manually since the presentation is automatic according to the sdk configuration.")
            return
        }

        guard let interstitial = interstitialToPresentManually else {
            print("[Interstitial] There is no interstitial to show.")
            return
        }

        interstitialToPresentManually = nil
        presentInterstitial(interstitial, from: viewController)
    }

}

