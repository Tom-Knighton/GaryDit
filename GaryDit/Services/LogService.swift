//
//  LogService.swift
//  GaryDit
//
//  Created by Tom Knighton on 01/07/2023.
//

import Foundation
import OSLog

typealias Logger = os.Logger

enum LogLevel {
    case debug
    case info
    case warn
    case error
    
    var osLevel: OSLogType {
        switch self {
        case .debug:
            return .debug
        case .info:
            return .info
        case .warn:
            return .error
        case .error:
            return .fault
        }
    }
}

extension Logger {
    
    init(category: String? = nil) {
        self.init(subsystem: "online.tomk.GaryDit", category: category ?? "GaryDit")
    }
}

