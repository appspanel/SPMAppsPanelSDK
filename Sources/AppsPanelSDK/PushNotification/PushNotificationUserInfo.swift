//
//  NotificationUserInfo.swift
//  AppsPanelSDK
//
//  Created by Pierre Grimault on 25/01/2019.
//  Copyright © 2019 Apps Panel. All rights reserved.
//

import Foundation
import UserNotifications
    
public struct PushNotificationUserInfo: Codable {

    public enum Sender: String, Codable {
        case apnl
        case other

        public init(from decoder: Decoder) throws {
            let string = try decoder.singleValueContainer().decode(String.self)
            if let sender = Sender(rawValue: string) {
                self = sender
            } else {
                self = .other
            }
        }
    }
    
    let priority: Int?
    let sender: Sender
    let data: [String: AnyCodable]?
    let image: URL?
    let urlRedirect: String?
    let id: Int
    let picture: URL?
    
    public init(from request: UNNotificationRequest) throws {
        let userInfo = request.content.userInfo as? [String: Any]
        try self.init(from: userInfo ?? [:])
    }
    
    public init(from userInfo: [String:Any]) throws {
        let data = try JSONSerialization.data(withJSONObject: userInfo as Any, options: [])

        do {
            self = try JSONDecoder.default.decode(PushNotificationUserInfo.self, from: data)
        } catch {
            // Try decoding legacy object (v4)
            let legacyUserInfo = try JSONDecoder.default.decode(PushNotificationLegacyUserInfo.self, from: data)
            
            guard let userInfo = PushNotificationUserInfo(legacy: legacyUserInfo) else {
                throw error
            }
            
            self = userInfo
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case priority
        case sender
        case data
        case image
        case urlRedirect
        case id
        case picture
    }
    
}

// MARK: Content
public extension PushNotificationUserInfo {
    func extractAttachment() -> UNNotificationAttachment? {
        guard let url = self.picture else { return nil }
        guard let imageData = NSData(contentsOf: url) else { return nil }
        guard let attachment = UNNotificationAttachment.saveImageToDisk(fileIdentifier: "image.jpg", data: imageData, options: nil) else { return nil }
        
        return attachment
    }
}


private extension UNNotificationAttachment {
    
    static func saveImageToDisk(fileIdentifier: String, data: NSData, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let folderName = ProcessInfo.processInfo.globallyUniqueString
        let folderURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(folderName, isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: folderURL!, withIntermediateDirectories: true, attributes: nil)
            let fileURL = folderURL?.appendingPathComponent(fileIdentifier)
            try data.write(to: fileURL!, options: [])
            let attachment = try UNNotificationAttachment(identifier: fileIdentifier, url: fileURL!, options: options)
            return attachment
        } catch let error {
            print("error \(error)")
        }
        
        return nil
    }
}
