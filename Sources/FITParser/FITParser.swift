import Foundation
import ObjcFIT
import SwiftFIT

public struct FITParser {
    public let session: SessionData
    public let summary: SummaryData
    public let settings: SettingsData
    public let tankSummaries: [TankSummaryData]
    public let tankUpdates: [TankUpdateData]
    
    public struct SessionData {
        public let startTime: Date?
        public let startCoordinates: (latitude: Double, longitude: Double)?
        public let endCoordinates: (latitude: Double, longitude: Double)?
        public let maxTemperature: Float?
        public let minTemperature: Float?
        public let avgTemperature: Float?
        public let totalElapsedTime: Float?
        public let maxDepth: Float?
        public let diveNumber: UInt16?
    }
    
    public struct SummaryData {
        public let timestamp: Date?
        public let diveNumber: UInt16?
        public let maxDepth: Float?
        public let surfaceInterval: UInt32?
        public let descentTime: Float?
        public let ascentTime: Float?
        public let bottomTime: UInt32?
        
        public init(timestamp: Date?, diveNumber: UInt16?, maxDepth: Float?, surfaceInterval: UInt32?, descentTime: Float?, ascentTime: Float?, bottomTime: UInt32?) {
            self.timestamp = timestamp
            self.diveNumber = diveNumber
            self.maxDepth = maxDepth
            self.surfaceInterval = surfaceInterval
            self.descentTime = descentTime
            self.ascentTime = ascentTime
            self.bottomTime = bottomTime
        }
    }
    
    public struct SettingsData {
        public let waterType: String?
        public let waterDensity: Float?
        public let gfLow: UInt8?
        public let gfHigh: UInt8?
        public let po2Warn: Float?
        public let po2Critical: Float?
        public let safetyStopEnabled: Bool?
        public let bottomDepth: Float?
    }
    
    public struct TankSummaryData {
        public let timestamp: Date?
        public let sensor: UInt32?
        public let startPressure: Float?
        public let endPressure: Float?
        public let volumeUsed: Float?
    }
    
    public struct TankUpdateData {
        public let timestamp: Date?
        public let sensor: UInt32?
        public let pressure: Float?
    }
    
