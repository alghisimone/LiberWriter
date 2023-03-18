//
//  ODTDocument.swift
//  LiberWriter
//
//  Created by Simone Alghisi on 09/03/23.
//

import SwiftUI
import UniformTypeIdentifiers
import XMLCoder
import ZIPFoundation

extension UTType {
    static var openDocumentText: UTType {
        UTType(exportedAs: "org.oasis-open.opendocument.text")
    }
}


struct OpenOfficeTextDocument: Codable {
    public var manifestXML = XMLDocument(contentsOf: tempStorage.appendingPathComponent("\(document)/META-INF/manifest.xml"))
    public var contentXML = XMLDocument(contentsOf: tempStorage.appendingPathComponent("\(document)/content.xml"))
    public var metadataXML = XMLDocument(contentsOf: tempStorage.appendingPathComponent("\(document)/meta.xml"))
    public var settingsXML = XMLDocument(contentsOf: tempStorage.appendingPathComponent("\(document)/settings.xml"))
    public var stylesXML = XMLDocument(contentsOf:  tempStorage.appendingPathComponent("\(document)/styles.xml"))
    public var resourcesXML = Data(contentsOf: tempStorage.appendingPathComponent("\(document)/media/"))
}



struct OfficeDocumentMeta: Codable {
    let officeVersion: String
    let officeMeta: Metadata
    
    enum CodingKeys: String, CodingKey {
        case officeVersion = "office:version"
        case officeMeta = "office:meta"
    }
}

struct Metadata: Codable {
    let generator: String
    let dcTitle: String
    let dcSubject: String
    let initialCreator: String
    let dcCreator: String
    let creationDate: String
    let dcDate: String
    let metaTemplate: MetaTemplate
    let editingCycles: String
    let editingDuration: String
    let userDefined: [UserDefined]
    let documentStatistic: DocumentStatistic
    
    enum CodingKeys: String, CodingKey {
        case generator = "meta:generator"
        case dcTitle = "dc:title"
        case dcSubject = "dc:subject"
        case initialCreator = "meta:initial-creator"
        case dcCreator = "dc:creator"
        case creationDate = "meta:creation-date"
        case dcDate = "dc:date"
        case metaTemplate = "meta:template"
        case editingCycles = "meta:editing-cycles"
        case editingDuration = "meta:editing-duration"
        case userDefined = "meta:user-defined"
        case documentStatistic = "meta:document-statistic"
    }
}

struct MetaTemplate: Codable {
    let xlinkHref: String
    let xlinkType: String
    
    enum CodingKeys: String, CodingKey {
        case xlinkHref = "xlink:href"
        case xlinkType = "xlink:type"
    }
}

struct UserDefined: Codable {
    let metaName: String
    let metaValueType: String?
    let metaValue: String
    
    enum CodingKeys: String, CodingKey {
        case metaName = "meta:name"
        case metaValueType = "meta:value-type"
        case metaValue = "meta:value"
    }
}

struct DocumentStatistic: Codable {
    let metaPageCount: String
    let metaParagraphCount: String
    let metaWordCount: String
    let metaCharacterCount: String
    let metaRowCount: String
    let metaNonWhitespaceCharacterCount: String
    
    enum CodingKeys: String, CodingKey {
        case metaPageCount = "meta:page-count"
        case metaParagraphCount = "meta:paragraph-count"
        case metaWordCount = "meta:word-count"
        case metaCharacterCount = "meta:character-count"
        case metaRowCount = "meta:row-count"
        case metaNonWhitespaceCharacterCount = "meta:non-whitespace-character-count"
    }
}


struct ODTDocument: FileDocument, Codable {
    static var readableContentTypes: [UTType] { [.openDocumentText] }
    static var writableContentTypes: [UTType] { [.openDocumentText] }
    
        var paragraphElement: [String]
        var titleElement: [String]
        var paragraphElementStyle: [String]
        var titleElementStyle: [String]
        var paragraphOutlineElement: [String]
        var images: [Data]
        var metadata: [Metadata: String]
        var tables: [[String]]
        var sections: [Section]
        var lists: [List]
        var styles: [String: Style]
        var footnotes: [Note]
        var endnotes: [Note]
        var hyperlinks: [Hyperlink]
        var bookmarks: [Bookmark]
    
    enum CodingKeys: String, CodingKey {
        case paragraphElement = "text:p"
        case titleElement = "text:h"
        case paragraphElementStyle = "text:style-name"
        case titleElementStyle = "text:h text:style-name"
    }
    
    enum Metadata: String, Codable {
        case generator
        case title
        case description
        case subject
        case keyword
        case initialCreator
        case creator
        case printedBy
        case creationDate
        case date
        case printDate
        case template
        case autoReload
        case hyperlinkBehaviour
        case language
        case editingCycles
        case editingDuration
        case documentStatistic
        case userDefined
    }
    
    struct Section: Codable {
        var range: NSRange
        var fontName: String
        var fontSize: CGFloat
        var textColor: String
        // Add additional properties for other formatting properties as needed}
        
        init (range: NSRange, fontName: String, fontSize: CGFloat, textColor: String) {
            self.range = range
            self.fontName = fontName
            self.fontSize = fontSize
            self.textColor = textColor
        }
    }
        
        struct List: Codable {
                var type: String
                var level: Int
                var items: [String]
            }
            
            struct Style: Codable {
                var fontFamily: String
                    var fontSize: CGFloat
                    var fontStyle: FontStyle
                    var textColor: String
                    var backgroundColor: String
                    var textPosition: Double
                    var textDecoration: String
                    var lineSpacing: Double
                    var textAlign: CGFloat
                    
                    enum FontStyle: String, Codable {
                        case regular
                        case bold
                        case italic
                        case boldItalic = "bold-italic"
                    }
                
                    enum textAlign: String, Codable {
                        case left
                        case center
                        case right
                        case justified
                    }
            }
            
            struct Note: Codable {
                var text: String
                var number: Int // or symbol: String
            }
            
            struct Hyperlink: Codable {
                var url: String
                var range: NSRange
            }
            
            struct Bookmark: Codable {
                var name: String
                var range: NSRange
            }
        
        init() {
            paragraphElement = [:]
                paragraphElementStyle = []
                paragraphOutlineElement = []
                images = []
                metadata = [:]
                tables = []
                sections = []
                lists = []
                styles = [:]
                footnotes = []
                endnotes = []
                hyperlinks = []
                bookmarks = []
            }
    
    
    
    init(fileWrapper: FileWrapper, contentType: UTType) throws {
        guard contentType == .openDocumentText else {
            throw CocoaError(.fileReadUnsupportedScheme)
        }
        
        guard let data = fileWrapper.regularFileContents,
              let archive = Archive(data: data, accessMode: .read),
              let xmlMeta = archive["meta.xml"],
              let xmlStyles = archive["styles.xml"],
              let xmlSettings = archive["settings.xml"],
              let xmlContent = archive["content.xml"] else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        let decoder = XMLDecoder()
        
        self = try decoder.decode(ODTDocument.self, from: xmlContent)
    }
    
    func fileWrapper() throws -> FileWrapper {
        let encoder = XMLEncoder()
        let xmlData = try encoder.encode(self, withRootKey: "office:document-content")
        
        let archive = Archive(accessMode: .create)
        try archive.addEntry(with: "content.xml", type: .file, uncompressedSize: UInt32(xmlData.count)) { data in
            data.write(xmlData)
        }
        
        let fileWrapper = FileWrapper(regularFileWithContents: archive.data)
        fileWrapper.preferredFilename = "document.odt"
        return fileWrapper
    }
}



