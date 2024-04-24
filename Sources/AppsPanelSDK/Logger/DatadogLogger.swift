//
//  DDLogger.swift
//  Example
//
//  Created by Arnaud Olivier on 25/01/2023.
//  Copyright © 2023 Apps Panel. All rights reserved.
//
import DatadogCore
import DatadogLogs
import Foundation

class DatadogLogger {
    
    private let logger: LoggerProtocol
    
    init() {
        self.logger = DatadogLogs.Logger.create(
            with: DatadogLogs.Logger.Configuration(
                networkInfoEnabled: false,
                consoleLogFormat: .short
            )
        )
    }
    
    static func configure(
        clientToken: String,
        environment: String
    ) {
        Datadog.initialize(with:Datadog.Configuration(clientToken: clientToken, env: environment, site: .eu1, service: Bundle.main.bundleIdentifier ?? ""), trackingConsent: .granted)
        Logs.enable()
    }
    
    var deviceIdentifier: String? {
        didSet {
            if let deviceIdentifier {
                logger.addAttribute(forKey: "device_uid", value: deviceIdentifier)
            } else {
                logger.removeAttribute(forKey: "device_uid")
            }
        }
    }
    
    typealias Attributes = [String: Encodable]
    
    func debug(_ message: String, attributes: Attributes? = nil) {
        logger.debug(message, attributes: attributes)
    }
    
    func info(_ message: String, attributes: Attributes? = nil) {
        logger.info(message, attributes: attributes)
    }
    
    func notice(_ message: String, attributes: Attributes? = nil) {
        logger.notice(message, attributes: attributes)
    }
    
    func warn(_ message: String, attributes: Attributes? = nil) {
        logger.warn(message, attributes: attributes)
    }
    
    func error(_ message: String, attributes: Attributes? = nil) {
        logger.error(message, attributes: attributes)
    }
    
    func critical(_ message: String, attributes: Attributes? = nil) {
        logger.critical(message, attributes: attributes)
    }
}
