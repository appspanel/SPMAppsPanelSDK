//
//  TextManager.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 29/08/2018.
//  Copyright © 2018 Apps Panel. All rights reserved.
//

import Foundation

public class TextManager {

    public static let shared = TextManager()
    
    public weak var delegate: TextManagerDelegate?
    
    private var configuration: RemoteConfiguration.TextManagerConfiguration?
    
    private var storage = TextManagerStorage.shared
    
    // MARK: - Language
        
    public private(set) var language: String
    
    // Used for legacy purpose related to the `setLocale(_:, default:)` method
    private var defaultLanguage: String?
    
    public private(set) var forcedLanguage: String? {
        get {
            return storage.forcedLanguage
        }
        set {
            storage.forcedLanguage = newValue
        }
    }

    // Default language for the app provided by the system
    private static var systemLanguage: String {
        return Bundle.main.preferredLocalizations[0]
    }
    
    @available(*, deprecated, message: "Use language property instead")
    public var currentLocale: Locale {
        return Locale(identifier: language)
    }
    
    @available(*, deprecated)
    public var defaultLocale: Locale? {
        return defaultLanguage.map(Locale.init(identifier:))
    }
    
    // MARK: - Texts

    private var remoteTextCollection: TextCollection?
    private var remoteTexts: [TextCollection.Key: String] {
        return remoteTextCollection?.texts ?? [:]
    }
    
    private var fallbackTextCollection: TextCollection?
    private var fallbackTexts: [TextCollection.Key: String] {
        return fallbackTextCollection?.texts ?? [:]
    }
    
    public var texts: [TextCollection.Key: String] = [:]
    
    // MARK: -

    private weak var currentRequest: DataRequest?

    // MARK: - Initalization

    private init() {
        self.language = TextManager.systemLanguage
        
        if let forcedLanguage = forcedLanguage {
            self.language = forcedLanguage
        }
        
        loadTextsFromDevice(forLanguage: language)
    }
    
    // MARK: - Configure Module

    func configure(with configuration: RemoteConfiguration.TextManagerConfiguration) {
        self.configuration = configuration
        
        guard configuration.isEnabled else {
            return
        }
        
        downloadTexts()
    }

    // MARK: - Change language
    
    @available(*, deprecated, message: "Use forceLanguage(_:) instead")
    public func setLocale(_ locale: Locale, default defaultLocale: Locale? = nil) {
        setLanguage(locale.identifier, default: defaultLocale?.identifier)
    }
    
    public func forceLanguage(_ language: String) {
        setLanguage(language, forced: true)
    }
    
    public func resetLanguage() {
        setLanguage(TextManager.systemLanguage)
    }
    
    private func setLanguage(_ language: String, default defaultLanguage: String? = nil, forced: Bool = false) {
        self.language = language
        forcedLanguage = forced ? language : nil
        self.defaultLanguage = defaultLanguage
        replaceTextsForCurrentLanguage()
    }

    private func replaceTextsForCurrentLanguage() {
        currentRequest?.cancel()
        
        loadTextsFromDevice(forLanguage: language)
        
        let isEnabled = configuration?.isEnabled ?? false
        guard isEnabled else {
            return
        }
        
        downloadTexts(forLanguage: language)
    }

    // MARK: - Get texts

    public func string(forKey key: String) -> String {
        let text = rawText(forKey: key)
        return text ?? key
    }

    public func string(forKey key: String, _ arguments: CustomStringConvertible...) -> String {
        return string(forKey: key, arguments: arguments)
    }

    public func string(forKey key: String, arguments: [CustomStringConvertible]) -> String {
        if let text = rawText(forKey: key) {
            return textByReplacingArgumentTags(in: text, withArguments: arguments)
        } else {
            return key
        }
    }

    public func string(forKey key: String, keyedArguments: [String: CustomStringConvertible]) -> String {
        if let text = rawText(forKey: key) {
            return textByReplacingArgumentTags(in: text, withKeyedArguments: keyedArguments)
        } else {
            return key
        }
    }

    private func rawText(forKey key: String) -> String? {
        if let text = texts[key], !text.isEmpty {
            return text
        }
        return nil
    }

    // MARK: - Replace arguments in raw text

    private let argumentTagRegex = "##([A-Z_]+)##"

