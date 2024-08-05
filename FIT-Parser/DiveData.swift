import Foundation
import ObjcFIT

struct DiveData {
    let session: SessionData
    let summary: SummaryData
    let settings: SettingsData
    let tankSummaries: [TankSummaryData]
    let tankUpdates: [TankUpdateData]
    
    struct SessionData {
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
    
    struct SummaryData {
        let timestamp: Date?
        let diveNumber: UInt16?
        let maxDepth: Float?
        let surfaceInterval: UInt32?
        let bottomTime: Float?
        let avgDepth: Float?
        let descentTime: Float?
        let ascentTime: Float?
    }
    
    struct SettingsData {
        let waterType: String?
        let waterDensity: Float?
        let gfLow: UInt8?
        let gfHigh: UInt8?
        let po2Warn: Float?
        let po2Critical: Float?
        let safetyStopEnabled: Bool?
        let bottomDepth: Float?
    }
    
    struct TankSummaryData {
        let timestamp: Date?
        let sensor: UInt32?
        let startPressure: Float?
        let endPressure: Float?
        let volumeUsed: Float?
    }
    
    struct TankUpdateData {
        let timestamp: Date?
        let sensor: UInt32?
        let pressure: Float?
    }
    
    init(session: FITSessionMesg, summary: FITDiveSummaryMesg, settings: FITDiveSettingsMesg, tankSummaries: [FITTankSummaryMesg], tankUpdates: [FITTankUpdateMesg]) {
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
        
        let waterType = settings.isWaterTypeValid() ? DiveData.formatWaterType(settings.getWaterType()) : nil

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