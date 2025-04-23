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
        
        print("Checking file at path: \(filePath)")
        if FileManager.default.fileExists(atPath: filePath) {
            print("File exists")
            if FileManager.default.isReadableFile(atPath: filePath) {
                print("File is readable")
                if let attributes = try? FileManager.default.attributesOfItem(atPath: filePath),
                   let fileSize = attributes[.size] as? Int64 {
                    print("File size: \(fileSize) bytes")
                }
            } else {
                print("File is not readable")
            }
        } else {
            print("File does not exist")
        }

        print("\nAnalyzing FIT file: \(filePath)")
        print("----------------------------------------")

        let result = FITParser.parse(fitFilePath: fileURL.path)

        switch result {
        case .success(let fitData):
            displayFileIdData(fitData.fileId)
            displaySessionData(fitData.session)
            if let summary = fitData.summary {
                displaySummaryData(summary)
            }
            if let settings = fitData.settings {
                displaySettingsData(settings)
            }
            displayTankSummaries(fitData.tankSummaries)
            displayTankUpdates(fitData.tankUpdates)
            displayDivePoints(fitData.divePoints)
            displayDiveAlerts(fitData.diveAlerts)
            displayDiveGases(fitData.diveGases)
            displayLapData(fitData.laps)
        case .failure(let error):
            print("Error parsing FIT file: \(error.localizedDescription)")
        }
    }

    private static func displayFileIdData(_ fileId: FITParser.FileIdData?) {
        print("\n=== File ID ===")
        if let fileId = fileId {
            print("Type:", fileId.type ?? "nil")
            print("Manufacturer:", fileId.manufacturer ?? "nil")
            print("Product ID:", fileId.product.map { String($0) } ?? "nil")
            print("Time Created:", fileId.timeCreated?.description ?? "nil")
            // Note: Product Name usually comes from Device Info message
        } else {
            print("File ID message not found.")
        }
    }

    private static func displaySessionData(_ session: FITParser.SessionData) {
        print("\n=== Session Data ===")
        print("Start Time:", session.startTime?.description ?? "nil")
        if let coords = session.startCoordinates {
            print("Start Coordinates: (\(coords.latitude), \(coords.longitude))")
        } else {
            print("Start Coordinates: nil")
        }
        if let coords = session.endCoordinates {
            print("End Coordinates: (\(coords.latitude), \(coords.longitude))")
        } else {
            print("End Coordinates: nil")
        }
        print("Max Temperature:", session.maxTemperature.map { String(format: "%.1f°C", $0) } ?? "nil")
        print("Min Temperature:", session.minTemperature.map { String(format: "%.1f°C", $0) } ?? "nil")
        print("Avg Temperature:", session.avgTemperature.map { String(format: "%.1f°C", $0) } ?? "nil")
        print("Total Elapsed Time:", session.totalElapsedTime.map { String(format: "%.1f seconds", $0) } ?? "nil")
        print("Max Depth:", session.maxDepth.map { String(format: "%.1f meters", $0) } ?? "nil")
        print("Dive Number:", session.diveNumber ?? "nil")
        print("Dive Time:", session.diveTime.map { FITParser.formatDuration($0) } ?? "nil")
        print("Sport:", session.sport ?? "nil")
        print("Sub Sport:", session.subSport ?? "nil")
        print("Average Speed:", session.avgSpeed.map { String(format: "%.2f km/h", $0) } ?? "nil")
        print("Average Vertical Speed:", session.avgPosVerticalSpeed.map { String(format: "%.2f km/h", $0) } ?? "nil")
        print("Total Distance:", session.totalDistance.map { String(format: "%.2f m", $0) } ?? "nil")
        print("Total Timer Time:", session.totalTimerTime.map { FITParser.formatDuration(UInt32($0)) } ?? "nil")
        print("Total Moving Time:", session.totalMovingTime.map { FITParser.formatDuration(UInt32($0)) } ?? "nil")
        print("Number of Laps:", session.numLaps ?? "nil")
    }

    private static func displaySummaryData(_ summary: FITParser.SummaryData) {
        print("\n=== Summary Data ===")
        print("Timestamp:", summary.timestamp?.description ?? "nil")
        print("Dive Number:", summary.diveNumber ?? "nil")
        print("Max Depth:", summary.maxDepth.map { String(format: "%.1f meters", $0) } ?? "nil")
        print("Surface Interval:", summary.surfaceInterval.map { FITParser.formatDuration($0) } ?? "nil")
        print("Descent Time:", summary.descentTime.map { String(format: "%.1f seconds", $0) } ?? "nil")
        print("Ascent Time:", summary.ascentTime.map { String(format: "%.1f seconds", $0) } ?? "nil")
        print("Bottom Time:", summary.bottomTime.map { FITParser.formatDuration($0) } ?? "nil")
    }

    private static func displaySettingsData(_ settings: FITParser.SettingsData) {
        print("\n=== Settings Data ===")
        print("Water Type:", settings.waterType ?? "nil")
        print("Water Density:", settings.waterDensity.map { String(format: "%.1f kg/m³", $0) } ?? "nil")
        print("GF Low:", settings.gfLow ?? "nil")
        print("GF High:", settings.gfHigh ?? "nil")
        print("PO2 Warn:", settings.po2Warn.map { String(format: "%.2f bar", $0) } ?? "nil")
        print("PO2 Critical:", settings.po2Critical.map { String(format: "%.2f bar", $0) } ?? "nil")
        print("Safety Stop Enabled:", settings.safetyStopEnabled.map { $0 ? "Yes" : "No" } ?? "nil")
        print("Bottom Depth:", settings.bottomDepth.map { String(format: "%.1f meters", $0) } ?? "nil")
    }

    private static func displayTankSummaries(_ summaries: [FITParser.TankSummaryData]) {
        print("\n=== Tank Summaries (\(summaries.count) entries) ===")
        for (index, summary) in summaries.enumerated() {
            print("\nTank Summary #\(index + 1):")
            print("Timestamp:", summary.timestamp?.description ?? "nil")
            print("Sensor:", summary.sensor ?? "nil")
            print("Start Pressure:", summary.startPressure.map { String(format: "%.1f bar", $0) } ?? "nil")
            print("End Pressure:", summary.endPressure.map { String(format: "%.1f bar", $0) } ?? "nil")
            print("Volume Used:", summary.volumeUsed.map { String(format: "%.1f L", $0) } ?? "nil")
        }
    }

    private static func displayTankUpdates(_ updates: [FITParser.TankUpdateData]) {
        print("\n=== Tank Updates (\(updates.count) entries) ===")
        for (index, update) in updates.enumerated() {
            print("\nTank Update #\(index + 1):")
            print("Timestamp:", update.timestamp?.description ?? "nil")
            print("Sensor:", update.sensor ?? "nil")
            print("Pressure:", update.pressure.map { String(format: "%.1f bar", $0) } ?? "nil")
        }
    }

    private static func displayDivePoints(_ points: [FITParser.DivePoint]) {
        print("\n=== Dive Profile Points (\(points.count) points) ===")
        for (i, point) in points.prefix(5).enumerated() {  // Show first 5 points
            print("\nPoint #\(i + 1):")
            print("Time:", point.timestamp?.description ?? "nil")
            print("Depth:", point.depth.map { String(format: "%.2f m", $0) } ?? "nil")
            print("Temperature:", point.temperature.map { String(format: "%.1f°C", $0) } ?? "nil")
            print("Heart Rate:", point.heartRate.map { "\($0) bpm" } ?? "nil")
            print("N2 Load:", point.n2Load.map { "\($0)%" } ?? "nil")
            print("CNS Load:", point.cnsLoad.map { "\($0)%" } ?? "nil")
            print("Next Stop Depth:", point.nextStopDepth.map { String(format: "%.2f m", $0) } ?? "nil")
            print("Next Stop Time:", point.nextStopTime.map { "\($0) s" } ?? "nil")
            print("Time to Surface:", point.timeToSurface.map { "\($0) s" } ?? "nil")
        }
        if points.count > 5 {
            print("\n... and \(points.count - 5) more points")
        }
    }

    private static func displayDiveAlerts(_ alerts: [FITParser.DiveAlert]) {
        print("\n=== Dive Alerts (\(alerts.count) alerts) ===")
        for (i, alert) in alerts.enumerated() {
            print("\nAlert #\(i + 1):")
            print("Time:", alert.timestamp?.description ?? "nil")
            print("Event:", alert.event ?? "nil")
            print("Event Type:", alert.eventType ?? "nil")
            print("Data:", alert.data ?? "nil")
        }
    }

    private static func displayDiveGases(_ gases: [FITParser.DiveGas]) {
        print("\n=== Dive Gases (\(gases.count) gases) ===")
        for (i, gas) in gases.enumerated() {
            print("\nGas #\(i + 1):")
            print("Message Index:", gas.messageIndex ?? "nil")
            print("Helium Content:", gas.heliumContent.map { "\($0)%" } ?? "nil")
            print("Oxygen Content:", gas.oxygenContent.map { "\($0)%" } ?? "nil")
            print("Status:", gas.status ?? "nil")
            print("Mode:", gas.mode ?? "nil")
        }
    }

    private static func displayLapData(_ laps: [FITParser.LapData]) {
        print("\n=== Lap Data (\(laps.count) laps) ===")
        for (index, lap) in laps.enumerated() {
            print("\nLap #\(index + 1):")
            print("Timestamp:", lap.timestamp?.description ?? "nil")
            print("Start Time:", lap.startTime?.description ?? "nil")
            if let coords = lap.startCoordinates {
                print("Start Coordinates: (\(coords.latitude), \(coords.longitude))")
            } else {
                print("Start Coordinates: nil")
            }
            if let coords = lap.endCoordinates {
                print("End Coordinates: (\(coords.latitude), \(coords.longitude))")
            } else {
                print("End Coordinates: nil")
            }
            print("Total Elapsed Time:", lap.totalElapsedTime.map { String(format: "%.1f seconds", $0) } ?? "nil")
            print("Total Timer Time:", lap.totalTimerTime.map { String(format: "%.1f seconds", $0) } ?? "nil")
            print("Total Distance:", lap.totalDistance.map { String(format: "%.2f m", $0) } ?? "nil")
            print("Max Speed:", lap.maxSpeed.map { String(format: "%.2f km/h", $0) } ?? "nil")
            print("Avg Speed:", lap.avgSpeed.map { String(format: "%.2f km/h", $0) } ?? "nil")
            print("Max Altitude:", lap.maxAltitude.map { String(format: "%.1f m", $0) } ?? "nil")
            print("Avg Altitude:", lap.avgAltitude.map { String(format: "%.1f m", $0) } ?? "nil")
            print("Max Depth:", lap.maxDepth.map { String(format: "%.1f m", $0) } ?? "nil")
            print("Avg Depth:", lap.avgDepth.map { String(format: "%.1f m", $0) } ?? "nil")
        }
    }
}