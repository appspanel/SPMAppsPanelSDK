// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "AppsPanelSDK",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "AppsPanelSDK",
            targets: ["AppsPanelSDK"]),
        .library(
            name: "AppsPanelSDKExtension",
            targets: ["AppsPanelSDKExtension"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.10.2")),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.2"),
        .package(url: "https://github.com/Kitura/Swift-JWT.git", .upToNextMinor(from: "3.6.200")),
        .package(url: "https://github.com/DataDog/dd-sdk-ios.git", .exact("2.26.0")),
    ],
    targets: [
            .target(
                name: "AppsPanelSDK",
                dependencies: [
                    .product(name: "Alamofire", package: "Alamofire"),
                    .product(name: "KeychainAccess", package: "KeychainAccess"),
                    .product(name: "SwiftJWT", package: "Swift-JWT"),
                    .product(name: "DatadogCore", package: "dd-sdk-ios"),
                    .product(name: "DatadogLogs", package: "dd-sdk-ios")
                ],
                path: "Sources/AppsPanelSDK",
                resources: [.process("Resources")]
            ),
            .target(
                name: "AppsPanelSDKCore",
                dependencies: [
                    .product(name: "Alamofire", package: "Alamofire"),
                    .product(name: "KeychainAccess", package: "KeychainAccess"),
                    .product(name: "SwiftJWT", package: "Swift-JWT"),
                ],
                path: "Sources/AppsPanelSDK",
                exclude: [
                    "Logger/DatadogLogger.swift",
                    "Logger/Logger.swift"
                ],
                resources: [.process("Resources")]
            ),
            .target(
                name: "AppsPanelSDKExtension",
                    dependencies: ["AppsPanelSDKCore"],
                path: "Sources/AppsPanelSDKExtension"
            ),
        .testTarget(
            name: "AppsPanelSDKv5PackageTests",
            dependencies: ["AppsPanelSDK"]),
    ]
)
