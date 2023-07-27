//
//  TextCollection.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 14/11/2018.
//

import Foundation

public struct TextCollection: Codable {

    public typealias Key = String
    public typealias LocalizedTexts = [Key: String]

    public let language: String
    public let askedLanguage: String
    
    @available(*, deprecated, message: "Use language property instead")
    public var locale: Locale {
        return Locale(identifier: language)
    }
    
    @available(*, deprecated, message: "Use askedLanguage property instead")
    public var askedLocale: Locale {
        return Locale(identifier: askedLanguage)
    }
    
    public let texts: LocalizedTexts

    enum CodingKeys: String, CodingKey {
        case language = "locale"
        case askedLanguage = "asked"
        case texts
    }
    
    @available(*, deprecated, message: "Use init(language:, askedLanguage:, texts:) instead")
    init(locale: Locale, askedLocale: Locale, texts: LocalizedTexts) {
        self.language = locale.identifier
        self.askedLanguage = askedLocale.identifier
        self.texts = texts
    }

    init(language: String, askedLanguage: String, texts: LocalizedTexts) {
        self.language = language
        self.askedLanguage = askedLanguage
        self.texts = texts
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let localeString = try container.decode(String.self, forKey: .language)
        language = localeString
        let askedLocaleString = try container.decode(String.self, forKey: .askedLanguage)
        askedLanguage = askedLocaleString
        texts = try container.decode([Key: String].self, forKey: .texts)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(language, forKey: .language)
        try container.encode(askedLanguage, forKey: .askedLanguage)
        try container.encode(texts, forKey: .texts)
    }
    
    public subscript(key: String) -> String? {
        get {
            return texts[key]
        }
    }

}
