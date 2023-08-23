//
//  WebInterstitialViewController.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 01/06/2020.
//  Copyright © 2020 Apps Panel. All rights reserved.
//

import Foundation
import WebKit

class WebInterstitialViewController: WebViewController {
    
    private let interstitial: Interstitial
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    init(interstitial: Interstitial) {
        self.interstitial = interstitial
        let url = interstitial.webViewURL
        super.init(url: interstitial.webViewURL)
        
        self.onLinkActivation = { [interstitial] url in
            StatsManager.shared.logEvent("SDK_INTERSTITIAL_\(interstitial.id)_CLICK", context: ["url": AnyCodable(url)])
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
