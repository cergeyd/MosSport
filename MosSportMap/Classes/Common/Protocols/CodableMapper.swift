//
//  UserStoriesFactory.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import Foundation

class CodableMapper<T: Codable> {

    func map(JSONObject: [String: Any]) throws -> T {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: JSONObject, options: .prettyPrinted) else {
            throw ThrowErrors.serialization
        }
        return try self.map(data: jsonData)
    }

    func map(data: Data) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
        return try decoder.decode(T.self, from: data)
    }

    func map(JSONString: String) throws -> T {
        guard let jsonData = JSONString.data(using: String.Encoding.utf8, allowLossyConversion: true) else {
            throw ThrowErrors.stringToData
        }
        return try self.map(data: jsonData)
    }
}

protocol CodableMappable: Codable {
    func demap() -> [String: Any]?
}

extension CodableMappable {

    func demap() -> [String: Any]? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(DateFormatter.iso8601Full)
        guard let data = try? encoder.encode(self) else {
            return nil
        }
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            return nil
        }
    }
}

extension CodableMapper {

    func map(JSONObject: [[String: Any]]) throws -> Array<T> {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: JSONObject, options: .prettyPrinted) else {
            throw ThrowErrors.serialization
        }
        return try self.map(data: jsonData)
    }

    func map(data: Data) throws -> Array<T> {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
        return try decoder.decode(Array<T>.self, from: data)
    }
}

private extension DateFormatter {

    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}
