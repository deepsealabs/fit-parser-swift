import SwiftUI
import ObjcFIT
import SwiftFIT

struct ContentView: View {
    @State private var diveData: DiveData?
    @State private var errorMessage: String?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Button("Parse FIT File") {
                    parseFITFile()
                }
                .padding()
                
                if let diveData = diveData {
                    displaySession(diveData.session)
                    displayDiveSummary(diveData.summary)
                    displayDiveSettings(diveData.settings)
                    
                    ForEach(diveData.tankSummaries, id: \.sensor) { summary in
                        Text("Tank Summary: Start Pressure: \(summary.startPressure ?? 0), End Pressure: \(summary.endPressure ?? 0)")
                    }
                    ForEach(diveData.tankUpdates, id: \.timestamp) { update in
                        Text("Tank Update: Pressure: \(update.pressure ?? 0)")
                    }
                }
                
                if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                }
            }
            .padding()
        }
    }
    
    private func parseFITFile() {
        let decoder = FITDecoder()
        let listener = FITListener()
        decoder.mesgDelegate = listener
        
        guard let fileURL = Bundle.main.url(forResource: "TestDive", withExtension: "fit") else {
            self.errorMessage = "Failed to find TestDive.fit file in bundle"
            self.diveData = nil
            return
        }
        
        print("Attempting to decode file at: \(fileURL.path)")
        
        if decoder.decodeFile(fileURL.path) {
            if let session = listener.messages.getSessionMesgs().first,
               let summary = listener.messages.getDiveSummaryMesgs().first,
               let settings = listener.messages.getDiveSettingsMesgs().first {
                let tankSummaries = listener.messages.getTankSummaryMesgs()
                let tankUpdates = listener.messages.getTankUpdateMesgs()
                self.diveData = DiveData(session: session, summary: summary, settings: settings, tankSummaries: tankSummaries, tankUpdates: tankUpdates)
                self.errorMessage = nil
            } else {
                self.errorMessage = "Failed to extract dive data from FIT file"
                self.diveData = nil
            }
        } else {
            self.errorMessage = "Failed to decode FIT file at path: \(fileURL.path)"
            self.diveData = nil
        }
    }
    
    private func displaySession(_ session: DiveData.SessionData) -> some View {
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
    
    private func displayDiveSummary(_ summary: DiveData.SummaryData) -> some View {
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
                Text("Bottom Time: \(formatDuration(bottomTime))")
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
    
    private func displayDiveSettings(_ settings: DiveData.SettingsData) -> some View {
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy hh:mm:ss a"
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ seconds: UInt32) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, remainingSeconds)
    }
    
    private func formatDuration(_ seconds: Float) -> String {
        let minutes = Int(seconds) / 60
        let remainingSeconds = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    private func formatCoordinate(_ coordinate: (latitude: Double, longitude: Double)) -> String {
        return String(format: "%.6f, %.6f", coordinate.latitude, coordinate.longitude)
    }
}