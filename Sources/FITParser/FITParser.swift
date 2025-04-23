import Foundation
import ObjcFIT
import SwiftFIT

public struct FITParser {
    public struct DivePoint {
        public let timestamp: Date?
        public let depth: Float?
        public let temperature: Float?
        public let heartRate: UInt8?
        public let n2Load: UInt16?
        public let cnsLoad: UInt8?
        public let nextStopDepth: Float?
        public let nextStopTime: UInt32?
        public let timeToSurface: UInt32?
        public let absolutePressure: UInt32?
        public let altitude: Float?
    }

    public struct DiveAlert {
        public let timestamp: Date?
        public let event: String?      // Type of event
        public let eventType: String?  // Additional event info
        public let data: UInt32?      // Raw event data
        public let interpretedData: String? // Human-readable interpretation of data
    }

    public struct DiveGas {
        public let messageIndex: UInt16?
        public let heliumContent: UInt8?
        public let oxygenContent: UInt8?
        public let status: String?  // "enabled" or "disabled"
        public let mode: String?    // "closed circuit diluent" or "open circuit"
    }

    public struct DeviceStatus {
        public let timestamp: Date?
        public let deviceType: FITUInt8?
        public let productName: String?
        public let batteryStatus: FITBatteryStatus?
        public let batteryVoltage: FITFloat32?
        public let batteryLevel: FITUInt8?
    }

    public let session: SessionData
    public let summary: SummaryData?
    public let settings: SettingsData?
    public let tankSummaries: [TankSummaryData]
    public let tankUpdates: [TankUpdateData]
    public let divePoints: [DivePoint]
    public let diveAlerts: [DiveAlert]
    public let diveGases: [DiveGas]
    public let laps: [LapData]
    public let fileId: FileIdData?
    
    public struct LapData {
        public let timestamp: Date?
        public let startTime: Date?
        public let startCoordinates: (latitude: Double, longitude: Double)?
        public let endCoordinates: (latitude: Double, longitude: Double)?
        public let totalElapsedTime: Float?
        public let totalTimerTime: Float?
        public let totalDistance: Float?
        public let maxSpeed: Float?
        public let avgSpeed: Float?
        public let maxAltitude: Float?
        public let avgAltitude: Float?
        public let maxDepth: Float?
        public let avgDepth: Float?
    }
    
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
        public let entryType: String?
        public let diveTime: UInt32?
        public let sport: String?
        public let subSport: String?
        public let avgSpeed: Float?
        public let avgPosVerticalSpeed: Float?
        public let totalDistance: Float?
        public let totalTimerTime: Float?
        public let totalMovingTime: Float?
        public let numLaps: UInt16?
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
    
    public struct FileIdData {
        public let type: String?
        public let manufacturer: String?
        public let product: UInt16?
        public let serialNumber: UInt32?
        public let timeCreated: Date?
    }
    
    private init(session: SessionData, summary: SummaryData?, settings: SettingsData?, 
                tankSummaries: [TankSummaryData], tankUpdates: [TankUpdateData], 
                divePoints: [DivePoint], diveAlerts: [DiveAlert], diveGases: [DiveGas],
                deviceInfo: [FITDeviceInfoMesg], laps: [LapData],
                fileId: FileIdData?) {
        self.session = session
        self.summary = summary
        self.settings = settings
        self.tankSummaries = tankSummaries
        self.tankUpdates = tankUpdates
        self.divePoints = divePoints
        self.diveAlerts = diveAlerts
        self.diveGases = diveGases
        self.laps = laps
        self.fileId = fileId
    }
    
