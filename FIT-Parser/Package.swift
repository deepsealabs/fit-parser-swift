// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "FITParser",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "FITParser",
            targets: ["FITParser"]),
    ],
    dependencies: [
        .package(url: "https://github.com/garmin/fit-objective-c-sdk.git", from: "21.126.0")
    ],
    targets: [
        .target(
            name: "FITParser",
            dependencies: [.product(name: "ObjcFIT", package: "fit-objective-c-sdk")]),
        .testTarget(
            name: "FITParserTests",
            dependencies: ["FITParser"]),
    ]
)