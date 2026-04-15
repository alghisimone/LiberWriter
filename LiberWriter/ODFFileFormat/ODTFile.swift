//
//  ODTFile.swift
//  LiberWriter
//
//  Created by Simone Alghisi on 02/03/2025.
//

import Foundation
import ZIPFoundation

struct ODTFile {
    var contentXML: String
    var stylesXML: String
    var metaXML: String
    var settingsXML: String?
    var resources: [String: Data]
    var fileURL: URL
    
    init(fileURL: URL) throws {
        self.fileURL = fileURL
        self.resources = [:]
        
        guard let archive = Archive(url: fileURL, accessMode: .read) else {
            throw NSError(domain: "ODTFile", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to read ODT file"])
        }
        
        self.contentXML = try ODTFile.extractXML(from: archive, path: "content.xml")
        self.stylesXML = try ODTFile.extractXML(from: archive, path: "styles.xml")
        self.metaXML = try ODTFile.extractXML(from: archive, path: "meta.xml")
        self.settingsXML = try? ODTFile.extractXML(from: archive, path: "settings.xml")
        
        for entry in archive {
            if entry.path.hasPrefix("Pictures/") {
                self.resources[entry.path] = try ODTFile.extractData(from: archive, path: entry.path)
            }
        }
    }
    
    private static func extractXML(from archive: Archive, path: String) throws -> String {
        guard let entry = archive[path] else {
            throw NSError(domain: "ODTFile", code: 2, userInfo: [NSLocalizedDescriptionKey: "Missing \(path)"])
        }
        var data = Data()
        _ = try archive.extract(entry, consumer: { data.append($0) })
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    private static func extractData(from archive: Archive, path: String) throws -> Data {
        guard let entry = archive[path] else {
            throw NSError(domain: "ODTFile", code: 3, userInfo: [NSLocalizedDescriptionKey: "Missing \(path)"])
        }
        var data = Data()
        _ = try archive.extract(entry, consumer: { data.append($0) })
        return data
    }
}
