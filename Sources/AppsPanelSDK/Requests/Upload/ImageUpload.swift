//
//  ImageUpload.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 10/12/2019.
//  Copyright © 2019 Apps Panel. All rights reserved.
//

import Foundation

public struct ImageUpload {

    public let file: File
    public let entity: UploadEntity?
    public let options: Options?
    public var timeout: TimeInterval?
    
    public init(file: File, entity: UploadEntity? = nil, options: Options? = nil) {
        self.file = file
        self.entity = entity
        self.options = options
    }

    public init(data: Data, entity: UploadEntity? = nil, options: Options? = nil) {
        self.file = File(data: data)
        self.entity = entity
        self.options = options
    }

}

extension ImageUpload {

    public struct Size: CustomStringConvertible, LosslessStringConvertible {

        public let width: Int
        public let height: Int

        private static let stringSeparator = "x"

        public init(width: Int, height: Int) {
            self.width = width
            self.height = height
        }

        public var description: String {
            return "\(width)\(Size.stringSeparator)\(height)"
        }

        public init?(_ description: String) {
            let components = description.split(separator: Character(Size.stringSeparator))

            guard components.count == 2 else {
                return nil
            }

            let widthString = components[0]
            let heightString = components[1]

            guard let width = Int(widthString),
                let height = Int(heightString)
            else {
                return nil
            }

            self.width = width
            self.height = height
        }

    }

}

extension ImageUpload {

    public struct Options {

        public let smallSize: Size?
        public let mediumSize: Size?
        public let largeSize: Size?

        public init(
            smallSize: Size? = nil,
            mediumSize: Size? = nil,
            largeSize: Size? = nil
        ) {
            self.smallSize = smallSize
            self.mediumSize = mediumSize
            self.largeSize = largeSize
        }

    }

}

extension FormData {

    init(imageUpload: ImageUpload) {
        self.init()
        
        self.append(imageUpload.file.data,
                    fileName: imageUpload.file.fileName,
                    mimeType: imageUpload.file.mimeType)

        if let entity = imageUpload.entity {
            self.appendEntity(entity)
        }

        if let options = imageUpload.options {
            appendOptions(options)
        }
    }

    private mutating func appendOptions(_ options: ImageUpload.Options) {
        if let smallSize = options.smallSize {
            append(String(smallSize), withName: "small_size")
        }

        if let mediumSize = options.mediumSize {
            append(String(mediumSize), withName: "medium_size")
        }

        if let largeSize = options.largeSize {
            append(String(largeSize), withName: "large_size")
        }
    }

}
