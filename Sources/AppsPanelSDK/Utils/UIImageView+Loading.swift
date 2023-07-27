//
//  UIImageView+Loading.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 01/06/2020.
//  Copyright © 2020 Apps Panel. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {

    func setImage(from url: URL?, withPlaceholder placeholder: UIImage? = nil, completion: ((Bool) -> Void)? = nil) {
        if let placeholder = placeholder {
            image = placeholder
        }

        guard let url = url else {
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            DispatchQueue.main.async {
                if let data = data {
                    let image = UIImage(data: data)
                    self.image = image
                    completion?(true)
                } else {
                    completion?(false)
                }
            }
        }.resume()
    }

}
