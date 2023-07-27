//
//  String+FormData.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 06/01/2020.
//  Copyright © 2020 Apps Panel. All rights reserved.
//

import Foundation

extension String {

    private func filter(charactersFrom string: String) -> String {
        return filter { !string.contains($0) }
    }

    var sanitizedFileName: String {
        let illegalCharacters = #"/\:?%*|"<>"#
        return filter(charactersFrom: illegalCharacters)
    }

    var sanitizedFormDataParam: String {
        let illegalCharacters = "\"\r\n"
        return filter(charactersFrom: illegalCharacters)
    }

}
