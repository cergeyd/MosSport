//
//  StorageManager.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import Foundation

class StorageManager {

    private let fileManager: FileManager

    init(fileManager: FileManager) {
        self.fileManager = fileManager
    }

    enum Directory {
        // Only documents and other data that is user-generated, or that cannot otherwise be recreated by your application, should be stored in the <Application_Home>/Documents directory and will be automatically backed up by iCloud.
        case documents
        // Data that can be downloaded again or regenerated should be stored in the <Application_Home>/Library/Caches directory. Examples of files you should put in the Caches directory include database cache files and downloadable content, such as that used by magazine, newspaper, and map applications.
        case caches
    }

    private func getURL(for directory: Directory) -> URL {
        var searchPathDirectory: FileManager.SearchPathDirectory

        switch directory {
        case .documents:
            searchPathDirectory = .documentDirectory
        case .caches:
            searchPathDirectory = .cachesDirectory
        }

        if let url = self.fileManager.urls(for: searchPathDirectory, in: .userDomainMask).first {
            return url
        } else {
            fatalError("Could not create URL for specified directory!")
        }
    }

    func store<T: Encodable>(_ object: T, to directory: Directory, as fileName: String) {
        let url = self.getURL(for: directory).appendingPathComponent(fileName, isDirectory: false)

        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            if self.fileManager.fileExists(atPath: url.path) {
                try self.fileManager.removeItem(at: url)
            }
            self.fileManager.createFile(atPath: url.path, contents: data, attributes: nil)
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func retrieve<T: Decodable>(_ fileName: String, from directory: Directory, as type: T.Type) -> T {
        let path = self.pathFor(recource: fileName, from: directory)
        if let data = self.fileManager.contents(atPath: path) {
            let decoder = JSONDecoder()
            do {
                let model = try decoder.decode(type, from: data)
                return model
            } catch {
                fatalError(error.localizedDescription)
            }
        } else {
            fatalError("No data at \(path)!")
        }
    }

    private func pathFor(recource: String, fileType: String = "json", from directory: Directory) -> String {
        let url = self.getURL(for: directory).appendingPathComponent(recource, isDirectory: false)
        if !self.fileManager.fileExists(atPath: url.path) {
            guard let path = Bundle.main.path(forResource: recource, ofType: fileType) else {
                fatalError("\(recource) does not exist!")
            }
            return path
        }
        return url.path
    }

    func clear(_ directory: Directory) {
        let url = self.getURL(for: directory)
        do {
            let contents = try self.fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
            for fileUrl in contents {
                try self.fileManager.removeItem(at: fileUrl)
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func remove(_ fileName: String, from directory: Directory) {
        let url = self.getURL(for: directory).appendingPathComponent(fileName, isDirectory: false)
        if self.fileManager.fileExists(atPath: url.path) {
            do {
                try self.fileManager.removeItem(at: url)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }

    func fileExists(_ fileName: String, in directory: Directory) -> Bool {
        let url = self.getURL(for: directory).appendingPathComponent(fileName, isDirectory: false)
        return self.fileManager.fileExists(atPath: url.path)
    }
}
