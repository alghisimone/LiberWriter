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
import CoreData


let decoder = XMLDecoder()

extension UTType {
    static var openDocumentText: UTType {
        UTType(importedAs: "org.oasis-open.opendocument.text")
        UTType(filenameExtension: ".odt")
        UTTypeReference(filenameExtension: ".odt")
        UTType(mimeType: "application/vnd.oasis.opendocument.text", conformingTo: .text)
    }
}

// let documentODFType = UTType("org.oasis-open.opendocument.text")
let documentODFType = UTType.openDocumentText

let testmanifestXML = """
<?xml version="1.0" encoding="UTF-8"?>
<manifest:manifest xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0" manifest:version="1.3" xmlns:loext="urn:org:documentfoundation:names:experimental:office:xmlns:loext:1.0">
 <manifest:file-entry manifest:full-path="/" manifest:version="1.3" manifest:media-type="application/vnd.oasis.opendocument.text"/>
 <manifest:file-entry manifest:full-path="Configurations2/accelerator/current.xml" manifest:media-type=""/>
 <manifest:file-entry manifest:full-path="Configurations2/" manifest:media-type="application/vnd.sun.xml.ui.configuration"/>
 <manifest:file-entry manifest:full-path="meta.xml" manifest:media-type="text/xml"/>
 <manifest:file-entry manifest:full-path="styles.xml" manifest:media-type="text/xml"/>
 <manifest:file-entry manifest:full-path="Pictures/100000010000019C0000018CD8AAB4BAB13D2E03.png" manifest:media-type="image/png"/>
 <manifest:file-entry manifest:full-path="content.xml" manifest:media-type="text/xml"/>
 <manifest:file-entry manifest:full-path="settings.xml" manifest:media-type="text/xml"/>
 <manifest:file-entry manifest:full-path="manifest.rdf" manifest:media-type="application/rdf+xml"/>
 <manifest:file-entry manifest:full-path="Thumbnails/thumbnail.png" manifest:media-type="image/png"/>
</manifest:manifest>
"""


/// The Structure of the ODF Document should be set when decoding, but it also should be an ObservableObject

struct documentODT: Codable, FileDocument {
    static var readableContentTypes: [UTType] {[.openDocumentText]}
    
    public var documentManifest: documentManifest!
    //public var documentSettings: documentSettings
    //public var documentMeta: documentMeta
    
    public enum documentBundleCodingKeys: String, CodingKey {
        case documentManifest = "manifest:manifest"
        //case documentSettings = ""
        // case documentMeta = ""
    }
    
    class documentManifest: Codable, ObservableObject {
        public var manifestVersion: String?
        public var manifestFileEntry: [manifestFileEntry]
        
        public enum documentManifestCodingKeys: String, CodingKey {
            case manifestManifest = "manifest:manifest"
            case manifestEncrypedKey = "manifest:encrypted-key"
            case manifestVersion = "manifest:version"
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: documentManifestCodingKeys.self)
            
            manifestVersion = try container.decodeIfPresent(String.self, forKey: .manifestVersion)
        }
        
        class manifestFileEntry: Codable, ObservableObject {
            public var manifestFileEntryPath: URL?
            public var manifestFileEntryMediaType: String?
            public var manifestFileEntryPreferredViewMode: String?
            public var manifestFileEntrySize: Int?
            public var manifestFileEntryVersion: Double?
            public var manifestFileEntryEncryptionData: fileEntryEncryptionData?
            
            public enum manifestFileEntryCodingKeys: String, CodingKey {
                case manifestFileEntryPath = "manifest:full-path"
                case manifestFileEntryMediaType = "manifest:media-type"
                case manifestFileEntryPreferredViewMode = "manifest:preferred-view-mode"
                case manifestFileEntrySize = "manifest:size"
                case manifestFileEntryVersion = "manifest:version"
                case manifestFileEntryEncryptionData = "manifest:encryption-data"
            }
            
