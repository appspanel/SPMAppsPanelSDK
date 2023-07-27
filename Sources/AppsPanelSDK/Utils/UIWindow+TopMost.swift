//
//  UIWindow+TopMost.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 18/10/2019.
//  Copyright © 2019 Apps Panel. All rights reserved.
//

import UIKit

extension UIWindow {

    func topMostController() -> UIViewController? {
        guard let rootViewController = rootViewController else {
            return nil
        }

        var topController = rootViewController

        while let newTopController = topController.presentedViewController {
            topController = newTopController
        }

        return topController
    }

}
