//
//  DialogManager.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 10/10/2019.
//  Copyright © 2019 Apps Panel. All rights reserved.
//

import Dispatch
import UIKit

@available(iOSApplicationExtension, unavailable)
class DialogManager {

    var configuration: RemoteConfiguration.DialogConfiguration?

    let application: UIApplication
    let textManager: TextManager

    init(application: UIApplication = .shared, textManager: TextManager = .shared) {
        self.application = application
        self.textManager = textManager
    }

    func configure(with configuration: RemoteConfiguration.DialogConfiguration) {
        self.configuration = configuration

        guard configuration.isEnabled else {
            return
        }

        let delay = max(0, configuration.delay)

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay)) { [weak self] in
            self?.run()
        }
    }

    // Called when the configuration is received and `isEnabled == true`
    private func run() {
        AppsPanel.shared.sdkRequestManager.request(endpoint: WebService.dialog)
            .responseObject(Dialog.self, jsonDecoder: JSONDecoder.default)
        { [weak self] result in
            switch result {
            case let .success(response):
                self?.presentDialog(response.object)
            case .failure(_):
                break
            }
        }
    }

    // MARK: - Displaying the dialog

    private func presentDialog(_ dialog: Dialog) {
        guard let topViewController = application.activeWindow?.topMostController() else {
            return
        }

        let localizedTitle = textManager.string(forKey: dialog.title)
        let localizedMessage = textManager.string(forKey: dialog.message)

        let alertController = UIAlertController(title: localizedTitle, message: localizedMessage, preferredStyle: .alert)

        let localizedCloseButtonTitle = textManager.string(forKey: dialog.closeButtonTitle)
        let closeAction = UIAlertAction(title: localizedCloseButtonTitle, style: .cancel) { action in
            if dialog.killsAppOnAnyButtonTap {
                exit(0)
            }
        }
        alertController.addAction(closeAction)

        if let url = dialog.url,
            let redirectButtonTitle = dialog.redirectButtonTitle
        {
            let localizedTitle = textManager.string(forKey: redirectButtonTitle)
            let redirectAction = UIAlertAction(title: localizedTitle, style: .default) { action in
                self.redirect(to: url) {
                    if dialog.killsAppOnAnyButtonTap {
                        exit(0)
                    }
                }
            }
            alertController.addAction(redirectAction)
        }

        topViewController.present(alertController, animated: false)
    }

    // MARK: - Opening an URL

//    @available(iOSApplicationExtension, unavailable)
    func redirect(to url: URL, completionHandler: (() -> Void)?) {
        if application.canOpenURL(url) {
            application.open(url) { success in
                completionHandler?()
            }
        }
    }

}
