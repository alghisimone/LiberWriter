//
//  ODTDocument.swift
//  LiberWriter
//
//  Created by Simone Alghisi on 09/03/23.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers
import XMLCoder
import ZIPFoundation

extension UTType {
    static var openDocumentText: UTType {
        UTType(exportedAs: "org.oasis-open.opendocument.text")
    }
}

class DocumentData: ObservableObject {
    @Published var fileURL: URL?
    @Published var metaXML: URL?
    @Published var contentXML: URL?
    @Published var settingsXML: URL?
}

class DocumentContents: ObservableObject {
    @Published var content: String?
    @Published var styles: String?
    @Published var meta: String?
    @Published var settings: String?
    @Published var manifest: String?
    @Published var resources: Data?
}

class ODTManifest: ObservableObject {
    @Published var manifestManifest: String?
    @Published var manifestFileEntry: FileEntry?
    @Published var contentFile: URL?
    @Published var stylesFile: URL?
    @Published var elementsOfFile: URL?
    @Published var filePrefix: URL?
    @Published var fileSuffix: URL?
}

class FileEntry {
    var manifestFileEntryFullPath: String?
    var manifestFileEntryMediaType: String?
    var manifestFileEntryPreferredViewMode: String?
    var manifestFileEntrySize: Int?
    var manifestFileEntryVersion: String?
    var manifestEncryptionData: ODTEncryption?
}

class ODTEncryption {
    var manifestChecksum: (any BinaryInteger)?
    var manifestChecksumType: String?
    var manifestEncryptionAlgorythm: String?
    var manifestKeyDerivation: String?
    var manifestStartKeyGeneration: String?
}

class ODTMetadata: Codable {
    var metadataODTGenerator: String?
    var metadataODTTitle: String?
    var metadataODTDescription: String?
    var metadataODTSubject: String?
    var metadataODTKeyword: String?
    var metadataODTInitialCreator: String?
    var metadataODTCreator: String?
    var metadataODTPrintedBy: String?
    var metadataODTCreationDate: Date?
    var metadataODTDate: Date?
    var metadataODTPrintDate: Date?
    var metadataODTTemplate: String?
    var metadataODTAutoReload: Bool?
    var hyperlinkBehaviour: HyperlinkBehaviour
    var metadataODTLanguage: String?
    var metadataODTEditingCycles: Int?
    var metadataODTEditingDuration: Int?
    var metadataODTDocumentStatistics: ODTDocumentStatistics
    var metadataODTUserDefined: ODTMetadataUserDefined

    class ODTMetadataUserDefined: Codable {
        var metadataODTCustomName: String?
        var metadataODTCustomValue: String?
        var metadataODTCustomKind: String?
    }

    class ODTDocumentStatistics: Codable {
        var metadataStatsCellCount: Int
        var metadataStatsCharacterCount: Int
        var metadataStatsDrawCount: Int
        var metadataStatsFrameCount: Int
        var metadataStatsImageCount: Int
        var metadataStatsNonWhiteCharCount: Int
        var metadataStatsObjectCount: Int
        var metadataStatsOLECount: Int
        var metadataStatsPageCount: Int
        var metadataStatsParagraphCount: Int
        var metadataStatsRowCount: Int
        var metadataStatsSentenceCount: Int
        var metadataStatsSyllableCount: Int
        var metadataStatsTableCount: Int
        var metadataStatsWordCount: Int
    }

    class HyperlinkBehaviour: Codable {
        var metadataHLBehaviourTargetFrameName: String?
        var metadataHLBehaviourXLinkShow: String?
    }

}


struct ODTDocument: FileDocument, Codable {
    static var readableContentTypes: [UTType] { [.openDocumentText] }
    static var writableContentTypes: [UTType] { [.openDocumentText] }
    
    var metadata: ODTMetadata
    //var content: ODTContent
    //var style: ODTStyle
    //var settings: ODTSettings
    var manifest: ODTManifest
    //var resources: ODTResources
    
    var decoder = XMLDecoder()
    
