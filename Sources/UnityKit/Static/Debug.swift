import Foundation

/// Provides logging functionality for debugging and diagnostic purposes.
///
/// The `Debug` enum offers static methods to log messages at different severity levels with
/// optional timestamps and source code location information. Configure which log levels are
/// active using ``set(enable:)`` with ``LogStyle`` options.
///
/// ## Overview
///
/// Debug logging is disabled by default. Enable specific log levels or all logging to see output.
/// Each log style includes visual indicators (emojis) and formatting to help distinguish log types.
///
/// ## Topics
///
/// ### Configuration
/// - ``set(enable:)``
/// - ``LogStyle``
///
/// ### Logging Methods
/// - ``debug(_:displayTime:_:_:_:_:)``
/// - ``info(_:displayTime:_:_:_:_:)``
/// - ``warning(_:displayTime:_:_:_:_:)``
/// - ``error(_:displayTime:_:_:_:_:)``
/// - ``log(_:style:displayTime:_:_:_:_:)``
///
/// ## Example Usage
///
/// ```swift
/// // Enable all logging
/// Debug.set(enable: .all)
///
/// // Enable specific log levels
/// Debug.set(enable: [.warning, .error])
///
/// // Log messages at different levels
/// Debug.debug("Player position updated")
/// Debug.info("Level loaded successfully")
/// Debug.warning("Low memory warning")
/// Debug.error("Failed to load asset")
///
/// // Log with timestamp
/// Debug.info("Server connected", displayTime: true)
///
/// // Disable all logging
/// Debug.set(enable: .none)
/// ```
public enum Debug {
    /// Defines the severity level and formatting style for debug log messages.
    ///
    /// Use this option set to configure which log levels should be displayed. Multiple styles
    /// can be combined to enable several log levels simultaneously.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Enable only warnings and errors
    /// Debug.set(enable: [.warning, .error])
    ///
    /// // Enable all log levels
    /// Debug.set(enable: .all)
    ///
    /// // Disable all logging
    /// Debug.set(enable: .none)
    /// ```
    public struct LogStyle: OptionSet {
        public let rawValue: Int

        /// Creates a log style with the specified raw value.
        ///
        /// - Parameter rawValue: The raw integer value representing the log style.
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        /// Debug level messages for detailed diagnostic information.
        ///
        /// Displayed with 💬 DEBUG: prefix.
        public static let debug = LogStyle(rawValue: 1 << 0)

        /// Informational messages about normal operations.
        ///
        /// Displayed with ℹ️ INFO: prefix.
        public static let info = LogStyle(rawValue: 1 << 1)

        /// Warning messages for potentially problematic situations.
        ///
        /// Displayed with ⚠️ WARNING: prefix along with file, line, column, and function information.
        public static let warning = LogStyle(rawValue: 1 << 2)

        /// Error messages for serious problems.
        ///
        /// Displayed with ‼️ ERROR: prefix along with file, line, column, and function information.
        public static let error = LogStyle(rawValue: 1 << 3)

        /// Disables all logging.
        public static let none = LogStyle(rawValue: 1 << 4)

        /// All log levels enabled (debug, info, warning, and error).
        public static var all: LogStyle = [.debug, .info, .warning, .error]

        /// The prefix string displayed before log messages for this style.
        ///
        /// Returns an emoji and label appropriate for the log level.
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

    private static var enabled: LogStyle = .none

    /// Configures which log levels should be displayed.
    ///
    /// Use this method to enable or disable specific log levels. By default, all logging is disabled.
    ///
    /// - Parameter enable: The ``LogStyle`` options indicating which log levels to enable.
    ///   Use ``.all`` to enable all levels, ``.none`` to disable all logging, or combine specific
    ///   levels like ``[.warning, .error]``.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Enable all logging during development
    /// Debug.set(enable: .all)
    ///
    /// // Production: only show warnings and errors
    /// Debug.set(enable: [.warning, .error])
    ///
    /// // Disable all logging
    /// Debug.set(enable: .none)
    /// ```
    public static func set(enable: LogStyle) {
        self.enabled = enable.contains(.none) ? .none : enable
    }

    /// Logs a warning message with source location information.
    ///
    /// Warning messages are displayed with a ⚠️ WARNING: prefix along with the source file,
    /// line number, column, and function name where the warning was triggered.
    ///
    /// - Parameters:
    ///   - message: The warning message to log.
    ///   - displayTime: If `true`, includes a timestamp in the output. Default is `false`.
    ///   - filepath: The source file path (automatically provided).
    ///   - function: The function name (automatically provided).
    ///   - line: The line number (automatically provided).
    ///   - column: The column number (automatically provided).
    ///
    /// ## Example
    ///
    /// ```swift
    /// Debug.warning("Memory usage is high")
    /// // Output: ⚠️ WARNING: [MyFile.swift line:42 col:5 func:update()] -> Memory usage is high
    /// ```
    public static func warning(
        _ message: String,
        displayTime: Bool = false,
        _ filepath: String = #file,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) {
        self.log(message, style: .warning, displayTime: displayTime, filepath, function, line, column)
    }

