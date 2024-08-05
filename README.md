# FIT-Parser Swift

DiveDataParser is a Swift package for parsing and displaying dive data from FIT files. It provides structures for organizing dive data and a SwiftUI view for displaying the parsed information.

## Features

- Parse FIT files containing dive data
- Extract session, summary, settings, and tank information
- Display parsed data in a user-friendly SwiftUI interface

## Installation

### Swift Package Manager

To integrate DiveDataParser into your Xcode project using Swift Package Manager, add it to the dependencies value of your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/latishab/fit-parser-swift.git")
]
```

Then, specify it as a dependency of your target:

```swift
targets: [
    .target(
        name: "YourTargetName",
        dependencies: ["fit-parser-swift"]),
]
```

### Manual Installation

1. Download the DiveDataParser package
2. Drag and drop the package folder into your Xcode project
3. Make sure to select "Copy items if needed" and choose the targets where you want to use the package

## Usage

1. Import the package in your Swift file:

```swift
import fit-parser-swift
```

2. Use the `DiveData` struct to parse FIT files:

```swift
let diveData = DiveData(session: fitSessionMesg, summary: fitDiveSummaryMesg, settings: fitDiveSettingsMesg, tankSummaries: fitTankSummaryMesgs, tankUpdates: fitTankUpdateMesgs)
```

## Requirements

- iOS 14.0+
- Swift 5.3+
- Xcode 12.0+

## Dependencies

This package depends on:

- SwiftUI
- ObjcFIT
- SwiftFIT

Make sure these dependencies are available in your project.

## Acknowledgments

- Thanks to the creators of the FIT file format and the ObjcFIT library
