//
//  Logger.swift
//  Example
//
//  Created by Arnaud Olivier on 25/01/2023.
//  Copyright © 2023 Apps Panel. All rights reserved.
//

import Foundation

public class Logger {
    
    private let ddLogger: DatadogLogger
    
    public init() {
        ddLogger = DatadogLogger()
        ddLogger.deviceIdentifier = AppsPanel.shared.deviceIdentifier
    }
    
    public static func configure(environment: String, clientToken: String) {
        DatadogLogger.configure(
            clientToken: clientToken,
            environment: environment
        )
    }
    
    public var deviceIdentifier: String? {
        get {
            return ddLogger.deviceIdentifier
        }
        set {
            ddLogger.deviceIdentifier = newValue
        }
    }
    
    public typealias Attributes = [String: Encodable]
    
    public func debug(_ message: String, attributes: Attributes? = nil) {
        ddLogger.debug(message, attributes: attributes)
    }
    
    public func info(_ message: String, attributes: Attributes? = nil) {
        ddLogger.info(message, attributes: attributes)
    }
    
    public func notice(_ message: String, attributes: Attributes? = nil) {
        ddLogger.notice(message, attributes: attributes)
    }
    
    public func warn(_ message: String, attributes: Attributes? = nil) {
        ddLogger.warn(message, attributes: attributes)
    }
    
    public func error(_ message: String, attributes: Attributes? = nil) {
        ddLogger.error(message, attributes: attributes)
    }
    
    public func critical(_ message: String, attributes: Attributes? = nil) {
        ddLogger.critical(message, attributes: attributes)
    }

}
