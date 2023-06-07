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
        UTType(mimeType: "")
    }
}

/// The Structure of the ODF Document should be set when decoding, but it also should be an ObservableObject

class documentODTStruct: Codable, ObservableObject {
    public var metaXML: URL?
    public var contentXML: URL?
    public var documentBundle: Codable?
    public var manifestXML: URL!
    }

class documentBundle: Codable, ObservableObject {
    public var documentManifest: documentManifest!
    public var documentSettings: documentSettings
    public var documentMeta: documentMeta
    
    class documentManifest: Codable, ObservableObject {
        public var manifestManifest:
        public var manifestFileEntry: [manifestFileEntry]
        public var manifestEncryptedKey:
        
        public enum documentManifestCodingKeys: String, CodingKey {
            case manifestManifest = "manifest:manifest"
            case manifestEncrypedKey = "manifest:encrypted-key"
        }
        
        
        class manifestFileEntry: Codable, ObservableObject {
            public var manifestFileEntryPath: URL?
            public var manifestFileEntryMediaType: UTType?
            public var manifestFileEntryPreferredViewMode: String?
            public var manifestFileEntrySize: Int?
            public var manifestFileEntryVersion: Double?
            public var manifestFileEntryEncryptionData: fileEntryEncryptionData?
            
            class fileEntryEncryptionData: Codable, ObservableObject {
                public var fileEntryEncryptionDataChecksum: String?
                public var fileEntryEncryptionDataChecksumType: String?
                public var fileEntryEncryptionDataAlgorithm: fileEntryEncryptionDataAlgorithm?
                public var fileEntryEncryptionDataKeyDerivation: fileEntryEncryptionDataKeyDerivation?
                public var fileEntryEncryptionDataStartKeyGeneration: fileEntryEncryptionDataStartKeyGeneration?
                
                class fileEntryEncryptionDataAlgorithm: Codable, ObservableObject {
                    public var entryEncryptionDataAlgorithmName: String?
                    public var entryEncryptionInitialisationVector: Data
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

        
        public var documentManifest: Codable {
            
        }
        public var documentStyles: Codable {
            
        }

        public var documentSettings: Codable {
            
        }
        public var documentContent: Codable {
            
        }
        public var resources: Codable {
            
        }
    }
    public var settingsXML: URL?
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

class ODFManifest: ObservableObject {
    @Published var manifestManifest: String?
    @Published var manifestVersion: String?
    @Published var manifestEncryptedKey: EncryptedKey?
    @Published var manifestFileEntry: FileEntry?
    @Published var contentFile: URL?
    @Published var stylesFile: URL?
    @Published var elementsOfFile: URL?
    @Published var filePrefix: URL?
    @Published var fileSuffix: URL?
    
    class FileEntry {
        var manifestFileEntryFullPath: String?
        var manifestFileEntryMediaType: String?
        var manifestFileEntryPreferredViewMode: String?
        var manifestFileEntrySize: Int?
        var manifestFileEntryVersion: String?
        var manifestEncryptionData: ODFEncryption?
    }
    
    class ODFEncryption {
        var manifestChecksum: (any BinaryInteger)?
        var manifestChecksumType: String?
        var manifestEncryptionAlgorythm: String?
        var manifestKeyDerivation: String?
        var manifestStartKeyGeneration: String?
    }
    
    class EncryptedKey {
        var manifestChypherData: ChypherValue?
        var manifestEncryptionMethod:
        var manifestKeyInfo: 
    }
}


class ODFMetadata: Codable {
    var metadataODFGenerator: String?
    var metadataODFTitle: String?
    var metadataODFDescription: String?
    var metadataODFSubject: String?
    var metadataODFKeyword: String?
    var metadataODFInitialCreator: String?
    var metadataODFCreator: String?
    var metadataODFPrintedBy: String?
    var metadataODFCreationDate: Date?
    var metadataODFDate: Date?
    var metadataODFPrintDate: Date?
    var metadataODFTemplate: String?
    var metadataODFAutoReload: Bool?
    var hyperlinkBehaviour: HyperlinkBehaviour
    var metadataODFLanguage: String?
    var metadataODFEditingCycles: Int?
    var metadataODFEditingDuration: Int?
    var metadataODFDocumentStatistics: ODFDocumentStatistics
    var metadataODFUserDefined: ODFMetadataUserDefined

    class ODFMetadataUserDefined: Codable {
        var metadataODFCustomName: String?
        var metadataODFCustomValue: String?
        var metadataODFCustomKind: String?
    }

    class ODFDocumentStatistics: Codable {
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




struct ODFDocument: FileDocument, Codable {
    static var readableContentTypes: [UTType] { [.openDocumentText] }
    static var writableContentTypes: [UTType] { [.openDocumentText] }
    
    var metadata: ODFMetadata
    //var content: ODFContent
    //var style: ODFStyle
    //var settings: ODFSettings
    var manifest: ODFManifest
    //var resources: ODFResources
    
    init(from decoder: XMLDecoder) throws {
        
        //General settings for the decoder
        
        decoder.shouldProcessNamespaces = true
        
        enum ManifestODFCodingKeys: String, CodingKey {
            case contentFile = "odf:ContentFile"
            case stylesFile = "odf:StylesFile"
            case fileElement = "odf:Element"
            case filePrefix = "odf:prefix"
            case fileSuffix = "odf:suffix"
        }
        

        print("--- Loading new document ---")
        
        //Decode METADATA
        
        //METADATA Coding Keys
              

        
        //Actual decodification of METADATA
        
        
        decoder.keyDecodingStrategy = .custom{ keys in metadataODFCodingKeys as! any CodingKey}
        
        metadata = try decoder.decode(ODFMetadata.self, from: Data(contentsOf: DocumentData().metaXML!))
        
        // Access the decoded metadata values
        print("Loading document metadata:")
        print("")
        print("Generator: \(String(describing: metadata.metadataODFCreator))") // "MicrosoftOffice/15.0 MicrosoftWord"
        print("Title: \(String(describing: metadata.metadataODFTitle))") // "Costituzione della Repubblica insuliana"
        print("Creator: \(String(describing: metadata.metadataODFCreator))") // "Simone Alghisi"
        print("Date: \(String(describing: metadata.metadataODFDate))") // "2023-03-03T12:07:00Z"
        print("Page count: \(metadata.metadataODFDocumentStatistics.metadataStatsPageCount)") // 53
        print("Word count: \(metadata.metadataODFDocumentStatistics.metadataStatsWordCount)") // 13918
        print("")
        
        
        
        
        
        
    
    }
    
    init(fileWrapper: FileWrapper, contentType: UTType) throws {
        guard contentType == .openDocumentText else {
            print("Couldn't decode file!")
            throw CocoaError(.fileReadUnsupportedScheme)
        }
    }
}
///
