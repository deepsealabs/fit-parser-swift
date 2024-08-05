import Foundation
import ObjcFIT

public struct FITParser {
    public let session: SessionData
    public let summary: SummaryData
    public let settings: SettingsData
    public let tankSummaries: [TankSummaryData]
    public let tankUpdates: [TankUpdateData]
    
    public struct SessionData {
        let startTime: Date?
        let startCoordinates: (latitude: Double, longitude: Double)?
        let endCoordinates: (latitude: Double, longitude: Double)?
        let maxTemperature: Float?
        let minTemperature: Float?
        let avgTemperature: Float?
        let totalElapsedTime: Float?
        let maxDepth: Float?
        let diveNumber: UInt16?
    }
    
    public struct SummaryData {
        let timestamp: Date?
        let diveNumber: UInt16?
        let maxDepth: Float?
        let surfaceInterval: UInt32?
        let bottomTime: Float?
        let avgDepth: Float?
        let descentTime: Float?
        let ascentTime: Float?
    }
    
    public struct SettingsData {
        let waterType: String?
        let waterDensity: Float?
        let gfLow: UInt8?
        let gfHigh: UInt8?
        let po2Warn: Float?
        let po2Critical: Float?
        let safetyStopEnabled: Bool?
        let bottomDepth: Float?
    }
    
    public struct TankSummaryData {
        let timestamp: Date?
        let sensor: UInt32?
        let startPressure: Float?
        let endPressure: Float?
        let volumeUsed: Float?
    }
    
    public struct TankUpdateData {
        let timestamp: Date?
        let sensor: UInt32?
        let pressure: Float?
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
            bottomTime: summary.isBottomTimeValid() ? summary.getBottomTime() : nil,
            avgDepth: summary.isAvgDepthValid() ? summary.getAvgDepth() : nil,
            descentTime: summary.isDescentTimeValid() ? summary.getDescentTime() : nil,
            ascentTime: summary.isAscentTimeValid() ? summary.getAscentTime() : nil
        )
        
        let waterType = settings.isWaterTypeValid() ? formatWaterType(settings.getWaterType()) : nil

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
}