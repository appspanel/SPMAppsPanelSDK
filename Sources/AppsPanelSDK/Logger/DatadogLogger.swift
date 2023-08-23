//
//  DDLogger.swift
//  Example
//
//  Created by Arnaud Olivier on 25/01/2023.
//  Copyright © 2023 Apps Panel. All rights reserved.
//
import Foundation
import Datadog

class DatadogLogger {
    
    private let logger: DDLogger
    
    init() {
        self.logger = DDLogger.builder
            .sendNetworkInfo(false)
            .printLogsToConsole(true, usingFormat: .short)
            .build()
    }
    
    static func configure(
        clientToken: String,
        environment: String
    ) {
        Datadog.initialize(
            appContext: .init(),
            trackingConsent: .granted,
            configuration: Datadog.Configuration
                .builderUsing(clientToken: clientToken, environment: environment) // dev/qa/prod
                .set(serviceName: Bundle.main.bundleIdentifier ?? "") // App ID
                .set(endpoint: .eu1)
                .build()
        )
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