    init(from decoder: XMLDecoder) throws {
        
        //General settings for the decoder
        
        decoder.shouldProcessNamespaces = true
        decoder.dateDecodingStrategy = .secondsSince1970
        
        enum ManifestODTCodingKeys: String, CodingKey {
            case contentFile = "odf:ContentFile"
            case stylesFile = "odf:StylesFile"
            case fileElement = "odf:Element"
            case filePrefix = "odf:prefix"
            case fileSuffix = "odf:suffix"
        }
        
        //Decode MANIFEST
        
        //MANIFEST Coding Keys
        
        
        //Actual decodification of MANIFEST
        
        decoder.keyDecodingStrategy = .custom{ keys in
            guard let lastKey = manifestODTCodingKeys.last else { return MetadataODTCodingKeys(stringValue: "")! }
            guard let odtMetadataKey = manifestODTCoingKeys.first(where: { $0.stringValue == lastKey.stringValue }) else {
                return lastKey
            }
            return odtMetadataKey
        }
        
        manifest = try decoder.decode(ODTMetadata.self, from: Data(contentsOf: DocumentData().metaXML!))
        
        print("")
        print("Loading new document")
        print("")
        
        //Decode METADATA
        
        //METADATA Coding Keys
              
        enum MetadataODTCodingKeys: String, CodingKey {
            case metadataODTGenerator = "meta:generator"
            case metadataODTTitle = "dc:title"
            case metadataODTDescription = "dc:description"
            case metadataODTSubject = "dc:subject"
            case metadataODTKeyword = "dc:keyword"
            case metadataODTInitialCreator = "meta:initial-creator"
            case metadataODTCreator = "dc:creator"
            case metadataODTPrintedBy = "meta:printed-by"
            case metadataODTCreationDate = "meta:creation-date"
            case metadataODTDate = "dc:date"
            case metadataODTPrintDate = "meta:print-date"
            case metadataODTTemplate = "meta:template"
            case metadataODTAutoReload = "meta:auto-reload"
            case metadataHLBehaviourTargetFrameName = "office:target-frame-name"
            case metadataHLBehaviourXLinkShow = "xlink:show"
            case metadataODTLanguage = "dc:language"
            case metadataODTEditingCycles = "meta:editing-cycles"
            case metadataODTEditingDuration = "meta:editing-duration"
            case metadataStatsCellCount = "meta:cell-count"
            case metadataStatsCharacterCount = "meta:character-count"
            case metadataStatsDrawCount = "meta:draw-count"
            case metadataStatsFrameCount = "meta:frame-count"
            case metadataStatsImageCount = "meta:image-count"
            case metadataStatsNonWhiteCharCount = "meta:non-whitespace-character-count"
            case metadataStatsObjectCount = "meta:object-count"
            case metadataStatsOLECount = "meta:ole-object-count"
            case metadataStatsPageCount = "meta:page-count"
            case metadataStatsParagraphCount = "meta:paragraph-count"
            case metadataStatsRowCount = "meta:row-count"
            case metadataStatsSentenceCount = "meta:sentence-count"
            case metadataStatsSyllableCount = "meta:syllable-count"
            case metadataStatsTableCount = "meta:table-count"
            case metadataStatsWordCount = "meta:word-count"
            case metadataODTCustomName = "meta:name"
            case metadataODTCustomKind = "meta:value-type"
            case metadataODTCustomValue = "meta:user-defined"
        }
        
        let metadataODTCodingKeys: [CodingKey] = { (path: [MetadataODTCodingKeys]) -> CodingKey in
            // Map each ODTCodingKey to a CodingKey
            switch path.first {
            case .metadataODTGenerator:
                return CodingKeys(stringValue: "meta:generator")!
            case .metadataODTTitle:
                return CodingKeys(stringValue: "dc:title")!
            case .metadataODTDescription:
                return CodingKeys(stringValue: "dc:description")!
            case .metadataODTSubject:
                return CodingKeys(stringValue: "dc:subject")!
            case .metadataODTKeyword:
                return CodingKeys(stringValue: "dc:keyword")!
            case .metadataODTInitialCreator:
                return CodingKeys(stringValue: "dc:initial-creator")!
            case .metadataODTCreator:
                return CodingKeys(stringValue: "dc:creator")!
            case .metadataODTPrintedBy:
                return CodingKeys(stringValue: "meta:printed-by")!
            case .metadataODTCreationDate:
                return CodingKeys(stringValue: "meta:creation-date")!
            case .metadataODTDate:
                return CodingKeys(stringValue: "dc:date")!
            case .metadataODTPrintDate:
                return CodingKeys(stringValue: "meta:print-date")!
            case .metadataODTTemplate:
                return CodingKeys(stringValue: "meta:template")!
            case .metadataODTAutoReload:
                return CodingKeys(stringValue: "meta:auto-reload")!
            case .metadataHLBehaviourTargetFrameName:
                return CodingKeys(stringValue: "office:target-frame-name")!
            case .metadataHLBehaviourXLinkShow:
                return CodingKeys(stringValue: "xlink:show")!
            case .metadataODTLanguage:
                return CodingKeys(stringValue: "dc:language")!
            case .metadataODTEditingCycles:
                return CodingKeys(stringValue: "meta:editing-cycles")!
            case .metadataODTEditingDuration:
                return CodingKeys(stringValue: "meta:editing-duration")!
            case .metadataStatsCellCount:
                return CodingKeys(stringValue: "meta:cell-count")!
            case .metadataStatsCharacterCount:
                return CodingKeys(stringValue: "meta:character-count")!
            case .metadataStatsDrawCount:
                return CodingKeys(stringValue: "meta:draw-count")!
            case .metadataStatsFrameCount:
                return CodingKeys(stringValue: "meta:frame-count")!
            case .metadataStatsImageCount:
                return CodingKeys(stringValue: "meta:image-count")!
            case .metadataStatsNonWhiteCharCount:
                return CodingKeys(stringValue: "meta:non-whitespace-character-count")!
            case .metadataStatsObjectCount:
                return CodingKeys(stringValue: "meta:object-count")!
            case .metadataStatsOLECount:
                return CodingKeys(stringValue: "meta:ole-object-count")!
            case .metadataStatsPageCount:
                return CodingKeys(stringValue: "meta:page-count")!
            case .metadataStatsParagraphCount:
                return CodingKeys(stringValue: "meta:paragraph-count")!
            case .metadataStatsRowCount:
                return CodingKeys(stringValue: "meta:row-count")!
            case .metadataStatsSentenceCount:
                return CodingKeys(stringValue: "meta:sentence-count")!
            case .metadataStatsSyllableCount:
                return CodingKeys(stringValue: "meta:syllable-count")!
            case .metadataStatsTableCount:
                return CodingKeys(stringValue: "meta:table-count")!
            case .metadataStatsWordCount:
                return CodingKeys(stringValue: "meta:word-count")!
            case .metadataODTCustomName:
                return CodingKeys(stringValue: "meta:name")!
            case .metadataODTCustomKind:
                return CodingKeys(stringValue: "meta:value-type")!
            case .metadataODTCustomValue:
                return CodingKeys(stringValue: "meta:user-defined")!
            case .none:
                return CodingKeys(stringValue: "")!
            }
        }
        
        //Actual decodification of METADATA
        
        
        decoder.keyDecodingStrategy = .custom{ keys in
            guard let lastKey = metadataODTCodingKeys.last else { return MetadataODTCodingKeys(stringValue: "")! }
            guard let odtMetadataKey = MetadataODTCodingKeys.first(where: { $0.stringValue == lastKey.stringValue }) else {
                return lastKey
            }
            return odtMetadataKey
        }
        
        metadata = try decoder.decode(ODTMetadata.self, from: Data(contentsOf: DocumentData().metaXML!))
        
        // Access the decoded metadata values
        print("Loading document metadata:")
        print("")
        print("Generator: \(String(describing: metadata.metadataODTCreator))") // "MicrosoftOffice/15.0 MicrosoftWord"
        print("Title: \(String(describing: metadata.metadataODTTitle))") // "Costituzione della Repubblica insuliana"
        print("Creator: \(String(describing: metadata.metadataODTCreator))") // "Simone Alghisi"
        print("Date: \(String(describing: metadata.metadataODTDate))") // "2023-03-03T12:07:00Z"
        print("Page count: \(metadata.metadataODTDocumentStatistics.metadataStatsPageCount)") // 53
        print("Word count: \(metadata.metadataODTDocumentStatistics.metadataStatsWordCount)") // 13918
        print("")
        
        
        
        
        
        
    
    }
    
    init(fileWrapper: FileWrapper, contentType: UTType) throws {
        guard contentType == .openDocumentText else {
            print("Couldn't decode file!")
            throw CocoaError(.fileReadUnsupportedScheme)
        }
    }
}
