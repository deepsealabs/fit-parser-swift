import PackageDescription

let package = Package(
    name: "fit-parser-swift",
    platforms: [
        .iOS(.v14),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "FITParserSwift",
            targets: ["FITParserSwift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/garmin/fit-objective-c-sdk.git")
    ],
    targets: [
        .target(
            name: "FITParserSwift",
            dependencies: [.product(name: "ObjcFIT", package: "fit-objective-c-sdk")]),
        .testTarget(
            name: "FITParserSwiftTests",
            dependencies: ["FITParserSwift"]),
    ]
)
