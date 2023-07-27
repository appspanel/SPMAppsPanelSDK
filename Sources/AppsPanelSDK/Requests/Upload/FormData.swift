//
//  FormData.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 11/12/2019.
//  Copyright © 2019 Apps Panel. All rights reserved.
//

import Foundation

public struct FormData {

    private var _data = Data()

    public var data: Data {
        if _data.isEmpty {
            return _data
        } else {
            return _data + closingBoundary()
        }
    }

    public let boundary: String

    public init(boundary: String = UUID().uuidString) {
        self.boundary = boundary
    }

    public mutating func append(_ file: Data, withName name: String = "file", fileName: String, mimeType: String) {
        appendEncapsulationBoundary()

        _data.append("Content-Disposition: form-data; name=\"\(name.sanitizedFormDataParam)\"; filename=\"\(fileName.sanitizedFileName)\"\r\n".data(using: .utf8)!)
        _data.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        _data.append(file)
        _data.append(Data())
    }
    
    public mutating func append(_ file: File, withName name: String) {
        append(file.data, withName: name, fileName: file.fileName, mimeType: file.mimeType)
    }

    public mutating func append(_ data: Data, withName name: String) {
        appendEncapsulationBoundary()

        let keyData = "Content-Disposition: form-data; name=\"\(name.sanitizedFormDataParam)\"\r\n\r\n".data(using: .utf8)!
        _data.append(keyData)
        _data.append(data)
    }

    public mutating func append(_ string: String, withName name: String) {
        let stringData = string.data(using: .utf8)!
        append(stringData, withName: name)
    }
    
    public mutating func append(_ stringConvertible: LosslessStringConvertible, withName name: String) {
        let string = stringConvertible.description
        append(string, withName: name)
    }
    
    public mutating func append(_ array: [Data], withName name: String) {
        array.forEach {
            append($0, withName: name + "[]")
        }
    }
    
    public mutating func append(_ array: [String], withName name: String) {
        array.forEach {
            append($0, withName: name + "[]")
        }
    }

    // MARK: - Boundaries

    private func boundary(closing: Bool) -> Data {
        return "\r\n--\(boundary)\(closing ? "--" : "")\r\n".data(using: .utf8)!
    }

    private func encapsulationBoundary() -> Data {
        return boundary(closing: false)
    }

    private func closingBoundary() -> Data {
        return boundary(closing: true)
    }

    // MARK: - Append boundaries

    private mutating func appendEncapsulationBoundary() {
        _data.append(encapsulationBoundary())
    }

    private mutating func appendClosingBoundary() {
        _data.append(closingBoundary())
    }

}
