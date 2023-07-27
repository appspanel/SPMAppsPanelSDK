//
//  DocumentHelper.swift
//  AppsPanelSDK
//
//  Created by Pierre Grimault on 27/02/2019.
//  Copyright © 2019 Apps Panel. All rights reserved.
//

import Foundation

public class DocumentHelper {
    private static let defaultFileName = "APSDKDefaultSavedValues"
    
    public static func getPathFor(filename: String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return "\(documentsDirectory)/\(filename).plist"
    }
    
    public static func write(value: Any, forKey key: String) {
        DocumentHelper.write(value: value, key: key, plistName: defaultFileName)
    }
    
    public static func write(value: Any, key: String, plistName: String) {
        var plist: NSMutableDictionary = [:]
        let plistPath = DocumentHelper.getPathFor(filename: plistName)
        if FileManager.default.fileExists(atPath: plistPath) {
            plist = NSMutableDictionary(contentsOfFile: plistPath) ?? [:]
        }
        plist.setObject(value, forKey: key as NSString)
        plist.write(toFile: plistPath, atomically: true)
    }
    
    // MARK: Read value
    
    public static func readValue(forKey key: String) -> Any? {
        let value = DocumentHelper.readValueForKey(key, plistName: defaultFileName)
        return value
    }
    
    public static func readValueForKey(_ key: String, plistName: String) -> Any? {
        if let plist = NSMutableDictionary(contentsOfFile: DocumentHelper.getPathFor(filename: plistName)) {
            return plist.object(forKey:key)
        } else {
            return nil
        }
    }
}
