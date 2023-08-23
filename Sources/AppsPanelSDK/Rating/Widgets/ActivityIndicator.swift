//
//  ActivityIndicator.swift
//  Notation
//
//  Created by AppsPanel on 25/04/2022.
//

import UIKit

class ActivityIndicator: UIActivityIndicatorView {
    
    static let shared = ActivityIndicator()
    
    init() {
        super.init(frame: .zero)
        backgroundColor = UIColor(white: 0, alpha: 0.5)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func add() {
        guard let topViewController = UIApplication.shared.activeWindow?.topMostController() else {
            return
        }
        frame = topViewController.view.frame
        topViewController.view.addSubview(self)
        startAnimating()
    }
    
    func remove() {
        removeFromSuperview()
    }
    
}
