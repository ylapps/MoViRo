//
//  Logger.swift
//  Moviro
//
//  Created by Yevhenii Lytvynenko on 14.09.2025.
//

import Foundation
import os.log

public enum MoviroLogger {
    
    public enum LogLevel: Int, CaseIterable {
        case debug = 0
        case info = 1
        case warning = 2
        case error = 3
        case none = 4
        
        var emoji: String {
            switch self {
            case .debug: return "🐛"
            case .info: return "ℹ️"
            case .warning: return "⚠️"
            case .error: return "❌"
            case .none: return ""
            }
        }
    }
    
    public enum Category: String, CaseIterable {
        case model = "MODEL"
        case router = "ROUTER"
        case view = "VIEW"
        
        var emoji: String {
            switch self {
            case .model: return "🧩"
            case .router: return "🧭"
            case .view: return "👁️"
            }
        }
    }
    
    public static var logLevel: LogLevel = .info
    public static var isEnabled: Bool = true
    
    private static let logger = OSLog(subsystem: "com.moviro.framework", category: "general")
    
    public static func log(_ level: LogLevel, category: Category, message: String, type: Any.Type? = nil) {
        guard isEnabled, level.rawValue >= logLevel.rawValue else { return }
        
        let typeString = type.map { " \($0)" } ?? ""
        let logMessage = "\(category.emoji) [\(category.rawValue)]\(typeString) \(message)"
        
        if #available(iOS 14.0, *) {
            let osLogType: OSLogType = switch level {
            case .debug: .debug
            case .info: .info
            case .warning: .error
            case .error: .fault
            case .none: .default
            }
            os_log("%{public}@", log: logger, type: osLogType, logMessage)
        } else {
            print(logMessage)
        }
    }
    
    // Convenience methods
    public static func debug(_ message: String, category: Category = .router, type: Any.Type? = nil) {
        log(.debug, category: category, message: message, type: type)
    }
    
    public static func info(_ message: String, category: Category = .router, type: Any.Type? = nil) {
        log(.info, category: category, message: message, type: type)
    }
    
    public static func warning(_ message: String, category: Category = .router, type: Any.Type? = nil) {
        log(.warning, category: category, message: message, type: type)
    }
    
    public static func error(_ message: String, category: Category = .router, type: Any.Type? = nil) {
        log(.error, category: category, message: message, type: type)
    }
}

// MARK: - Lifecycle Logging Extensions

public extension MoviroLogger {
    
    static func logInit<T>(_ type: T.Type, category: Category) {
        debug("init", category: category, type: type)
    }
    
    static func logDeinit<T>(_ type: T.Type, category: Category) {
        debug("deinit", category: category, type: type)
    }
    
    static func logAppear<T>(_ type: T.Type, category: Category = .model) {
        debug("appear", category: category, type: type)
    }
    
    static func logDisappear<T>(_ type: T.Type, category: Category = .model) {
        debug("disappear", category: category, type: type)
    }
}