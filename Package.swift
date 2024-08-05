// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "FITParser",
    platforms: [
        .iOS(.v14),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "FITParser",
            targets: ["FITParser"]),
    ],
    dependencies: [
        .package(name: "FIT", url: "https://github.com/garmin/fit-objective-c-sdk.git", from: "21.141.0")
    ],
    targets: [
        .target(
            name: "FITParser",
            dependencies: [
                .product(name: "ObjcFIT", package: "FIT")
            ]),
        .testTarget(
            name: "FITParserTests",
            dependencies: ["FITParser"]),
    ]
)