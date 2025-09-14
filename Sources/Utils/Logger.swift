// Logger.swift
// Utility for conditional debug logging

import Foundation

@inline(__always)
func debugLog(_ message: @autoclosure () -> String) {
#if DEBUG
    print(message())
#endif
}