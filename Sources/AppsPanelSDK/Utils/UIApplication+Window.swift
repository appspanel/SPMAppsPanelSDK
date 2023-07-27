//
//  UIApplication+Window.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 25/10/2021.
//  Copyright © 2021 Apps Panel. All rights reserved.
//

import UIKit

extension UIApplication {
    
    var activeWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        }
    }
    
}