    private init(session: FITSessionMesg, summary: FITDiveSummaryMesg, settings: FITDiveSettingsMesg, tankSummaries: [FITTankSummaryMesg], tankUpdates: [FITTankUpdateMesg]) {
        self.session = SessionData(
            startTime: session.isStartTimeValid() ? FITDate.date(from: session.getStartTime()) : nil,
            startCoordinates: (session.isStartPositionLatValid() && session.isStartPositionLongValid()) ?
                (latitude: Double(session.getStartPositionLat()) * (180.0 / 2147483648.0),
                 longitude: Double(session.getStartPositionLong()) * (180.0 / 2147483648.0)) : nil,
            endCoordinates: (session.isEndPositionLatValid() && session.isEndPositionLongValid()) ?
                (latitude: Double(session.getEndPositionLat()) * (180.0 / 2147483648.0),
                 longitude: Double(session.getEndPositionLong()) * (180.0 / 2147483648.0)) : nil,
            maxTemperature: session.isMaxTemperatureValid() ? Float(session.getMaxTemperature()) : nil,
            minTemperature: session.isMinTemperatureValid() ? Float(session.getMinTemperature()) : nil,
            avgTemperature: session.isAvgTemperatureValid() ? Float(session.getAvgTemperature()) : nil,
            totalElapsedTime: session.isTotalElapsedTimeValid() ? session.getTotalElapsedTime() : nil,
            maxDepth: session.isMaxDepthValid() ? session.getMaxDepth() : nil,
            diveNumber: session.isDiveNumberValid() ? UInt16(session.getDiveNumber()) : nil
        )
        
        self.summary = SummaryData(
            timestamp: summary.isTimestampValid() ? FITDate.date(from: summary.getTimestamp()) : nil,
            diveNumber: summary.isDiveNumberValid() ? UInt16(summary.getDiveNumber()) : nil,
            maxDepth: summary.isMaxDepthValid() ? summary.getMaxDepth() : nil,
            surfaceInterval: summary.isSurfaceIntervalValid() ? summary.getSurfaceInterval() : nil,
            descentTime: summary.isDescentTimeValid() ? summary.getDescentTime() : nil,
            ascentTime: summary.isAscentTimeValid() ? summary.getAscentTime() : nil,
            bottomTime: session.isTotalElapsedTimeValid() ? UInt32(session.getTotalElapsedTime()) : nil
        )
        
        let waterType = settings.isWaterTypeValid() ? FITParser.formatWaterType(settings.getWaterType()) : nil

        self.settings = SettingsData(
            waterType: waterType,
            waterDensity: settings.isWaterDensityValid() ? settings.getWaterDensity() : nil,
            gfLow: settings.isGfLowValid() ? settings.getGfLow() : nil,
            gfHigh: settings.isGfHighValid() ? settings.getGfHigh() : nil,
            po2Warn: settings.isPo2WarnValid() ? Float(settings.getPo2Warn()) / 100.0 : nil,
            po2Critical: settings.isPo2CriticalValid() ? Float(settings.getPo2Critical()) / 100.0 : nil,
            safetyStopEnabled: settings.isSafetyStopEnabledValid() ? (settings.getSafetyStopEnabled() == FITBoolTrue) : nil,
            bottomDepth: settings.isBottomDepthValid() ? settings.getBottomDepth() : nil
        )
        
        self.tankSummaries = tankSummaries.map { summary in
            TankSummaryData(
                timestamp: summary.isTimestampValid() ? FITDate.date(from: summary.getTimestamp()) : nil,
                sensor: summary.isSensorValid() ? summary.getSensor() : nil,
                startPressure: summary.isStartPressureValid() ? summary.getStartPressure() : nil,
                endPressure: summary.isEndPressureValid() ? summary.getEndPressure() : nil,
                volumeUsed: summary.isVolumeUsedValid() ? summary.getVolumeUsed() : nil
            )
        }
        
        self.tankUpdates = tankUpdates.map { update in
            TankUpdateData(
                timestamp: update.isTimestampValid() ? FITDate.date(from: update.getTimestamp()) : nil,
                sensor: update.isSensorValid() ? update.getSensor() : nil,
                pressure: update.isPressureValid() ? update.getPressure() : nil
            )
        }
    }
    
    public static func parse(fitFilePath: String) -> Result<FITParser, Error> {
        let decoder = FITDecoder()
        let listener = FITListener()
        decoder.mesgDelegate = listener
        
        guard decoder.decodeFile(fitFilePath) else {
            return .failure(NSError(domain: "FITParserError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode FIT file"]))
        }
        
        guard let session = listener.messages.getSessionMesgs().first,
              let summary = listener.messages.getDiveSummaryMesgs().first,
              let settings = listener.messages.getDiveSettingsMesgs().first else {
            return .failure(NSError(domain: "FITParserError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to extract data from FIT file"]))
        }
        
        let tankSummaries = listener.messages.getTankSummaryMesgs()
        let tankUpdates = listener.messages.getTankUpdateMesgs()
        
        let fitParser = FITParser(session: session, summary: summary, settings: settings, tankSummaries: tankSummaries, tankUpdates: tankUpdates)
        return .success(fitParser)
    }
    
    static private func formatWaterType(_ waterType: FITWaterType) -> String {
        switch waterType {
        case FITWaterTypeFresh:
            return "Fresh"
        case FITWaterTypeSalt:
            return "Salt"
        case FITWaterTypeEn13319:
            return "EN13319"
        case FITWaterTypeCustom:
            return "Custom"
        default:
            return "Unknown"
        }
    }
    
    public static func formatDuration(_ seconds: UInt32) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, remainingSeconds)
    }
}