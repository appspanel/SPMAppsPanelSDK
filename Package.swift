// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "AppsPanelSDK",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "AppsPanelSDK",
            targets: ["AppsPanelSDK"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.9.1")),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.0.0"),
        .package(url: "https://github.com/Kitura/Swift-JWT.git", .upToNextMinor(from: "3.6.200")),
        .package(url: "https://github.com/DataDog/dd-sdk-ios.git", .exact("2.11.1")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "AppsPanelSDK",
            dependencies: [.product(name: "Alamofire", package: "Alamofire"),
                           .product(name: "KeychainAccess", package: "KeychainAccess"),
                           .product(name: "SwiftJWT", package: "Swift-JWT"),
                           .product(name: "DatadogCore", package: "dd-sdk-ios"),
                           .product(name: "DatadogLogs", package: "dd-sdk-ios")],
            resources: [.process("Resources")]),
        .testTarget(
            name: "AppsPanelSDKv5PackageTests",
            dependencies: ["AppsPanelSDK"]),
    ]
)
