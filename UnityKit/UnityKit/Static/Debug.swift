
import Foundation

public final class Debug {

    public struct LogStyle: OptionSet {

        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static let debug = LogStyle(rawValue: 1 << 0)
        public static let info = LogStyle(rawValue: 1 << 1)
        public static let warning = LogStyle(rawValue: 1 << 2)
        public static let error = LogStyle(rawValue: 1 << 3)
        public static let none = LogStyle(rawValue: 1 << 4)

        public static var all: LogStyle = [.debug, .info, .warning, .error]

        public var prefix: String {

            if self.contains(.debug) {
                return "💬" + " DEBUG: "
            } else if self.contains(.info) {
                return "ℹ️" + " INFO: "
            } else if self.contains(.warning) {
                return "⚠️" + " WARNING: "
            } else if self.contains(.error) {
                return "‼️" + " ERROR: "
            }
            return ""
        }
    }

    private static var dateFormat = "HH:mm:ss.SSS"
    fileprivate static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }

    private static var enabled: LogStyle = .all

    public static func set(enable: LogStyle) {
        self.enabled = enable.contains(.none) ? .none : enable
    }

    public static func log(_ items: Any...,
        style: LogStyle = .debug,
        displayTime: Bool = false,
        _ filepath: String = #file,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column) {

        guard !enabled.contains(.none)
            else { return }

        let time = displayTime ? Debug.dateFormatter.string(from: Date()) + " " : ""

        switch style {
        case .debug:
            print(time + style.prefix + items.debugDescription)
        case .info:
            print(time + style.prefix + items.description)
        case .warning:
            print(time + style.prefix + items.description)
        case .error:
            let filename = URL(fileURLWithPath: filepath).lastPathComponent
            print(time + style.prefix + "[\(filename) line:\(line) col:\(column) func:\(function)] -> " + items.description)
        default:
            break
        }
    }
}
