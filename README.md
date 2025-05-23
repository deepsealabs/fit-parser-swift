# FIT Parser Swift

![GitHub forks](https://img.shields.io/github/forks/deepsealabs/fit-parser-swift?style=social)
![GitHub stars](https://img.shields.io/github/stars/deepsealabs/fit-parser-swift?style=social)
![License](https://img.shields.io/github/license/deepsealabs/fit-parser-swift)

A Swift library for parsing Garmin FIT (Flexible and Interoperable Data Transfer) files, specifically focused on dive computer data.

## Features

- Parse FIT files from Garmin dive computers
- Extract detailed dive information including:
  - Session data (time, coordinates, temperature, depth)
  - Dive summary (max depth, surface interval, bottom time)
  - Dive settings (water type, gradient factors, PO2 limits)
  - Tank data (pressure, volume)
  - Dive profile points (depth, temperature, heart rate, tissue loading)
  - Dive alerts and events
  - Gas configurations

## Installation

Add this package to your project using Swift Package Manager by adding it to your `Package.swift`:

```swift
// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "YourProject",
    platforms: [
        .macOS(.v11),
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "YourProject",
            targets: ["YourProject"]),
    ],
    dependencies: [
        .package(url: "https://github.com/deepsealabs/fit-parser-swift.git", from: "1.2.0")
    ],
    targets: [
        .target(
            name: "YourProject",
            dependencies: ["FITParser"])
    ]
)
```

Or if you're using Xcode:
1. Go to File > Add Packages...
2. Enter package URL: `https://github.com/deepsealabs/fit-parser-swift.git`
3. Select version: `1.2.0` or higher

## Usage

### Command Line Interface

```bash
swift run FITParserCLI Sources/FITParser/TestDive4.fit
```

### Library Usage

```swift
import FITParser

// Parse a FIT file
let result = FITParser.parse(fitFilePath: "Sources/FITParser/TestDive4.fit")

switch result {
case .success(let fitData):
    // Access dive data
    print("Max Depth:", fitData.summary.maxDepth ?? "N/A")
    print("Dive Time:", FITParser.formatDuration(fitData.session.diveTime ?? 0))
    
    // Access dive profile points
    for point in fitData.divePoints {
        print("Depth:", point.depth ?? "N/A")
        print("Temperature:", point.temperature ?? "N/A")
    }
    
case .failure(let error):
    print("Error parsing FIT file:", error)
}
```

## Data Structures

### Main Components
- `SessionData`: Overall dive session information
- `SummaryData`: Dive summary statistics
- `SettingsData`: Dive computer settings
- `DivePoint`: Individual data points throughout the dive
- `DiveAlert`: Alerts and events during the dive
- `DiveGas`: Gas mix configurations

### Example Data Access

```swift
// Access session data
let startTime = fitData.session.startTime
let maxDepth = fitData.session.maxDepth
let avgTemp = fitData.session.avgTemperature

// Access dive profile
for point in fitData.divePoints {
    let depth = point.depth
    let n2Load = point.n2Load
    let cnsLoad = point.cnsLoad
}

// Access alerts
for alert in fitData.diveAlerts {
    print("Alert:", alert.event ?? "Unknown")
    print("Details:", alert.interpretedData ?? "No details")
}
```

## Requirements

- Swift 5.5+
- macOS 11.0+ / iOS 14.0+

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
