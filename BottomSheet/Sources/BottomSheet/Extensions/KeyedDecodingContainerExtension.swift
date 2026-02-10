//
//  KeyedDecodingContainerExtension.swift
//  NetworkingLayer
//
//  Created by 이현재 on 2025/08/15.
//  Copyright © 2025 WAUG. All rights reserved.
//

import Foundation

public extension KeyedDecodingContainer {
    func decodeInt(forKey key: K) -> Int {
        if let intValue = try? decode(Int.self, forKey: key) {
            return intValue
        } else if let string = try? decode(String.self, forKey: key) {
            return Int(string) ?? 0
        }
        return 0
    }

    func decodeDouble(forKey key: K) -> Double {
        if let doubleValue = try? decode(Double.self, forKey: key) {
            return doubleValue
        } else if let string = try? decode(String.self, forKey: key) {
            return Double(string) ?? 0.0
        }
        return 0.0
    }

    func decodeBool(forKey key: K) -> Bool {
        if let intValue = try? decode(Int.self, forKey: key) {
            return intValue != 0
        } else if let string = try? decode(String.self, forKey: key) {
            if let intValue = Int(string) {
                return intValue != 0
            }
            let newString = string.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            return Bool(newString) ?? false
        } else if let boolValue = try? decode(Bool.self, forKey: key) {
            return boolValue
        }
        return false
    }

    func decodeString(forKey key: K) -> String {
        (try? decode(String.self, forKey: key)) ?? ""
    }

    func decodeOptionalString(forKey key: K) -> String? {
        try? decode(String.self, forKey: key)
    }

    func decodeOrNil<T>(_ type: T.Type, forKey key: Self.Key) -> T? where T: Decodable {
        try? decode(type, forKey: key)
    }
}
