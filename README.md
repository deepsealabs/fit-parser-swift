# fit-parser-swift

fit-parser-swift is a Swift package for parsing and displaying dive data from FIT files. It provides structures for organizing dive data and includes a SwiftUI view for displaying the parsed information.

current fit-parser-swift supports FIT 21.141.0

## Features

- Parse FIT files containing dive data
- Extract session, summary, settings, tank summaries, and tank updates information
- Display parsed data in a user-friendly SwiftUI interface

## Installation

### Swift Package Manager

To integrate fit-parser-swift into your Xcode project using Swift Package Manager, add it to the dependencies value of your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/latishab/fit-parser-swift.git", .upToNextMajor(from: "1.0.0"))
]
```

Then, specify it as a dependency of your target:

```swift
targets: [
    .target(
        name: "YourTarget",
        dependencies: ["FITParserSwift"]),
]
```

The Garmin FIT Objective-C SDK is included as a dependency in this package, so you don't need to add it separately.

## Usage

1. Import the package in your Swift file:

```swift
import FITParserSwift
```

2. Use the `FITParser.parse(fitFilePath:)` method to parse FIT files:

```swift
let result = FITParser.parse(fitFilePath: "path/to/your/file.fit")
switch result {
case .success(let fitData):
    // Use fitData to access parsed information
case .failure(let error):
    print("Error parsing FIT file: \(error)")
}
```

3. Access parsed data through the `FITParser` struct:

```swift
let session = fitData.session
let summary = fitData.summary
let settings = fitData.settings
let tankSummaries = fitData.tankSummaries
let tankUpdates = fitData.tankUpdates
```

4. For a complete example of how to use the parser and display the data, refer to the `ContentView.swift` file in the package. This file demonstrates:
   - How to trigger the parsing of a FIT file
   - How to handle success and error cases
   - How to display all the parsed data in a SwiftUI view

## Example

Here's a simplified example of how to use the `FITParser` in a SwiftUI view:

```swift
import SwiftUI
import FITParserSwift

struct ContentView: View {
    @State private var fitData: FITParser?
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
            Button("Parse FIT File") {
                parseFITFile()
            }
            
            if let fitData = fitData {
                Text("Dive Number: \(fitData.summary.diveNumber ?? 0)")
                Text("Max Depth: \(fitData.summary.maxDepth ?? 0) m")
                // Display more data as needed
            }
            
            if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            }
        }
    }
    
    private func parseFITFile() {
        guard let fileURL = Bundle.main.url(forResource: "TestDive", withExtension: "fit") else {
            self.errorMessage = "Failed to find TestDive.fit file in bundle"
            return
        }
        
        switch FITParser.parse(fitFilePath: fileURL.path) {
        case .success(let parsedFitData):
            self.fitData = parsedFitData
            self.errorMessage = nil
        case .failure(let error):
            self.errorMessage = error.localizedDescription
            self.fitData = nil
        }
    }
}
```

For a more comprehensive example, please refer to the `ContentView.swift` file in the package.

## Requirements

- iOS 14.0+
- macOS 11.0+
- Swift 5.3+
- Xcode 12.0+

## Dependencies

This package includes the following dependency:

- Garmin FIT Objective-C SDK

You don't need to manually add this dependency to your project.

## Contributing

We welcome contributions to the fit-parser-swift project! If you'd like to contribute, please follow these guidelines:

### Getting Started

1. Fork the repository on GitHub.
2. Clone your forked repository to your local machine.
3. Create a new branch for your feature or bug fix.

### Making Changes

1. Make your changes in your feature branch.
2. Add or update tests as necessary.
3. Ensure your code follows the Swift style guide and best practices.
4. Run the existing tests to make sure they still pass.
5. Add new tests for new functionality.

### Submitting Changes

1. Push your changes to your fork on GitHub.
2. Submit a pull request to the main fit-parser-swift repository.
3. In your pull request description, clearly describe the problem you're solving and the proposed solution.
4. Link any relevant issues in the pull request description.

### Code Style

- Follow the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/).
- Use clear, descriptive variable and function names.
- Comment your code where necessary, especially for complex logic.
- Keep functions small and focused on a single task.

### Testing

- Write unit tests for new functionality.
- Ensure all tests pass before submitting a pull request.
- Aim for high test coverage, especially for critical parts of the code.

### Documentation

- Update the README.md file if you're adding or changing functionality.
- Use inline documentation for functions and complex code blocks.
- If you're adding new features, consider updating or creating usage examples.

### Reporting Issues

- Use the GitHub issue tracker to report bugs or suggest features.
- Clearly describe the issue, including steps to reproduce for bugs.
- Check if the issue has already been reported before creating a new one.

## License

This project is licensed under the MIT License. See the [LICENSE](https://github.com/latishab/fit-parser-swift/blob/main/LICENSE) file for the full license text.

Copyright (c) 2024 Latisha Besariani Hendra.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the conditions specified in the LICENSE file.

### FIT Protocol Notice

This parser is based on the Flexible and Interoperable Data Transfer (FIT) Protocol, which is subject to the [FIT Protocol License Agreement](https://developer.garmin.com/fit/download/) by Garmin International, Inc. Users of this parser must comply with the terms of that agreement.

Users are responsible for ensuring their use of this parser complies with both the MIT License and the FIT Protocol License Agreement.

## Acknowledgments

- Thanks to Garmin for providing the FIT Objective-C SDK
