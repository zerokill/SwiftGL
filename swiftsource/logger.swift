import Foundation

enum LogLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
}

struct Logger {
    static var isEnabled = true
    static var logLevel: LogLevel = .debug

    static func log(_ items: Any..., level: LogLevel = .debug) {
        guard isEnabled else { return }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"

        let dateString = dateFormatter.string(from: Date())

        // Combine all items into a single string
        let message = items.map { "\($0)" }.joined(separator: " ")

        print("\(dateString) [\(level.rawValue)] - \(message)")
    }

    static func debug(_ items: Any...) {
        log(items, level: .debug)
    }

    static func info(_ items: Any...) {
        log(items, level: .info)
    }

    static func warning(_ items: Any...) {
        log(items, level: .warning)
    }

    static func error(_ items: Any...) {
        log(items, level: .error)
    }
}