            required init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: manifestFileEntryCodingKeys.self)
                manifestFileEntryPath = try container.decodeIfPresent(URL.self, forKey: .manifestFileEntryPath)
                manifestFileEntryMediaType = try container.decodeIfPresent(String.self, forKey: .manifestFileEntryMediaType)
                manifestFileEntryPreferredViewMode = try container.decodeIfPresent(String.self, forKey: .manifestFileEntryPreferredViewMode)
                manifestFileEntrySize = try container.decodeIfPresent(Int.self, forKey: .manifestFileEntrySize)
                manifestFileEntryVersion = try container.decodeIfPresent(Double.self, forKey: .manifestFileEntryVersion)
                manifestFileEntryEncryptionData = try container.decodeIfPresent(fileEntryEncryptionData.self, forKey: .manifestFileEntryEncryptionData)
            }
            
            class fileEntryEncryptionData: Codable, ObservableObject {
                public var fileEntryEncryptionDataChecksum: String?
                public var fileEntryEncryptionDataChecksumType: String?
                public var fileEntryEncryptionDataAlgorithm: fileEntryEncryptionDataAlgorithm?
                public var fileEntryEncryptionDataKeyDerivation: fileEntryEncryptionDataKeyDerivation?
                public var fileEntryEncryptionDataStartKeyGeneration: fileEntryEncryptionDataStartKeyGeneration?
                
                public enum fileEntryEncryptionDataCodingKeys: String, CodingKey {
                    case fileEntryEncryptionDataChecksum = "manifest:checksum"
                    case fileEntryEncryptionDataChecksumType = "manifest:checksum-type"
                    case fileEntryEncryptionDataAlgorithm = "manifest:algorithm"
                    case fileEntryEncryptionDataKeyDerivation = "manifest:key-derivation"
                    case fileEntryEncryptionDataStartKeyGeneration = "manifest:start-key-generation"
                }
                
                required init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: fileEntryEncryptionDataCodingKeys.self)
                    fileEntryEncryptionDataChecksum = try container.decodeIfPresent(String.self, forKey: .fileEntryEncryptionDataChecksum)
                }
                
                class fileEntryEncryptionDataAlgorithm: Codable, ObservableObject {
                    public var entryEncryptionDataAlgorithmName: String?
                    public var entryEncryptionInitialisationVector: Data?
                    
                    public enum fileEntryEncryptionDataAlgorithmCodingKeys: String, CodingKey {
                        case entryEncryptionDataAlgorithmName = "manifest:algorithm-name"
                        case entryEncryptionInitialisationVector = "manifest:initialisation-vector"
                    }
                }
                class fileEntryEncryptionDataKeyDerivation: Codable, ObservableObject {
                    public var entryEncryptionKeyDerivationIterationCount: Int?
                    public var entryEncryptionKeyDerivationName: String?
                    public var entryEncryptionKeyDerivationSize: Int?
                    public var entryEncryptionKeyDerivationSalt: Data?
                    
                    public enum fileEntryEncryptionDataKeyDerivationCodingKeys: String, CodingKey {
                        case entryEncryptionKeyDerivationIterationCount = "manifest:iteration-count"
                        case entryEncryptionKeyDerivationName = "manifest:key-derivation-name"
                        case entryEncryptionKeyDerivationSize = "manifest:key-size"
                        case entryEncryptionKeyDerivationSalt = "manifest:salt"
                    }
                }
                class fileEntryEncryptionDataStartKeyGeneration: Codable, ObservableObject {
                    public var entryEncryptionKeyGenerationSize: Int?
                    public var entryEncryptionKeyGenerationName: String?
                    
                    public enum fileEntryEncryptionDataStartKeyGenerationCodingKeys: String, CodingKey {
                        case entryEncryptionKeyGenerationSize = "manifest:key-size"
                        case entryEncryptionKeyGenerationName = "manifest:start-key-generation-name"
                    }
                }
                
            }
            
            
        
    }
    
    class documentMeta: Codable, ObservableObject {
        public var metadataODFGenerator: String?
        public var metadataODFTitle: String?
        public var metadataODFDescription: String?
        public var metadataODFSubject: String?
        public var metadataODFKeyword: String?
        public var metadataODFInitialCreator: String?
        public var metadataODFCreator: String?
        public var metadataODFPrintedBy: String?
        public var metadataODFCreationDate: Date?
        public var metadataODFDate: Date?
        public var metadataODFPrintDate: Date?
        public var metadataODFTemplate: String?
        public var metadataODFAutoReload: Bool?
        public var hyperlinkBehaviour: hyperlinkBehaviour?
        public var metadataODFLanguage: String?
        public var metadataODFEditingCycles: Int?
        public var metadataODFEditingDuration: Int?
        public var metadataODFDocumentStatistics: metadataODFDocumentStatistics?
        public var metadataODFUserDefined: [metadataODFUserDefined?]
        
        public enum documentMetaCodingKeys: String, CodingKey {
            case metadataODFGenerator = "meta:generator"
            case metadataODFTtitle = "dc:title"
            case metadataODFDescription = "dc:description"
            case metadataODFSubject = "dc:subject"
            case metadataODFKeyword = "dc:keyword"
            case metadataODFInitialCreator = "meta:initial-creator"
            case metadataODFCreator = "dc:creator"
            case metadataODFPrintedBy = "meta:printed-by"
            case metadataODFCreationDate = "meta:creation-date"
            case metadataODFDate = "dc.date"
            case metadataODFPrintDate = "meta:print-date"
            case metadataODFTemplate = "meta:template"
            case metadataODFAutoReload = "meta:auto-reload"
            case metadataODFLanguage = "dc:language"
            case metadataODFEditingCycles = "meta:editing-cycles"
            case metadataODFEditingDuration = "meta:editing-duration"
        }
        
        class hyperlinkBehaviour: Codable, ObservableObject {
            public var metadataHLBehaviourTargetFrameName: String?
            public var metadataHLBehaviourXLinkShow: String?
            
            public enum hyperlinkBehaviourCodingKeys: String, CodingKey {
                case metadataHLBehaviourTargetFrameName = "office:target-frame-name"
                case metadataHLBehaviourXLinkShow = "xlink:show"
            }
        }
        class metadataODFDocumentStatistics: Codable, ObservableObject {
            public var metadataStatsCellCount: Int
            public var metadataStatsCharacterCount: Int
            public var metadataStatsDrawCount: Int
            public var metadataStatsFrameCount: Int
            public var metadataStatsImageCount: Int
            public var metadataStatsNonWhiteCharCount: Int
            public var metadataStatsObjectCount: Int
            public var metadataStatsOLECount: Int
            public var metadataStatsPageCount: Int
            public var metadataStatsParagraphCount: Int
            public var metadataStatsRowCount: Int
            public var metadataStatsSentenceCount: Int
            public var metadataStatsSyllableCount: Int
            public var metadataStatsTableCount: Int
            public var metadataStatsWordCount: Int
            
            public enum metadataODFDocumentStatistics: String, CodingKey {
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
            }
        }
        class metadataODFUserDefined: Codable, ObservableObject {
            public var metadataODFCustomName: String?
            public var metadataODFCustomValue: String?
            public var metadataODFCustomKind: String?
            
            public enum metadataODFUserDefinedCodingKeys: String, CodingKey {
                case metadataODFCustomName = "meta:name"
                case metadataODFCustomKind = "meta:value-type"
                case metadataODFCustomValue = "meta:user-defined"
            }
            
        }
    }
    
    
    //public var documentManifest: Codable {}
    //public var documentStyles: Codable {}
    //public var documentSettings: Codable {}
    //public var documentContent: Codable {}
    //public var resources: Codable {}
    
    public var settingsXML: URL?
    
    
    init(configuration: ReadConfiguration) throws {
        CocoaError.coderReadCorrupt
    }
    
    func fileWrapper(configuration: Self.WriteConfiguration) throws -> FileWrapper {
        
    }
    
}



func decodeDocument() {
    // create an XMLDecoder instance
    
    
    // create an XMLDocument instance from the XML string
    let xmlDocument = try XMLDocument(xmlString: testmanifestXML, options: [.])
    
    // decode the documentManifest type from the XMLDocument instance
    let manifest = try decoder.decode(documentManifest.self, from: xmlDocument)
}