    private func textByReplacingArgumentTags(in text: String, withArguments arguments: [CustomStringConvertible]) -> String {
        guard let regex = try? NSRegularExpression(pattern: argumentTagRegex, options: []) else {
            return text
        }

        let nsString = text as NSString
        let ranges = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length)).map { $0.range }

        var modifiedText = text
        for (argument, nsRange) in zip(arguments, ranges).reversed() {
            if let range = Range(nsRange, in: text) {
                modifiedText = modifiedText.replacingCharacters(in: range, with: argument.description)
            }
        }
        return modifiedText
    }

    private func textByReplacingArgumentTags(in text: String, withKeyedArguments keyedArguments: [String: CustomStringConvertible]) -> String {
        var modifiedText = text
        for (key, argument) in keyedArguments {
            let fullKey = "##" + key.uppercased() + "##"
            modifiedText = modifiedText.replacingOccurrences(of: fullKey, with: argument.description)
        }
        return modifiedText
    }

    // MARK: - Load texts

    private func loadTextsFromDevice(forLanguage language: String) {
        loadFromMainBundle(forLanguage: language)
        loadFromCache(forLanguage: language)
        mergeTexts()
    }

    private func loadFromCache(forLanguage language: String) {
        print("[Text Manager] Trying to load texts from device for the language \"\(language)\"")

        do {
            let url = cacheFileURL(forLanguage: language)
            let json = try Data(contentsOf: url)
            remoteTextCollection = try JSONDecoder().decode(TextCollection.self, from: json)
            print("[Text Manager] Texts loaded from cache")
        } catch {
            remoteTextCollection = nil
            print("[Text Manager] Failed to load texts from cache")
        }
    }

    private func loadFromMainBundle(forLanguage askedLanguage: String) {
        let possibleLanguages: [String] = [
            askedLanguage,
            defaultLanguage
        ].compactMap { $0 }

        for language in possibleLanguages {
            if let texts = try? textsFromMainBundle(forLanguage: language) {
                self.fallbackTextCollection = TextCollection(language: language, askedLanguage: askedLanguage, texts: texts)
                print("[Text Manager] Texts loaded from main bundle with language \(language)")
                return
            }
        }

        self.fallbackTextCollection = nil
        print("[Text Manager] Couldn't find any language file in main bundle for the current language.")
    }

    private func textsFromMainBundle(forLanguage language: String) throws -> TextCollection.LocalizedTexts {
        guard let url = mainBundleFileURL(forLanguage: language) else {
            throw Error.bundleFileMissing
        }
        
        let json = try Data(contentsOf: url)
        let texts = try JSONDecoder().decode(TextCollection.LocalizedTexts.self, from: json)
        return texts
    }
    
    // MARK: -
    
    private func mergeTexts() {
        // Add fallback texts if there are missing from the remote texts
        texts = remoteTexts.merging(fallbackTexts) { remoteText, _ in remoteText }
    }

    // MARK: - Download texts

    public func downloadTexts() {
        downloadTexts(forLanguage: language)
    }

    private func downloadTexts(forLanguage language: String) {
        currentRequest?.cancel()

        // Warning: Use basic JSON decoder to prevent conversion from snake case to camel case of the text manager's keys
        currentRequest = AppsPanel.shared.sdkRequestManager.request(endpoint: WebService.texts(language: language))
            .responseObject(TextCollection.self, jsonDecoder: JSONDecoder())
        { [unowned self] result in
            self.currentRequest = nil

            switch result {
            case .success(let response):
                let textCollection = response.object
                self.remoteTextCollection = textCollection
                
                self.mergeTexts()
                
                print("[Text Manager] Texts loaded from server")

                do {
                    try self.saveTextCollection(textCollection, forLanguage: language)
                } catch {
                    print("[Text Manager] Unable to save the texts in a file.")
                    print("[Text Manager]", error)
                }
            case .failure(let error):
                print("[Text Manager] Unable to get texts from server")
                print(error)
            }
        }
    }

    // MARK: - Save texts

    private func saveTextCollection(_ textCollection: TextCollection, forLanguage language: String) throws {
        let url = cacheFileURL(forLanguage: language)

        // Create folder
        try! FileManager.default.createDirectory(atPath: url.deletingLastPathComponent().path, withIntermediateDirectories: true)

        // Encode to JSON
        let jsonEncoder = JSONEncoder()
        if #available(iOS 11, *) {
            jsonEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        } else {
            jsonEncoder.outputFormatting = .prettyPrinted
        }
        let json = try jsonEncoder.encode(textCollection)

        // Write to file
        try json.write(to: url, options: .atomic)
        print("[Text Manager] Texts saved")
        delegate?.textManagerDidUpdateTexts()
    }

    // MARK: - Clear cache

//    private func clearCache() {
//        let cacheForlder = cacheFileURL(for: language).deletingLastPathComponent()
//        try? FileManager.default.removeItem(at: cacheForlder)
//    }

    // MARK: - Helpers

    private func mainBundleFileURL(forLanguage language: String) -> URL? {
        return Bundle.main.url(forResource: "apnl_strings_\(language)", withExtension: "json")
    }

    private func cacheFileURL(forLanguage language: String) -> URL {
        let applicationSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let appsPanelDirectory = AppsPanel.bundleIdentifier
        var fileURL = applicationSupportURL.appendingPathComponent(appsPanelDirectory, isDirectory: true)
        fileURL.appendPathComponent("Texts", isDirectory: true)
        fileURL.appendPathComponent("\(language).json")
        return fileURL
    }

}

public extension TextManager {

    enum Error: Swift.Error {
        case bundleFileMissing
    }

}

public protocol TextManagerDelegate: AnyObject {
    func textManagerDidUpdateTexts()
}
