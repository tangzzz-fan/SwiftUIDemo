import Foundation
import os.log

enum Logger {
    static let subsystem = Bundle.main.bundleIdentifier!
    static let ui = OSLog(subsystem: subsystem, category: "UI")
    static let network = OSLog(subsystem: subsystem, category: "Network")
    static let data = OSLog(subsystem: subsystem, category: "Data")

    static func debug(_ message: String, log: OSLog = ui) {
        #if DEBUG
            os_log(.debug, log: log, "%{public}@", message)
        #endif
    }

    static func info(_ message: String, log: OSLog = ui) {
        os_log(.info, log: log, "%{public}@", message)
    }

    static func error(_ message: String, log: OSLog = ui) {
        os_log(.error, log: log, "%{public}@", message)
    }
}