    /// Logs an error message with source location information.
    ///
    /// Error messages are displayed with a ‼️ ERROR: prefix along with the source file,
    /// line number, column, and function name where the error occurred.
    ///
    /// - Parameters:
    ///   - message: The error message to log.
    ///   - displayTime: If `true`, includes a timestamp in the output. Default is `false`.
    ///   - filepath: The source file path (automatically provided).
    ///   - function: The function name (automatically provided).
    ///   - line: The line number (automatically provided).
    ///   - column: The column number (automatically provided).
    ///
    /// ## Example
    ///
    /// ```swift
    /// Debug.error("Failed to load configuration file")
    /// // Output: ‼️ ERROR: [MyFile.swift line:15 col:9 func:loadConfig()] -> Failed to load configuration file
    /// ```
    public static func error(
        _ message: String,
        displayTime: Bool = false,
        _ filepath: String = #file,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) {
        self.log(message, style: .error, displayTime: displayTime, filepath, function, line, column)
    }

    /// Logs a debug message for detailed diagnostic information.
    ///
    /// Debug messages are displayed with a 💬 DEBUG: prefix and are useful for tracking
    /// detailed execution flow during development.
    ///
    /// - Parameters:
    ///   - message: The debug message to log.
    ///   - displayTime: If `true`, includes a timestamp in the output. Default is `false`.
    ///   - filepath: The source file path (automatically provided).
    ///   - function: The function name (automatically provided).
    ///   - line: The line number (automatically provided).
    ///   - column: The column number (automatically provided).
    ///
    /// ## Example
    ///
    /// ```swift
    /// Debug.debug("Player position: \(position)")
    /// // Output: 💬 DEBUG: Player position: Vector2(x: 10, y: 20)
    /// ```
    public static func debug(
        _ message: String,
        displayTime: Bool = false,
        _ filepath: String = #file,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) {
        self.log(message, style: .debug, displayTime: displayTime, filepath, function, line, column)
    }

    /// Logs an informational message about normal operations.
    ///
    /// Info messages are displayed with a ℹ️ INFO: prefix and are useful for tracking
    /// important events and state changes.
    ///
    /// - Parameters:
    ///   - message: The informational message to log.
    ///   - displayTime: If `true`, includes a timestamp in the output. Default is `false`.
    ///   - filepath: The source file path (automatically provided).
    ///   - function: The function name (automatically provided).
    ///   - line: The line number (automatically provided).
    ///   - column: The column number (automatically provided).
    ///
    /// ## Example
    ///
    /// ```swift
    /// Debug.info("Game level loaded successfully")
    /// // Output: ℹ️ INFO: Game level loaded successfully
    ///
    /// Debug.info("Connection established", displayTime: true)
    /// // Output: 14:30:25.123 ℹ️ INFO: Connection established
    /// ```
    public static func info(
        _ message: String,
        displayTime: Bool = false,
        _ filepath: String = #file,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) {
        self.log(message, style: .info, displayTime: displayTime, filepath, function, line, column)
    }

    /// Logs a message with a specified log style.
    ///
    /// This is the general-purpose logging method that all other log methods call internally.
    /// Use the specialized methods (``debug(_:displayTime:_:_:_:_:)``, ``info(_:displayTime:_:_:_:_:)``,
    /// ``warning(_:displayTime:_:_:_:_:)``, ``error(_:displayTime:_:_:_:_:)``) for convenience.
    ///
    /// - Parameters:
    ///   - message: The message to log.
    ///   - style: The ``LogStyle`` to use for this message. Default is ``.debug``.
    ///   - displayTime: If `true`, includes a timestamp in the output. Default is `false`.
    ///   - filepath: The source file path (automatically provided).
    ///   - function: The function name (automatically provided).
    ///   - line: The line number (automatically provided).
    ///   - column: The column number (automatically provided).
    ///
    /// ## Example
    ///
    /// ```swift
    /// Debug.log("Custom log message", style: .info, displayTime: true)
    /// ```
    public static func log(
        _ message: String,
        style: LogStyle = .debug,
        displayTime: Bool = false,
        _ filepath: String = #file,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) {
        guard !self.enabled.contains(.none)
        else { return }

        let time = displayTime ? Debug.dateFormatter.string(from: Date()) + " " : ""

        switch style {
        case .debug:
            print(time + style.prefix + message)
        case .info:
            print(time + style.prefix + message)
        case .warning:
            let filename = URL(fileURLWithPath: filepath).lastPathComponent
            print(time + style.prefix + "[\(filename) line:\(line) col:\(column) func:\(function)] -> " + message)
        case .error:
            let filename = URL(fileURLWithPath: filepath).lastPathComponent
            print(time + style.prefix + "[\(filename) line:\(line) col:\(column) func:\(function)] -> " + message)
        default:
            break
        }
    }

