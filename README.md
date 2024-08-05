# fit-parser-swift

fit-parser-swift is a Swift package for parsing and displaying dive data from FIT files. It provides structures for organizing dive data and a SwiftUI view for displaying the parsed information.

## Features

- Parse FIT files containing dive data
- Extract session, summary, settings, and tank information
- Display parsed data in a user-friendly SwiftUI interface

## Installation

### Swift Package Manager

To integrate fit-parser-swift into your Xcode project using Swift Package Manager, add it to the dependencies value of your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/fit-parser-swift.git", .upToNextMajor(from: "1.0.0"))
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

### Manual Installation

1. Download the fit-parser-swift package
2. Drag and drop the package folder into your Xcode project
3. Make sure to select "Copy items if needed" and choose the targets where you want to use the package

## Usage

1. Import the package in your Swift file:

```swift
import FITParserSwift
```

2. Use the `DiveData` struct to parse FIT files:

```swift
let diveData = DiveData(session: fitSessionMesg, summary: fitDiveSummaryMesg, settings: fitDiveSettingsMesg, tankSummaries: fitTankSummaryMesgs, tankUpdates: fitTankUpdateMesgs)
```

3. Use the `ContentView` to display the parsed data:

```swift
ContentView()
```

## Requirements

- iOS 14.0+
- macOS 11.0+
- Swift 5.3+
- Xcode 12.0+

## Dependencies

This package includes the following dependency:

- Garmin FIT Objective-C SDK

You don't need to manually add this dependency to your project.

## License

[Specify your license here]

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

### Code of Conduct

- Be respectful and inclusive in your interactions with other contributors.
- We follow the [Contributor Covenant](https://www.contributor-covenant.org/version/2/0/code_of_conduct/). Please read and adhere to it.

Thank you for contributing to fit-parser-swift! Your efforts help make this project better for everyone.

## Acknowledgments

- Thanks to Garmin for providing the FIT Objective-C SDK
