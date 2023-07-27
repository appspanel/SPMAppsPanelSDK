//
//  FileManagerExtensions.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 19/11/2021.
//  Copyright © 2021 Apps Panel. All rights reserved.
//

import Foundation

extension FileManager {
    
    var sdkApplicationSupportDirectoryURL: URL {
        let applicationSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let appsPanelDirectory = AppsPanel.bundleIdentifier
        return applicationSupportURL.appendingPathComponent(appsPanelDirectory, isDirectory: true)
    }

    func createDirectory(at url: URL) throws {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
    
}
