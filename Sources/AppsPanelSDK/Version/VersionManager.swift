//
//  APVersionManager.swift
//  AppsPanelSDK
//
//  Created by Matteo Melis on 02/04/2024.
//  Copyright © 2024 Apps Panel. All rights reserved.
//


import Foundation
import UIKit

public final class VersionManager {
    public static let shared = VersionManager()
    
    private var configuration: RemoteConfiguration.VersionConfiguration?
    
    let application: UIApplication
    let textManager: TextManager

    init(application: UIApplication = .shared, textManager: TextManager = .shared) {
        self.application = application
        self.textManager = textManager
    }

    func configure(with configuration: RemoteConfiguration.VersionConfiguration) {
        self.configuration = configuration
        
        if configuration.isEnabled {
            let delay = max(0, configuration.delay)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay)) {
                self.fetchVersionConfiguration(completionHandler: { result in
                    switch result {
                    case .success(let version):
                        if self.isVersionOutdated(
                            currentVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String,
                            thresholdVersion: version.version
                        ) {
                            self.showOutdatedVersionDialog(version)
                        }
                    case .failure(let failure):
                        print("[Version Manager] Unable to get version. \(failure)")
                    }
                })
            }
        }
    }
    
    private func fetchVersionConfiguration(completionHandler: @escaping (Result<Version, Error>) -> Void) {
        AppsPanel.shared.sdkRequestManager.request(endpoint: WebService.version).responseObject(Version.self, jsonDecoder: .default) { result in
            switch result {
            case .success(let response):
                completionHandler(.success(response.object))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    private func isVersionOutdated(currentVersion: String, thresholdVersion: String) -> Bool {
        return compareVersions(versionA: currentVersion, versionB: thresholdVersion) == .orderedDescending
    }
    
    private func compareVersions(versionA: String, versionB: String) -> ComparisonResult {
        let sep: Character = "."
        var versionA = versionA
        var versionB = versionB
        let versionASeparatorCount = versionA.filter { $0 == sep }.count
        let versionBSeparatorCount = versionB.filter { $0 == sep }.count
        let lengthDiff = versionASeparatorCount - versionBSeparatorCount
        let padding = String(repeating: ".0", count: abs(lengthDiff))
        if lengthDiff > 0 {
            versionB.append(contentsOf: padding)
        } else if lengthDiff < 0 {
            versionA.append(contentsOf: padding)
        }
        return versionB.compare(versionA, options: .numeric)
    }
    
    private func showOutdatedVersionDialog(_ version: Version) {
        guard let topViewController = application.activeWindow?.topMostController() else {
            return
        }
        
        let alertController = UIAlertController(title: version.version, message: version.message, preferredStyle: .alert)
        
        alertController.addAction(
            UIAlertAction(title: version.cancelButton, style: .cancel) { action in
                if version.force {
                    exit(0)
                }
            }
        )
        
        guard let urlString = version.url,
              let url = URL(string: urlString)
        else { return }
        alertController.addAction(
            UIAlertAction(title: version.okButton, style: .default) { action in
                if self.application.canOpenURL(url) {
                    self.application.open(url) { _ in
                        if (version.force) {
                            exit(0)
                        }
                    }
                }
            }
        )
        
        topViewController.present(alertController, animated: false)
    }
}
