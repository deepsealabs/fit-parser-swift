import Foundation
import FITParser

public struct FITParserCLI {
    public static func main() {
        guard CommandLine.arguments.count > 1 else {
            print("Usage: FITParserCLI <path_to_fit_file>")
            exit(1)
        }

        let filePath = CommandLine.arguments[1]
        let fileURL = URL(fileURLWithPath: filePath)

        print("Parsing FIT file: \(filePath)")

        let result = FITParser.parse(fitFilePath: fileURL.path)

        switch result {
        case .success(let fitData):
            printFITData(fitData)
        case .failure(let error):
            print("Error parsing FIT file: \(error.localizedDescription)")
        }
    }

    private static func printFITData(_ fitData: FITParser) {
        print("\nSession Data:")
        print(fitData.session)

        print("\nSummary Data:")
        print(fitData.summary)

        print("\nSettings Data:")
        print(fitData.settings)

        print("\nTank Summaries:")
        for (index, summary) in fitData.tankSummaries.enumerated() {
            print("Tank \(index + 1):")
            print(summary)
        }

        print("\nTank Updates:")
        for (index, update) in fitData.tankUpdates.enumerated() {
            print("Update \(index + 1):")
            print(update)
        }
    }
}