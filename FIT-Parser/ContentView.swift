import SwiftUI
import FITParser

struct ContentView: View {
    @State private var fitData: FITParser?
    @State private var errorMessage: String?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Button("Parse FIT File") {
                    parseFile()
                }
                .padding()
                
                if let fitData = fitData {
                    displaySession(fitData.session)
                    displayDiveSummary(fitData.summary)
                    displayDiveSettings(fitData.settings)
                    displayTankSummaries(fitData.tankSummaries)
                    displayTankUpdates(fitData.tankUpdates)
                }
                
                if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                }
            }
            .padding()
        }
    }
    
    private func parseFile() {
        guard let fileURL = Bundle.main.url(forResource: "TestDive", withExtension: "fit") else {
            self.errorMessage = "Failed to find TestDive.fit file in bundle"
            self.fitData = nil
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
    
    private func displaySession(_ session: FITParser.SessionData) -> some View {
        VStack(alignment: .leading) {
            Text("Session Information").font(.headline)
            if let startTime = session.startTime {
                Text("Start Time: \(formatDate(startTime))")
            }
            if let startCoordinates = session.startCoordinates {
                Text("Start Coordinates: \(formatCoordinate(startCoordinates))")
            }
            if let endCoordinates = session.endCoordinates {
                Text("End Coordinates: \(formatCoordinate(endCoordinates))")
            }
            if let maxTemperature = session.maxTemperature {
                Text("Max Temperature: \(String(format: "%.1f", maxTemperature)) °C")
            }
            if let minTemperature = session.minTemperature {
                Text("Min Temperature: \(String(format: "%.1f", minTemperature)) °C")
            }
            if let totalElapsedTime = session.totalElapsedTime {
                Text("Total Elapsed Time: \(formatDuration(UInt32(totalElapsedTime)))")
            }
            if let maxDepth = session.maxDepth {
                Text("Max Depth: \(String(format: "%.3f", maxDepth)) m")
            }
            if let diveNumber = session.diveNumber {
                Text("Dive Number: \(diveNumber)")
            }
        }
        .padding(.bottom)
    }
    
    private func displayDiveSummary(_ summary: FITParser.SummaryData) -> some View {
        VStack(alignment: .leading) {
            Text("Dive Summary").font(.headline)
            if let timestamp = summary.timestamp {
                Text("Timestamp: \(formatDate(timestamp))")
            }
            if let diveNumber = summary.diveNumber {
                Text("Dive Number: \(diveNumber)")
            }
            if let maxDepth = summary.maxDepth {
                Text("Max Depth: \(String(format: "%.3f", maxDepth)) m")
            }
            if let surfaceInterval = summary.surfaceInterval {
                Text("Surface Interval: \(formatDuration(surfaceInterval))")
            }
            if let bottomTime = summary.bottomTime {
                Text("Bottom Time: \(formatDuration(UInt32(bottomTime)))")
            }
            if let avgDepth = summary.avgDepth {
                Text("Average Depth: \(String(format: "%.3f", avgDepth)) m")
            }
            if let descentTime = summary.descentTime {
                Text("Descent Time: \(formatDuration(UInt32(descentTime)))")
            }
            if let ascentTime = summary.ascentTime {
                Text("Ascent Time: \(formatDuration(UInt32(ascentTime)))")
            }
        }
        .padding(.bottom)
    }
    
    private func displayDiveSettings(_ settings: FITParser.SettingsData) -> some View {
        VStack(alignment: .leading) {
            Text("Dive Settings").font(.headline)
            if let waterType = settings.waterType {
                Text("Water Type: \(waterType)")
            }
            if let waterDensity = settings.waterDensity {
                Text("Water Density: \(String(format: "%.3f", waterDensity)) kg/m^3")
            }
            if let gfLow = settings.gfLow {
                Text("GF Low: \(gfLow)")
            }
            if let gfHigh = settings.gfHigh {
                Text("GF High: \(gfHigh)")
            }
            if let po2Warn = settings.po2Warn {
                Text("PO2 Warning: \(String(format: "%.2f", po2Warn)) bar")
            }
            if let po2Critical = settings.po2Critical {
                Text("PO2 Critical: \(String(format: "%.2f", po2Critical)) bar")
            }
            if let safetyStopEnabled = settings.safetyStopEnabled {
                Text("Safety Stop Enabled: \(safetyStopEnabled ? "Yes" : "No")")
            }
            if let bottomDepth = settings.bottomDepth {
                Text("Bottom Depth: \(String(format: "%.2f", bottomDepth)) m")
            }
        }
        .padding(.bottom)
    }
    
    private func displayTankSummaries(_ summaries: [FITParser.TankSummaryData]) -> some View {
        VStack(alignment: .leading) {
            Text("Tank Summaries").font(.headline)
            ForEach(summaries, id: \.sensor) { summary in
                VStack(alignment: .leading) {
                    if let sensor = summary.sensor {
                        Text("Sensor: \(sensor)")
                    }
                    if let startPressure = summary.startPressure {
                        Text("Start Pressure: \(String(format: "%.1f", startPressure)) bar")
                    }
                    if let endPressure = summary.endPressure {
                        Text("End Pressure: \(String(format: "%.1f", endPressure)) bar")
                    }
                    if let volumeUsed = summary.volumeUsed {
                        Text("Volume Used: \(String(format: "%.1f", volumeUsed)) L")
                    }
                }
                .padding(.bottom, 5)
            }
        }
        .padding(.bottom)
    }
    
    private func displayTankUpdates(_ updates: [FITParser.TankUpdateData]) -> some View {
        VStack(alignment: .leading) {
            Text("Tank Updates").font(.headline)
            ForEach(updates, id: \.timestamp) { update in
                VStack(alignment: .leading) {
                    if let timestamp = update.timestamp {
                        Text("Time: \(formatDate(timestamp))")
                    }
                    if let sensor = update.sensor {
                        Text("Sensor: \(sensor)")
                    }
                    if let pressure = update.pressure {
                        Text("Pressure: \(String(format: "%.1f", pressure)) bar")
                    }
                }
                .padding(.bottom, 5)
            }
        }
        .padding(.bottom)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ seconds: UInt32) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, remainingSeconds)
    }
    
    private func formatCoordinate(_ coordinate: (latitude: Double, longitude: Double)) -> String {
        return String(format: "%.6f, %.6f", coordinate.latitude, coordinate.longitude)
    }
}