    public static func parse(fitFilePath: String) -> Result<FITParser, Error> {
        let decoder = FITDecoder()
        let listener = FITListener()
        decoder.mesgDelegate = listener
        
        if !decoder.decodeFile(fitFilePath) {
            print("FIT decoder failed to decode file")
            return .failure(NSError(domain: "FITParserError", code: 1, 
                                  userInfo: [NSLocalizedDescriptionKey: "Failed to decode FIT file"]))
        }
        
        let sessions = listener.messages.getSessionMesgs()
        let summaries = listener.messages.getDiveSummaryMesgs()
        let settings = listener.messages.getDiveSettingsMesgs()
        let tankUpdates = listener.messages.getTankUpdateMesgs()
        let tankSummaries = listener.messages.getTankSummaryMesgs()
        let records = listener.messages.getRecordMesgs()
        let events = listener.messages.getEventMesgs()
        let gases = listener.messages.getDiveGasMesgs()
        let deviceInfo = listener.messages.getDeviceInfoMesgs()
        let laps = listener.messages.getLapMesgs()
        let fileIds = listener.messages.getFileIdMesgs()
        
        guard let session = sessions.first else {
            return .failure(NSError(domain: "FITParserError", code: 2, 
                                  userInfo: [NSLocalizedDescriptionKey: "Failed to extract essential session data from FIT file"]))
        }
        
        let summary = summaries.first
        let setting = settings.first

        let startTime = session.isTimestampValid() ? FITDate.date(from: session.getTimestamp()) : nil
        let divFactor = Double(Int32.max) / 180.0

        let startCoords = session.isStartPositionLatValid() && session.isStartPositionLongValid() ? 
            (Double(session.getStartPositionLat()) / divFactor,
             Double(session.getStartPositionLong()) / divFactor) : nil

        let endCoords = session.isEndPositionLatValid() && session.isEndPositionLongValid() ? 
            (Double(session.getEndPositionLat()) / divFactor,
             Double(session.getEndPositionLong()) / divFactor) : nil

        let sessionData = SessionData(
            startTime: startTime,
            startCoordinates: startCoords,
            endCoordinates: endCoords,
            maxTemperature: session.isMaxTemperatureValid() ? Float(session.getMaxTemperature()) : nil,
            minTemperature: session.isMinTemperatureValid() ? Float(session.getMinTemperature()) : nil,
            avgTemperature: session.isAvgTemperatureValid() ? Float(session.getAvgTemperature()) : nil,
            totalElapsedTime: session.isTotalElapsedTimeValid() ? session.getTotalElapsedTime() : nil,
            maxDepth: session.isTotalDescentValid() ? Float(session.getTotalDescent()) : nil,
            diveNumber: session.isNumLapsValid() ? UInt16(session.getNumLaps()) : nil,
            entryType: nil,
            diveTime: session.isTotalTimerTimeValid() ? UInt32(session.getTotalTimerTime()) : nil,
            sport: session.isSportValid() ? formatSport(session.getSport()) : nil,
            subSport: session.isSubSportValid() ? formatSubSport(session.getSubSport()) : nil,
            avgSpeed: session.isAvgSpeedValid() ? session.getAvgSpeed() : nil,
            avgPosVerticalSpeed: session.isAvgPosVerticalSpeedValid() ? session.getAvgPosVerticalSpeed() : nil,
            totalDistance: session.isTotalDistanceValid() ? session.getTotalDistance() : nil,
            totalTimerTime: session.isTotalTimerTimeValid() ? session.getTotalTimerTime() : nil,
            totalMovingTime: session.isTotalMovingTimeValid() ? session.getTotalMovingTime() : nil,
            numLaps: session.isNumLapsValid() ? UInt16(session.getNumLaps()) : nil
        )

        let summaryData: SummaryData? = summary.map { summaryMsg in
            SummaryData(
                timestamp: summaryMsg.isTimestampValid() ? FITDate.date(from: summaryMsg.getTimestamp()) : nil,
                diveNumber: summaryMsg.isDiveNumberValid() ? UInt16(summaryMsg.getDiveNumber()) : nil,
                maxDepth: summaryMsg.isMaxDepthValid() ? summaryMsg.getMaxDepth() : nil,
                surfaceInterval: summaryMsg.isSurfaceIntervalValid() ? summaryMsg.getSurfaceInterval() : nil,
                descentTime: summaryMsg.isDescentTimeValid() ? summaryMsg.getDescentTime() : nil,
                ascentTime: summaryMsg.isAscentTimeValid() ? summaryMsg.getAscentTime() : nil,
                bottomTime: summaryMsg.isBottomTimeValid() ? UInt32(summaryMsg.getBottomTime()) : nil
            )
        }

        let settingsData: SettingsData? = setting.map { settingMsg in
            SettingsData(
                waterType: settingMsg.isWaterTypeValid() ? formatWaterType(settingMsg.getWaterType()) : nil,
                waterDensity: settingMsg.isWaterDensityValid() ? settingMsg.getWaterDensity() : nil,
                gfLow: settingMsg.isGfLowValid() ? settingMsg.getGfLow() : nil,
                gfHigh: settingMsg.isGfHighValid() ? settingMsg.getGfHigh() : nil,
                po2Warn: settingMsg.isPo2WarnValid() ? settingMsg.getPo2Warn() : nil,
                po2Critical: settingMsg.isPo2CriticalValid() ? settingMsg.getPo2Critical() : nil,
                safetyStopEnabled: settingMsg.isSafetyStopEnabledValid() ? settingMsg.getSafetyStopEnabled() == 1 : nil,
                bottomDepth: settingMsg.isBottomDepthValid() ? settingMsg.getBottomDepth() : nil
            )
        }

        let tankSummariesData = tankSummaries.map { summary in
            TankSummaryData(
                timestamp: summary.isTimestampValid() ? FITDate.date(from: summary.getTimestamp()) : nil,
                sensor: summary.isSensorValid() ? summary.getSensor() : nil,
                startPressure: summary.isStartPressureValid() ? summary.getStartPressure() : nil,
                endPressure: summary.isEndPressureValid() ? summary.getEndPressure() : nil,
                volumeUsed: summary.isVolumeUsedValid() ? summary.getVolumeUsed() : nil
            )
        }

        let tankUpdatesData = tankUpdates.map { update in
            TankUpdateData(
                timestamp: update.isTimestampValid() ? FITDate.date(from: update.getTimestamp()) : nil,
                sensor: update.isSensorValid() ? update.getSensor() : nil,
                pressure: update.isPressureValid() ? update.getPressure() : nil
            )
        }

        var lapsData = laps.map { lapMsg -> LapData in
            let divFactor = Double(Int32.max) / 180.0
            let startCoords = lapMsg.isStartPositionLatValid() && lapMsg.isStartPositionLongValid() ? 
                (Double(lapMsg.getStartPositionLat()) / divFactor,
                 Double(lapMsg.getStartPositionLong()) / divFactor) : nil
            let endCoords = lapMsg.isEndPositionLatValid() && lapMsg.isEndPositionLongValid() ? 
                (Double(lapMsg.getEndPositionLat()) / divFactor,
                 Double(lapMsg.getEndPositionLong()) / divFactor) : nil

            return LapData(
                timestamp: lapMsg.isTimestampValid() ? FITDate.date(from: lapMsg.getTimestamp()) : nil,
                startTime: lapMsg.isStartTimeValid() ? FITDate.date(from: lapMsg.getStartTime()) : nil,
                startCoordinates: startCoords,
                endCoordinates: endCoords,
                totalElapsedTime: lapMsg.isTotalElapsedTimeValid() ? lapMsg.getTotalElapsedTime() : nil,
                totalTimerTime: lapMsg.isTotalTimerTimeValid() ? lapMsg.getTotalTimerTime() : nil,
                totalDistance: lapMsg.isTotalDistanceValid() ? lapMsg.getTotalDistance() : nil,
                maxSpeed: lapMsg.isMaxSpeedValid() ? lapMsg.getMaxSpeed() : nil,
                avgSpeed: lapMsg.isAvgSpeedValid() ? lapMsg.getAvgSpeed() : nil,
                maxAltitude: lapMsg.isMaxAltitudeValid() ? lapMsg.getMaxAltitude() : nil,
                avgAltitude: lapMsg.isAvgAltitudeValid() ? lapMsg.getAvgAltitude() : nil,
                maxDepth: lapMsg.isMaxDepthValid() ? lapMsg.getMaxDepth() : nil,
                avgDepth: lapMsg.isAvgDepthValid() ? lapMsg.getAvgDepth() : nil
            )
        }

        // If no laps were found in the file, generate one from the session data
        if lapsData.isEmpty {
            var generatedStartCoords = startCoords 
            if generatedStartCoords == nil {
                if let firstRecordWithCoords = records.first(where: { $0.isPositionLatValid() && $0.isPositionLongValid() }) {
                    generatedStartCoords = (Double(firstRecordWithCoords.getPositionLat()) / divFactor,
                                            Double(firstRecordWithCoords.getPositionLong()) / divFactor)
                }
            }
            
            var generatedEndCoords = endCoords 
            if generatedEndCoords == nil {
                if let lastRecordWithCoords = records.last(where: { $0.isPositionLatValid() && $0.isPositionLongValid() }) {
                    generatedEndCoords = (Double(lastRecordWithCoords.getPositionLat()) / divFactor,
                                          Double(lastRecordWithCoords.getPositionLong()) / divFactor)
                }
            }

            let generatedLap = LapData(
                timestamp: session.isTimestampValid() ? FITDate.date(from: session.getTimestamp()) : nil, 
                startTime: session.isStartTimeValid() ? FITDate.date(from: session.getStartTime()) : nil,
                startCoordinates: generatedStartCoords, // Use potentially derived start coords
                endCoordinates: generatedEndCoords, // Use potentially derived end coords
                totalElapsedTime: session.isTotalElapsedTimeValid() ? session.getTotalElapsedTime() : nil,
                totalTimerTime: session.isTotalTimerTimeValid() ? session.getTotalTimerTime() : nil,
                totalDistance: session.isTotalDistanceValid() ? session.getTotalDistance() : nil,
                maxSpeed: session.isMaxSpeedValid() ? session.getMaxSpeed() : nil,
                avgSpeed: session.isAvgSpeedValid() ? session.getAvgSpeed() : nil,
                maxAltitude: session.isMaxAltitudeValid() ? session.getMaxAltitude() : nil,
                avgAltitude: session.isAvgAltitudeValid() ? session.getAvgAltitude() : nil,
                maxDepth: session.isMaxDepthValid() ? session.getMaxDepth() : nil,
                avgDepth: session.isAvgDepthValid() ? session.getAvgDepth() : nil
            )
            lapsData = [generatedLap]
        }

        let fileIdData: FileIdData? = fileIds.first.map { fileIdMsg in
            FileIdData(
                type: fileIdMsg.isTypeValid() ? formatFileType(fileIdMsg.getType()) : nil,
                manufacturer: fileIdMsg.isManufacturerValid() ? formatManufacturer(fileIdMsg.getManufacturer()) : nil,
                product: fileIdMsg.isProductValid() ? fileIdMsg.getProduct() : nil,
                serialNumber: fileIdMsg.isSerialNumberValid() ? fileIdMsg.getSerialNumber() : nil,
                timeCreated: fileIdMsg.isTimeCreatedValid() ? FITDate.date(from: fileIdMsg.getTimeCreated()) : nil
            )
        }

        let fitParser = FITParser(
            session: sessionData,
            summary: summaryData,
            settings: settingsData,
            tankSummaries: tankSummariesData,
            tankUpdates: tankUpdatesData,
            divePoints: records.map { record in
                DivePoint(
                    timestamp: record.isTimestampValid() ? FITDate.date(from: record.getTimestamp()) : nil,
                    depth: record.isDepthValid() ? record.getDepth() : nil,
                    temperature: record.isTemperatureValid() ? Float(record.getTemperature()) : nil,
                    heartRate: record.isHeartRateValid() ? record.getHeartRate() : nil,
                    n2Load: record.isN2LoadValid() ? record.getN2Load() : nil,
                    cnsLoad: record.isCnsLoadValid() ? record.getCnsLoad() : nil,
                    nextStopDepth: record.isNextStopDepthValid() ? record.getNextStopDepth() : nil,
                    nextStopTime: record.isNextStopTimeValid() ? record.getNextStopTime() : nil,
                    timeToSurface: record.isTimeToSurfaceValid() ? record.getTimeToSurface() : nil,
                    absolutePressure: record.isAbsolutePressureValid() ? record.getAbsolutePressure() : nil,
                    altitude: record.isAltitudeValid() ? record.getAltitude() : nil
                )
            },
            diveAlerts: events.compactMap { event in
                if event.isEventValid() && event.isEventTypeValid() {
                    let eventName = FITParser.formatEvent(event.getEvent())
                    let data = event.isDataValid() ? event.getData() : nil
                    return DiveAlert(
                        timestamp: event.isTimestampValid() ? FITDate.date(from: event.getTimestamp()) : nil,
                        event: eventName,
                        eventType: FITParser.formatEventType(event.getEventType()),
                        data: data,
                        interpretedData: data.map { FITParser.formatDiveAlertData(event.getEvent(), $0) }
                    )
                }
                return nil
            },
            diveGases: gases.map { gas in
                DiveGas(
                    messageIndex: gas.isMessageIndexValid() ? gas.getMessageIndex() : nil,
                    heliumContent: gas.isHeliumContentValid() ? gas.getHeliumContent() : nil,
                    oxygenContent: gas.isOxygenContentValid() ? gas.getOxygenContent() : nil,
                    status: gas.isStatusValid() ? FITParser.formatGasStatus(gas.getStatus()) : nil,
                    mode: gas.isModeValid() ? FITParser.formatGasMode(gas.getMode()) : nil
                )
            },
            deviceInfo: deviceInfo,
            laps: lapsData,
            fileId: fileIdData
        )
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
    
    static private func formatSport(_ sport: FITSport) -> String {
        switch sport {
        case FITSportDiving:
            return "Diving"
        default:
            return "Unknown Sport (\(sport))"
        }
    }
    
    static private func formatSubSport(_ subSport: FITSubSport) -> String {
        switch subSport {
        case FITSubSportSingleGasDiving:
            return "Single Gas Diving"
        case FITSubSportMultiGasDiving:
            return "Multi Gas Diving"
        case FITSubSportGaugeDiving:
            return "Gauge Diving"
        case FITSubSportApneaDiving:
            return "Apnea Diving"
        case FITSubSportOpenWater:
            return "Open Water"
        case 63:  // CCR (Closed Circuit Rebreather) diving - not defined in SDK
            return "CCR Diving"
        default:
            print("Unknown subsport raw value: \(subSport)")
            return "Unknown Sub Sport (\(subSport))"
        }
    }
    
    static private func formatEvent(_ event: FITEvent) -> String {
        switch event {
        case 0: return "Timer"
        case 3: return "Workout"
        case 4: return "Workout Step"
        case 5: return "Power Down"
        case 6: return "Power Up"
        case 7: return "Off Course"
        case 8: return "Session"
        case 9: return "Lap"
        case 10: return "Course Point"
        case 11: return "Battery"
        case 12: return "Virtual Partner Pace"
        case 13: return "HR High Alert"
        case 14: return "HR Low Alert"
        case 15: return "Speed High Alert"
        case 16: return "Speed Low Alert"
        case 17: return "Cadence High Alert"
        case 18: return "Cadence Low Alert"
        case 19: return "Power High Alert"
        case 20: return "Power Low Alert"
        case 21: return "Recovery HR"
        case 22: return "Battery Low"
        case 23: return "Time Duration Alert"
        case 24: return "Distance Duration Alert"
        case 25: return "Calorie Duration Alert"
        case 26: return "Activity"
        case 27: return "Fitness Equipment"
        case 28: return "Length"
        case 32: return "User Marker"
        case 33: return "Sport Point"
        case 36: return "Calibration"
        case 38: return "Dive Gas Switch"
        case 42: return "Front Gear Change"
        case 43: return "Rear Gear Change"
        case 44: return "Rider Position Change"
        case 45: return "Elevation High Alert"
        case 46: return "Elevation Low Alert"
        case 47: return "Comm Timeout"
        case 48: return "Dive Alert Warning"
        case 56: return "Dive Alert"
        default:
            return "Unknown Event (raw: \(event))"
        }
    }
    
    static private func formatEventType(_ eventType: FITEventType) -> String {
        switch eventType {
        case FITEventTypeStart:
            return "Start"
        case FITEventTypeStop:
            return "Stop"
        case FITEventTypeConsecutiveDepreciated:
            return "Consecutive (Deprecated)"
        case FITEventTypeMarker:
            return "Marker"
        case FITEventTypeStopAll:
            return "Stop All"
        case FITEventTypeStopDisable:
            return "Stop Disable"
        case FITEventTypeStopDisableAll:
            return "Stop Disable All"
        default:
            return "Unknown Event Type (\(eventType))"
        }
    }
    
    static private func formatGasStatus(_ status: FITDiveGasStatus) -> String {
        switch status {
        case FITDiveGasStatusDisabled:
            return "disabled"
        case FITDiveGasStatusEnabled:
            return "enabled"
        case FITDiveGasStatusBackupOnly:
            return "backup only"
        default:
            return "unknown"
        }
    }
    
    static private func formatGasMode(_ mode: FITDiveGasMode) -> String {
        switch mode {
        case FITDiveGasModeOpenCircuit:
            return "open circuit"
        case FITDiveGasModeClosedCircuitDiluent:
            return "closed circuit diluent"
        default:
            return "unknown"
        }
    }
    
    static private func formatDiveAlertData(_ event: FITEvent, _ data: UInt32) -> String {
        switch event {
        case 56:  // Dive Alert
            switch data {
            case 0: return "Surface"
            case 2: return "Safety Stop Violation"
            case 3: return "Deco Stop Violation"
            case 9: return "PO2 Warning"
            case 10: return "PO2 Critical"
            case 15: return "Tissue Loading Warning"
            case 19: return "Alert Cleared"
            case 23: return "Air Time Warning"
            case 24: return "Air Time Critical"
            case 25: return "Velocity Warning"
            default: return "Unknown Alert Data (\(data))"
            }
        case 38:  // Gas Switch
            return "Switch to Gas \(data)"
        case 48:  // Warning
            return "Warning Code \(data)"
        default:
            return "\(data)"
        }
    }
    
    static private func formatFileType(_ type: FITFile) -> String {
        switch type {
        case FITFileDevice: return "Device"
        case FITFileSettings: return "Settings"
        case FITFileSport: return "Sport"
        case FITFileActivity: return "Activity"
        case FITFileWorkout: return "Workout"
        case FITFileCourse: return "Course"
        case FITFileSchedules: return "Schedules"
        case FITFileWeight: return "Weight"
        case FITFileTotals: return "Totals"
        case FITFileGoals: return "Goals"
        case FITFileBloodPressure: return "Blood Pressure"
        case FITFileMonitoringA: return "Monitoring A"
        case FITFileActivitySummary: return "Activity Summary"
        case FITFileMonitoringDaily: return "Monitoring Daily"
        case FITFileMonitoringB: return "Monitoring B"
        case FITFileSegment: return "Segment"
        case FITFileSegmentList: return "Segment List"
        case FITFileExdConfiguration: return "Exd Configuration"
        case FITFileMfgRangeMin: return "Mfg Range Min (0xF7)"
        case FITFileMfgRangeMax: return "Mfg Range Max (0xFE)"
        default:
            return "Unknown File Type (\(type))"
        }
    }

    static private func formatManufacturer(_ manufacturer: FITManufacturer) -> String {
        switch manufacturer {
        case FITManufacturerGarmin: return "Garmin"
        case FITManufacturerGarminFr405Antfs: return "Garmin FR405 Antfs"
        case FITManufacturerZephyr: return "Zephyr"
        case FITManufacturerDayton: return "Dayton"
        case FITManufacturerIdt: return "IDT"
        case FITManufacturerSrm: return "SRM"
        case FITManufacturerQuarq: return "Quarq"
        case FITManufacturerIbike: return "iBike"
        case FITManufacturerSaris: return "Saris"
        case FITManufacturerSparkHk: return "Spark HK"
        case FITManufacturerTanita: return "Tanita"
        case FITManufacturerEchowell: return "Echowell"
        case FITManufacturerDynastreamOem: return "Dynastream OEM"
        case FITManufacturerNautilus: return "Nautilus"
        case FITManufacturerBontrager: return "Bontrager"
        case FITManufacturerTheHurtBox: return "The Hurt Box"
        case FITManufacturerCitizenSystems: return "Citizen Systems"
        case FITManufacturerMagellan: return "Magellan"
        case FITManufacturerOsynce: return "Osynce"
        case FITManufacturerHolux: return "Holux"
        case FITManufacturerConcept2: return "Concept2"
        case FITManufacturerShimano: return "Shimano"
        case FITManufacturerOneGiantLeap: return "One Giant Leap"
        case FITManufacturerAceSensor: return "Ace Sensor"
        case FITManufacturerBrimBrothers: return "Brim Brothers"
        case FITManufacturerXplova: return "Xplova"
        case FITManufacturerPerceptionDigital: return "Perception Digital"
        case FITManufacturerBf1systems: return "BF1 Systems"
        case FITManufacturerPioneer: return "Pioneer"
        case FITManufacturerSpantec: return "Spantec"
        case FITManufacturerMetalogics: return "Metalogics"
        case FITManufacturerSeikoEpson: return "Seiko Epson"
        case FITManufacturerSeikoEpsonOem: return "Seiko Epson OEM"
        case FITManufacturerIforPowell: return "Ifor Powell"
        case FITManufacturerMaxwellGuider: return "Maxwell Guider"
        case FITManufacturerStarTrac: return "Star Trac"
        case FITManufacturerBreakaway: return "Breakaway"
        case FITManufacturerAlatechTechnologyLtd: return "Alatech Technology Ltd"
        case FITManufacturerMioTechnologyEurope: return "Mio Technology Europe"
        case FITManufacturerRotor: return "Rotor"
        case FITManufacturerGeonaute: return "Geonaute"
        case FITManufacturerIdBike: return "IdBike"
        case FITManufacturerSpecialized: return "Specialized"
        case FITManufacturerWtek: return "Wtek"
        case FITManufacturerPhysicalEnterprises: return "Physical Enterprises"
        case FITManufacturerNorthPoleEngineering: return "North Pole Engineering"
        case FITManufacturerBkool: return "Bkool"
        case FITManufacturerCateye: return "Cateye"
        case FITManufacturerStagesCycling: return "Stages Cycling"
        case FITManufacturerSigmasport: return "SigmaSport"
        case FITManufacturerTomtom: return "TomTom"
        case FITManufacturerPeripedal: return "Peripedal"
        case FITManufacturerWattbike: return "Wattbike"
        case FITManufacturerMoxy: return "Moxy"
        case FITManufacturerCiclosport: return "Ciclosport"
        case FITManufacturerPowerbahn: return "Powerbahn"
        case FITManufacturerAcornProjectsAps: return "Acorn Projects ApS"
        case FITManufacturerLifebeam: return "Lifebeam"
        case FITManufacturerLezyne: return "Lezyne"
        case FITManufacturerSuunto: return "Suunto"
        case FITManufacturerDevelopment: return "Development"
        case FITManufacturerActigraphcorp: return "ActiGraphCorp"
        default:
            return "Unknown Manufacturer (\(manufacturer))"
        }
    }
    
    public static func formatDuration(_ seconds: UInt32) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, remainingSeconds)
    }
}