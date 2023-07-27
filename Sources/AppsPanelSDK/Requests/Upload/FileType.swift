//
//  FileType.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 07/01/2020.
//  Copyright © 2020 Apps Panel. All rights reserved.
//

import CoreServices
import Foundation

struct FileType: Codable {

    let mimeType: String
    let fileExtension: String

    private static let defaultMIMEType: String = "application/octet-stream"
    private static let defaultFileExtension: String = "bin"

    static let `default`: FileType = FileType(mimeType: FileType.defaultMIMEType, fileExtension: FileType.defaultFileExtension)

    static let jpeg: FileType = FileType(mimeType: "image/jpeg", fileExtension: "jpg")
    static let png: FileType = FileType(mimeType: "image/png", fileExtension: "png")
    static let gif: FileType = FileType(mimeType: "image/gif", fileExtension: "gif")
    static let tiff: FileType = FileType(mimeType: "image/tiff", fileExtension: "tiff")
    static let pdf: FileType = FileType(mimeType: "application/pdf", fileExtension: "pdf")
    static let zip: FileType = FileType(mimeType: "application/zip", fileExtension: "zip")
    static let mp3: FileType = FileType(mimeType: "audio/mpeg3", fileExtension: "mp3")

    // TODO: Use it to determine the MIME type from the file name extension
    private func mimeType(forFileNameExtension fileNameExtension: String) -> String? {
        if let id = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileNameExtension as CFString, nil)?.takeRetainedValue(),
            let contentType = UTTypeCopyPreferredTagWithClass(id, kUTTagClassMIMEType)?.takeRetainedValue()
        {
            return contentType as String
        }

        return nil
    }

}

extension Data {

    // https://en.wikipedia.org/wiki/List_of_file_signatures
    // https://www.garykessler.net/library/file_sigs.html
    private static let mimeTypeSignatures: [[UInt8]: FileType] = [
        [0xFF, 0xD8, 0xFF]:                                 FileType.jpeg,
        [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]:   FileType.png,
        [0x47, 0x49, 0x46, 0x38, 0x37, 0x61]:               FileType.gif,
        [0x47, 0x49, 0x46, 0x38, 0x39, 0x61]:               FileType.gif,
        [0x49, 0x20, 0x49]:                                 FileType.tiff,
        [0x49, 0x49, 0x2A, 0x00]:                           FileType.tiff,
        [0x4D, 0x4D, 0x00, 0x2A]:                           FileType.tiff,
        [0x25, 0x50, 0x44, 0x46, 0x2D]:                     FileType.pdf,
        [0x49, 0x44, 0x33]:                                 FileType.mp3,
    ]

    private func matchesMIMETypeSignature(_ signature: [UInt8]) -> Bool {
        guard !isEmpty else {
            return false
        }

        guard !signature.isEmpty else {
            return false
        }

        let signatureData = Data(signature)

        guard count >= signatureData.count else {
            return false
        }

        return starts(with: signatureData)
    }

    func fileType() -> FileType {
        let signatures = Data.mimeTypeSignatures.keys

        let matchingSignature = signatures.first { matchesMIMETypeSignature($0) }

        guard let signature = matchingSignature else {
            return FileType.default
        }

        return Data.mimeTypeSignatures[signature]!
    }

}
