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
        .executable(
            name: "FITParserCLI",
            targets: ["FITParserCLI"])
    ],
    dependencies: [
        .package(url: "https://github.com/garmin/fit-objective-c-sdk.git", from: "21.141.0")
    ],
    targets: [
        .target(
            name: "FITParser",
            dependencies: [
                .product(name: "FIT", package: "fit-objective-c-sdk")
            ],
            resources: [.process("TestDive.fit")]),
        .target(
            name: "FITParserCLI",
            dependencies: ["FITParser"]),
        .testTarget(
            name: "FITParserTests",
            dependencies: ["FITParser"]),
    ]
)