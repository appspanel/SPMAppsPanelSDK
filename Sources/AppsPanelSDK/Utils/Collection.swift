//
//  Collection.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 08/02/2019.
//  Copyright © 2019 Apps Panel. All rights reserved.
//

import Foundation

extension Collection {

    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }

}