    /// Logs multiple items as a warning message with source location information.
    ///
    /// This variadic version allows logging multiple values in a single call.
    ///
    /// - Parameters:
    ///   - items: The items to log (variadic parameter).
    ///   - displayTime: If `true`, includes a timestamp in the output. Default is `false`.
    ///   - filepath: The source file path (automatically provided).
    ///   - function: The function name (automatically provided).
    ///   - line: The line number (automatically provided).
    ///   - column: The column number (automatically provided).
    ///
    /// ## Example
    ///
    /// ```swift
    /// Debug.warning(items: "Player health:", health, "is low")
    /// ```
    public static func warning(
        items: Any...,
        displayTime: Bool = false,
        _ filepath: String = #file,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) {
        self.log(items: items, style: .warning, displayTime: displayTime, filepath, function, line, column)
    }

    /// Logs multiple items as an error message with source location information.
    ///
    /// This variadic version allows logging multiple values in a single call.
    ///
    /// - Parameters:
    ///   - items: The items to log (variadic parameter).
    ///   - displayTime: If `true`, includes a timestamp in the output. Default is `false`.
    ///   - filepath: The source file path (automatically provided).
    ///   - function: The function name (automatically provided).
    ///   - line: The line number (automatically provided).
    ///   - column: The column number (automatically provided).
    ///
    /// ## Example
    ///
    /// ```swift
    /// Debug.error(items: "Failed to load asset:", assetName, "with error:", error)
    /// ```
    public static func error(
        items: Any...,
        displayTime: Bool = false,
        _ filepath: String = #file,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) {
        self.log(items: items, style: .error, displayTime: displayTime, filepath, function, line, column)
    }

    /// Logs multiple items as an informational message.
    ///
    /// This variadic version allows logging multiple values in a single call.
    ///
    /// - Parameters:
    ///   - items: The items to log (variadic parameter).
    ///   - displayTime: If `true`, includes a timestamp in the output. Default is `false`.
    ///   - filepath: The source file path (automatically provided).
    ///   - function: The function name (automatically provided).
    ///   - line: The line number (automatically provided).
    ///   - column: The column number (automatically provided).
    ///
    /// ## Example
    ///
    /// ```swift
    /// Debug.info(items: "Loaded", count, "assets in", duration, "seconds")
    /// ```
    public static func info(
        items: Any...,
        displayTime: Bool = false,
        _ filepath: String = #file,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) {
        self.log(items: items, style: .info, displayTime: displayTime, filepath, function, line, column)
    }

    /// Logs multiple items with a specified log style.
    ///
    /// This variadic version of the general-purpose logging method allows logging multiple values.
    ///
    /// - Parameters:
    ///   - items: The items to log (variadic parameter).
    ///   - style: The ``LogStyle`` to use for this message. Default is ``.debug``.
    ///   - displayTime: If `true`, includes a timestamp in the output. Default is `false`.
    ///   - filepath: The source file path (automatically provided).
    ///   - function: The function name (automatically provided).
    ///   - line: The line number (automatically provided).
    ///   - column: The column number (automatically provided).
    ///
    /// ## Example
    ///
    /// ```swift
    /// Debug.log(items: "Value:", value, "Status:", status, style: .debug)
    /// ```
    public static func log(
        items: Any...,
        style: LogStyle = .debug,
        displayTime: Bool = false,
        _ filepath: String = #file,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) {
        guard !self.enabled.contains(.none)
        else { return }

        let time = displayTime ? Debug.dateFormatter.string(from: Date()) + " " : ""

        switch style {
        case .debug:
            print(time + style.prefix, items)
        case .info:
            print(time + style.prefix, items)
        case .warning:
            let filename = URL(fileURLWithPath: filepath).lastPathComponent
            print(time + style.prefix + "[\(filename) line:\(line) col:\(column) func:\(function)] -> ", items)
        case .error:
            let filename = URL(fileURLWithPath: filepath).lastPathComponent
            print(time + style.prefix + "[\(filename) line:\(line) col:\(column) func:\(function)] -> ", items)
        default:
            break
        }
    }
}
