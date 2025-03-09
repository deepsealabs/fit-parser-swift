import XCTest
@testable import FITParser

final class FITParserTests: XCTestCase {
    var testFitFilePath: String!
    
    override func setUpWithError() throws {
        // Get path to test FIT file in the bundle
        guard let testFileURL = Bundle.module.url(forResource: "TestDive", withExtension: "fit") else {
            XCTFail("Test FIT file not found in bundle")
            return
        }
        testFitFilePath = testFileURL.path
    }
    
    func testParseValidFitFile() throws {
        // Test parsing a valid FIT file
        let result = FITParser.parse(fitFilePath: testFitFilePath)
        
        switch result {
        case .success(let fitData):
            // Debug logging for Session Data
            print("\n=== Session Data ===")
            print("Start Time:", fitData.session.startTime ?? "nil")
            print("Start Coordinates:", fitData.session.startCoordinates ?? "nil")
            print("End Coordinates:", fitData.session.endCoordinates ?? "nil")
            print("Max Temperature:", fitData.session.maxTemperature ?? "nil")
            print("Min Temperature:", fitData.session.minTemperature ?? "nil")
            print("Avg Temperature:", fitData.session.avgTemperature ?? "nil")
            print("Total Elapsed Time:", fitData.session.totalElapsedTime ?? "nil")
            print("Max Depth:", fitData.session.maxDepth ?? "nil")
            print("Dive Number:", fitData.session.diveNumber ?? "nil")
            
            // Test Session Data
            XCTAssertNotNil(fitData.session.startTime)
            XCTAssertNotNil(fitData.session.startCoordinates)
            XCTAssertNotNil(fitData.session.endCoordinates)
            XCTAssertEqual(fitData.session.maxTemperature, 32.0)
            XCTAssertEqual(fitData.session.minTemperature, 26.0)
            XCTAssertEqual(fitData.session.avgTemperature, 27.0)
            XCTAssertEqual(fitData.session.totalElapsedTime, 3480.0)
            XCTAssertEqual(fitData.session.maxDepth, 18.0)
            XCTAssertEqual(fitData.session.diveNumber, 1)
            
            // Test Summary Data
            XCTAssertNotNil(fitData.summary.timestamp)
            XCTAssertEqual(fitData.summary.diveNumber, 1)
            XCTAssertEqual(fitData.summary.maxDepth, 18.0)
            XCTAssertEqual(fitData.summary.surfaceInterval, 4680)
            XCTAssertEqual(fitData.summary.bottomTime, 3480)
            
            // Test Settings Data
            XCTAssertEqual(fitData.settings.waterType, "Salt")
            XCTAssertEqual(fitData.settings.waterDensity, 1025.0)
            
            // Test Tank Data (which we know is empty for this file)
            XCTAssertTrue(fitData.tankSummaries.isEmpty)
            XCTAssertTrue(fitData.tankUpdates.isEmpty)
            
        case .failure(let error):
            XCTFail("Failed to parse valid FIT file: \(error.localizedDescription)")
        }
    }
    
    func testParseInvalidFitFile() {
        // Test parsing an invalid/non-existent file
        let invalidPath = "/path/to/nonexistent/file.fit"
        let result = FITParser.parse(fitFilePath: invalidPath)
        
        switch result {
        case .success:
            XCTFail("Parser should not succeed with invalid file path")
        case .failure(let error):
            XCTAssertNotNil(error)
        }
    }
    
    func testFormatDuration() {
        // Test duration formatting
        let testCases = [
            (UInt32(3661), "01:01:01"),  // 1 hour, 1 minute, 1 second
            (UInt32(7200), "02:00:00"),  // 2 hours
            (UInt32(45), "00:00:45"),    // 45 seconds
            (UInt32(0), "00:00:00")      // 0 seconds
        ]
        
        for (input, expected) in testCases {
            let result = FITParser.formatDuration(input)
            XCTAssertEqual(result, expected, "Duration formatting failed for input: \(input)")
        }
    }
} 