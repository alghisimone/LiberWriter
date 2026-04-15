//
//  ODTFile.swift
//  LiberWriter
//
//  Created by Simone Alghisi on 02/03/2025.
//

import Foundation
import ZIPFoundation

enum ODTError: LocalizedError {
    case invalidArchive
    case missingRequiredEntry(String)
    case malformedXML(String)
    case invalidDocumentRoot(String)
    case unsupportedMimetype(String)

    var errorDescription: String? {
        switch self {
        case .invalidArchive:
            return "Failed to read the ODT archive."
        case .missingRequiredEntry(let entry):
            return "Missing required package entry: \(entry)"
        case .malformedXML(let detail):
            return "Malformed XML: \(detail)"
        case .invalidDocumentRoot(let name):
            return "Unexpected document root element: \(name)"
        case .unsupportedMimetype(let mimetype):
            return "Unsupported mimetype: \(mimetype)"
        }
    }
}

enum ODFNamespace: String, CaseIterable {
    case office = "urn:oasis:names:tc:opendocument:xmlns:office:1.0"
    case text = "urn:oasis:names:tc:opendocument:xmlns:text:1.0"
    case style = "urn:oasis:names:tc:opendocument:xmlns:style:1.0"
    case table = "urn:oasis:names:tc:opendocument:xmlns:table:1.0"
    case draw = "urn:oasis:names:tc:opendocument:xmlns:drawing:1.0"
    case fo = "urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0"
    case xlink = "http://www.w3.org/1999/xlink"
    case svg = "urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0"
    case meta = "urn:oasis:names:tc:opendocument:xmlns:meta:1.0"
    case dc = "http://purl.org/dc/elements/1.1/"
    case manifest = "urn:oasis:names:tc:opendocument:xmlns:manifest:1.0"
    case number = "urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0"
    case presentation = "urn:oasis:names:tc:opendocument:xmlns:presentation:1.0"
    case chart = "urn:oasis:names:tc:opendocument:xmlns:chart:1.0"
    case form = "urn:oasis:names:tc:opendocument:xmlns:form:1.0"
    case script = "urn:oasis:names:tc:opendocument:xmlns:script:1.0"
    case config = "urn:oasis:names:tc:opendocument:xmlns:config:1.0"
    case xml = "http://www.w3.org/XML/1998/namespace"

    var preferredPrefix: String {
        switch self {
        case .office: return "office"
        case .text: return "text"
        case .style: return "style"
        case .table: return "table"
        case .draw: return "draw"
        case .fo: return "fo"
        case .xlink: return "xlink"
        case .svg: return "svg"
        case .meta: return "meta"
        case .dc: return "dc"
        case .manifest: return "manifest"
        case .number: return "number"
        case .presentation: return "presentation"
        case .chart: return "chart"
        case .form: return "form"
        case .script: return "script"
        case .config: return "config"
        case .xml: return "xml"
        }
    }
}

struct ODFQualifiedName: Hashable, Sendable {
    let localName: String
    let prefix: String?
    let namespaceURI: String?

    init(localName: String, prefix: String? = nil, namespaceURI: String? = nil) {
        self.localName = localName
        self.prefix = prefix
        self.namespaceURI = namespaceURI
    }

    init(xmlName: String, namespaceURI: String?, qualifiedName: String?) {
        self.localName = xmlName
        self.namespaceURI = namespaceURI
        if let qualifiedName, let separatorIndex = qualifiedName.firstIndex(of: ":") {
            self.prefix = String(qualifiedName[..<separatorIndex])
        } else {
            self.prefix = nil
        }
    }

    var rawName: String {
        guard let prefix, !prefix.isEmpty else {
            return localName
        }
        return "\(prefix):\(localName)"
    }
}

indirect enum ODFXMLContent: Sendable {
    case text(String)
    case element(ODFXMLNode)
}

struct ODFXMLNode: Sendable {
    var name: ODFQualifiedName
    var attributes: [ODFQualifiedName: String]
    var children: [ODFXMLContent]

    init(name: ODFQualifiedName, attributes: [ODFQualifiedName: String] = [:], children: [ODFXMLContent] = []) {
        self.name = name
        self.attributes = attributes
        self.children = children
    }

    var elementChildren: [ODFXMLNode] {
        children.compactMap {
            if case .element(let node) = $0 {
                return node
            }
            return nil
        }
    }

    var normalizedText: String {
        children.map { child in
            switch child {
            case .text(let text):
                return text
            case .element(let node):
                return node.normalizedText
            }
        }.joined()
    }

    func attribute(_ localName: String, namespace: ODFNamespace? = nil) -> String? {
        attributes.first { key, _ in
            key.localName == localName && (namespace == nil || key.namespaceURI == namespace?.rawValue)
        }?.value
    }

    func childElements(_ localName: String, namespace: ODFNamespace? = nil) -> [ODFXMLNode] {
        elementChildren.filter {
            $0.name.localName == localName && (namespace == nil || $0.name.namespaceURI == namespace?.rawValue)
        }
    }

    func firstChild(_ localName: String, namespace: ODFNamespace? = nil) -> ODFXMLNode? {
        childElements(localName, namespace: namespace).first
    }

    func descendantElements(_ localName: String, namespace: ODFNamespace? = nil) -> [ODFXMLNode] {
        var matches = childElements(localName, namespace: namespace)
        for child in elementChildren {
            matches.append(contentsOf: child.descendantElements(localName, namespace: namespace))
        }
        return matches
    }

    func updatingFirstChild(
        _ localName: String,
        namespace: ODFNamespace? = nil,
        with replacement: ODFXMLNode
    ) -> ODFXMLNode {
        var updated = self
        var hasUpdated = false
        updated.children = children.map { child in
            guard case .element(let node) = child else {
                return child
            }
            guard !hasUpdated else {
                return child
            }
            let matchesName = node.name.localName == localName
            let matchesNamespace = namespace == nil || node.name.namespaceURI == namespace?.rawValue
            guard matchesName && matchesNamespace else {
                return child
            }
            hasUpdated = true
            return .element(replacement)
        }
        return updated
    }

    func xmlString(indentationLevel: Int = 0, prettyPrinted: Bool = true) -> String {
        let indent = prettyPrinted ? String(repeating: "    ", count: indentationLevel) : ""
        let newline = prettyPrinted ? "\n" : ""
        let attributesText = attributes
            .sorted { $0.key.rawName < $1.key.rawName }
            .map { key, value in
                "\(key.rawName)=\"\(value.xmlEscaped(isAttribute: true))\""
            }
            .joined(separator: " ")

        let openingTag: String
        if attributesText.isEmpty {
            openingTag = "<\(name.rawName)>"
        } else {
            openingTag = "<\(name.rawName) \(attributesText)>"
        }

        if children.isEmpty {
            return "\(indent)\(openingTag.dropLast())/>\(newline)"
        }

        let containsElementChildren = children.contains {
            if case .element = $0 {
                return true
            }
            return false
        }

        let childText = children.map { child -> String in
            switch child {
            case .text(let text):
                return text.xmlEscaped(isAttribute: false)
            case .element(let node):
                return node.xmlString(indentationLevel: indentationLevel + 1, prettyPrinted: prettyPrinted)
            }
        }.joined()

        if containsElementChildren && prettyPrinted {
            let trimmedText = childText.trimmingCharacters(in: .newlines)
            return "\(indent)\(openingTag)\(newline)\(trimmedText)\(newline)\(indent)</\(name.rawName)>\(newline)"
        }

        return "\(indent)\(openingTag)\(childText)</\(name.rawName)>\(newline)"
    }
}

extension String {
    fileprivate func xmlEscaped(isAttribute: Bool) -> String {
        var escaped = self
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
        if isAttribute {
            escaped = escaped.replacingOccurrences(of: "\"", with: "&quot;")
        }
        return escaped
    }
}

final class ODFXMLParserDelegate: NSObject, XMLParserDelegate {
    private var stack: [ODFXMLNode] = []
    private(set) var rootNode: ODFXMLNode?
    private(set) var parserError: Error?

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        var attributes: [ODFQualifiedName: String] = [:]
        for (rawKey, value) in attributeDict {
            let parts = rawKey.split(separator: ":", maxSplits: 1).map(String.init)
            let prefix = parts.count == 2 ? parts[0] : nil
            let localName = parts.count == 2 ? parts[1] : parts[0]
            let namespaceURI = prefix.flatMap { prefixValue in
                ODFNamespace.allCases.first(where: { $0.preferredPrefix == prefixValue })?.rawValue
            }
            let name = ODFQualifiedName(localName: localName, prefix: prefix, namespaceURI: namespaceURI)
            attributes[name] = value
        }

        let node = ODFXMLNode(
            name: ODFQualifiedName(xmlName: elementName, namespaceURI: namespaceURI, qualifiedName: qName),
            attributes: attributes
        )
        stack.append(node)
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard !stack.isEmpty else { return }
        if case .text(let existingText)? = stack[stack.count - 1].children.last {
            stack[stack.count - 1].children.removeLast()
            stack[stack.count - 1].children.append(.text(existingText + string))
        } else {
            stack[stack.count - 1].children.append(.text(string))
        }
    }

    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        guard let completedNode = stack.popLast() else { return }
        if stack.isEmpty {
            rootNode = completedNode
        } else {
            stack[stack.count - 1].children.append(.element(completedNode))
        }
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        parserError = parseError
    }
}

enum ODFXMLParser {
    static func parse(data: Data) throws -> ODFXMLNode {
        let parser = XMLParser(data: data)
        parser.shouldProcessNamespaces = true
        parser.shouldReportNamespacePrefixes = true

        let delegate = ODFXMLParserDelegate()
        parser.delegate = delegate

        guard parser.parse() else {
            throw ODTError.malformedXML(delegate.parserError?.localizedDescription ?? "XML parser failed.")
        }

        guard let rootNode = delegate.rootNode else {
            throw ODTError.malformedXML("The document has no root element.")
        }

        return rootNode
    }
}

struct ODTManifestEncryptionData: Sendable {
    let algorithmName: String?
    let checksumType: String?
    let checksum: String?
    let initializationVector: String?
}

struct ODTManifestFileEntry: Sendable {
    let fullPath: String
    let mediaType: String?
    let version: String?
    let size: Int?
    let preferredViewMode: String?
    let encryption: ODTManifestEncryptionData?
}

struct ODTManifest: Sendable {
    let version: String?
    let fileEntries: [ODTManifestFileEntry]

    init(rootNode: ODFXMLNode) throws {
        guard rootNode.name.localName == "manifest",
              rootNode.name.namespaceURI == ODFNamespace.manifest.rawValue else {
            throw ODTError.invalidDocumentRoot(rootNode.name.rawName)
        }

        version = rootNode.attribute("version", namespace: .manifest)
        fileEntries = rootNode.childElements("file-entry", namespace: .manifest).map { node in
            let encryptionNode = node.firstChild("encryption-data", namespace: .manifest)
            let algorithmNode = encryptionNode?.firstChild("algorithm", namespace: .manifest)
            return ODTManifestFileEntry(
                fullPath: node.attribute("full-path", namespace: .manifest) ?? "",
                mediaType: node.attribute("media-type", namespace: .manifest),
                version: node.attribute("version", namespace: .manifest),
                size: node.attribute("size", namespace: .manifest).flatMap(Int.init),
                preferredViewMode: node.attribute("preferred-view-mode", namespace: .manifest),
                encryption: encryptionNode.map {
                    ODTManifestEncryptionData(
                        algorithmName: algorithmNode?.attribute("algorithm-name", namespace: .manifest),
                        checksumType: encryptionNode?.attribute("checksum-type", namespace: .manifest),
                        checksum: encryptionNode?.attribute("checksum", namespace: .manifest),
                        initializationVector: algorithmNode?.attribute("initialisation-vector", namespace: .manifest)
                    )
                }
            )
        }
    }
}

struct ODTInlineSpan: Sendable {
    let styleName: String?
    let content: [ODTInlineNode]

    var plainText: String {
        content.map(\.plainText).joined()
    }
}

struct ODTLink: Sendable {
    let href: String?
    let styleName: String?
    let visitedStyleName: String?
    let content: [ODTInlineNode]

    var plainText: String {
        content.map(\.plainText).joined()
    }
}

indirect enum ODTInlineNode: Sendable {
    case text(String)
    case span(ODTInlineSpan)
    case link(ODTLink)
    case lineBreak
    case tab
    case spaces(Int)
    case noteCitation(String)
    case generic(ODFXMLNode)

    var plainText: String {
        switch self {
        case .text(let text):
            return text
        case .span(let span):
            return span.plainText
        case .link(let link):
            return link.plainText
        case .lineBreak:
            return "\n"
        case .tab:
            return "\t"
        case .spaces(let count):
            return String(repeating: " ", count: max(count, 1))
        case .noteCitation(let citation):
            return citation
        case .generic(let node):
            return node.normalizedText
        }
    }
}

struct ODTParagraph: Sendable {
    let styleName: String?
    let content: [ODTInlineNode]

    init(node: ODFXMLNode) {
        styleName = node.attribute("style-name", namespace: .text)
        content = ODTContentDecoder.inlineNodes(from: node)
    }

    static func plain(_ text: String) -> ODTParagraph {
        ODTParagraph(styleName: nil, content: [.text(text)])
    }

    private init(styleName: String?, content: [ODTInlineNode]) {
        self.styleName = styleName
        self.content = content
    }

    var plainText: String {
        content.map(\.plainText).joined()
    }
}

struct ODTHeading: Sendable {
    let level: Int
    let styleName: String?
    let content: [ODTInlineNode]

    init(node: ODFXMLNode) {
        level = Int(node.attribute("outline-level", namespace: .text) ?? "1") ?? 1
        styleName = node.attribute("style-name", namespace: .text)
        content = ODTContentDecoder.inlineNodes(from: node)
    }

    var plainText: String {
        content.map(\.plainText).joined()
    }
}

struct ODTListItem: Sendable {
    let blocks: [ODTTextBlock]
}

struct ODTList: Sendable {
    let styleName: String?
    let items: [ODTListItem]
    let headerBlocks: [ODTTextBlock]

    init(node: ODFXMLNode) {
        styleName = node.attribute("style-name", namespace: .text)
        headerBlocks = node.childElements("list-header", namespace: .text)
            .flatMap(ODTContentDecoder.blocks)
        items = node.childElements("list-item", namespace: .text).map { item in
            ODTListItem(blocks: ODTContentDecoder.blocks(from: item))
        }
    }

    var plainText: String {
        let header = headerBlocks.map(\.plainText).joined(separator: "\n")
        let itemsText = items.enumerated().map { index, item in
            let itemText = item.blocks.map(\.plainText).joined(separator: "\n")
            return "\(index + 1). \(itemText)"
        }.joined(separator: "\n")
        return [header, itemsText].filter { !$0.isEmpty }.joined(separator: "\n")
    }
}

struct ODTTableCell: Sendable {
    let repeatedColumns: Int
    let blocks: [ODTTextBlock]

    init(node: ODFXMLNode) {
        repeatedColumns = Int(node.attribute("number-columns-repeated", namespace: .table) ?? "1") ?? 1
        blocks = ODTContentDecoder.blocks(from: node)
    }
}

struct ODTTableRow: Sendable {
    let repeatedRows: Int
    let cells: [ODTTableCell]

    init(node: ODFXMLNode) {
        repeatedRows = Int(node.attribute("number-rows-repeated", namespace: .table) ?? "1") ?? 1
        cells = node.elementChildren.compactMap { child in
            guard child.name.namespaceURI == ODFNamespace.table.rawValue else {
                return nil
            }
            switch child.name.localName {
            case "table-cell", "covered-table-cell":
                return ODTTableCell(node: child)
            default:
                return nil
            }
        }
    }
}

struct ODTTable: Sendable {
    let name: String?
    let styleName: String?
    let rows: [ODTTableRow]

    init(node: ODFXMLNode) {
        name = node.attribute("name", namespace: .table)
        styleName = node.attribute("style-name", namespace: .table)
        rows = node.childElements("table-row", namespace: .table).map(ODTTableRow.init)
    }

    var plainText: String {
        rows.map { row in
            row.cells.map { cell in
                cell.blocks.map(\.plainText).joined(separator: "\n")
            }.joined(separator: "\t")
        }.joined(separator: "\n")
    }
}

struct ODTSection: Sendable {
    let name: String?
    let styleName: String?
    let blocks: [ODTTextBlock]

    init(node: ODFXMLNode) {
        name = node.attribute("name", namespace: .text)
        styleName = node.attribute("style-name", namespace: .text)
        blocks = ODTContentDecoder.blocks(from: node)
    }

    var plainText: String {
        blocks.map(\.plainText).joined(separator: "\n")
    }
}

indirect enum ODTTextBlock: Sendable {
    case paragraph(ODTParagraph)
    case heading(ODTHeading)
    case list(ODTList)
    case table(ODTTable)
    case section(ODTSection)
    case trackedChanges(ODFXMLNode)
    case generic(ODFXMLNode)

    var plainText: String {
        switch self {
        case .paragraph(let paragraph):
            return paragraph.plainText
        case .heading(let heading):
            return heading.plainText
        case .list(let list):
            return list.plainText
        case .table(let table):
            return table.plainText
        case .section(let section):
            return section.plainText
        case .trackedChanges:
            return ""
        case .generic(let node):
            return node.normalizedText
        }
    }
}

enum ODTContentDecoder {
    static func inlineNodes(from node: ODFXMLNode) -> [ODTInlineNode] {
        node.children.compactMap { child in
            switch child {
            case .text(let text):
                guard !text.isEmpty else { return nil }
                return .text(text)
            case .element(let element):
                guard element.name.namespaceURI == ODFNamespace.text.rawValue else {
                    return .generic(element)
                }

                switch element.name.localName {
                case "span":
                    return .span(
                        ODTInlineSpan(
                            styleName: element.attribute("style-name", namespace: .text),
                            content: inlineNodes(from: element)
                        )
                    )
                case "a":
                    return .link(
                        ODTLink(
                            href: element.attribute("href", namespace: .xlink),
                            styleName: element.attribute("style-name", namespace: .text),
                            visitedStyleName: element.attribute("visited-style-name", namespace: .text),
                            content: inlineNodes(from: element)
                        )
                    )
                case "line-break":
                    return .lineBreak
                case "tab":
                    return .tab
                case "s":
                    let count = Int(element.attribute("c", namespace: .text) ?? "1") ?? 1
                    return .spaces(count)
                case "note":
                    let citation = element.firstChild("note-citation", namespace: .text)?.normalizedText ?? ""
                    return .noteCitation(citation)
                default:
                    return .generic(element)
                }
            }
        }
    }

    static func blocks(from node: ODFXMLNode) -> [ODTTextBlock] {
        node.elementChildren.map(block)
    }

    static func block(from node: ODFXMLNode) -> ODTTextBlock {
        guard let namespace = node.name.namespaceURI else {
            return .generic(node)
        }

        if namespace == ODFNamespace.text.rawValue {
            switch node.name.localName {
            case "p":
                return .paragraph(ODTParagraph(node: node))
            case "h":
                return .heading(ODTHeading(node: node))
            case "list":
                return .list(ODTList(node: node))
            case "section":
                return .section(ODTSection(node: node))
            case "tracked-changes":
                return .trackedChanges(node)
            default:
                return .generic(node)
            }
        }

        if namespace == ODFNamespace.table.rawValue, node.name.localName == "table" {
            return .table(ODTTable(node: node))
        }

        return .generic(node)
    }
}

struct ODTTextBody: Sendable {
    let node: ODFXMLNode
    let blocks: [ODTTextBlock]

    init(node: ODFXMLNode) {
        self.node = node
        self.blocks = ODTContentDecoder.blocks(from: node)
    }

    var plainText: String {
        blocks
            .map(\.plainText)
            .filter { !$0.isEmpty }
            .joined(separator: "\n")
    }

    static func plainTextDocument(_ text: String) -> ODTTextBody {
        let paragraphs = text
            .components(separatedBy: .newlines)
            .map { line -> ODFXMLNode in
                let paragraphName = ODFQualifiedName(
                    localName: "p",
                    prefix: ODFNamespace.text.preferredPrefix,
                    namespaceURI: ODFNamespace.text.rawValue
                )
                return ODFXMLNode(name: paragraphName, children: [.text(line)])
            }

        let textNode = ODFXMLNode(
            name: ODFQualifiedName(
                localName: "text",
                prefix: ODFNamespace.office.preferredPrefix,
                namespaceURI: ODFNamespace.office.rawValue
            ),
            children: paragraphs.map { .element($0) }
        )
        return ODTTextBody(node: textNode)
    }
}

struct ODTDocumentMetadata: Sendable {
    let title: String?
    let subject: String?
    let description: String?
    let creator: String?
    let initialCreator: String?
    let keywords: [String]
    let language: String?
    let creationDate: String?
    let date: String?
    let editingDuration: String?
    let editingCycles: Int?

    init(rootNode: ODFXMLNode) {
        let metaNode = rootNode.firstChild("meta", namespace: .office)

        title = metaNode?.firstChild("title", namespace: .dc)?.normalizedText
        subject = metaNode?.firstChild("subject", namespace: .dc)?.normalizedText
        description = metaNode?.firstChild("description", namespace: .dc)?.normalizedText
        creator = metaNode?.firstChild("creator", namespace: .dc)?.normalizedText
        initialCreator = metaNode?.firstChild("initial-creator", namespace: .meta)?.normalizedText
        keywords = metaNode?.childElements("keyword", namespace: .meta).map(\.normalizedText) ?? []
        language = metaNode?.firstChild("language", namespace: .dc)?.normalizedText
        creationDate = metaNode?.firstChild("creation-date", namespace: .meta)?.normalizedText
        date = metaNode?.firstChild("date", namespace: .dc)?.normalizedText
        editingDuration = metaNode?.firstChild("editing-duration", namespace: .meta)?.normalizedText
        editingCycles = metaNode?.firstChild("editing-cycles", namespace: .meta)?.normalizedText.flatMap(Int.init)
    }
}

struct ODTStyle: Sendable {
    let family: String?
    let name: String?
    let displayName: String?
    let parentStyleName: String?
    let nextStyleName: String?
    let node: ODFXMLNode
}

struct ODTStylesCatalog: Sendable {
    let styles: [ODTStyle]
    let automaticStyles: [ODTStyle]
    let masterPages: [ODFXMLNode]
    let fontFaces: [ODFXMLNode]

    init(rootNode: ODFXMLNode) {
        styles = ODTStylesCatalog.extractStyles(named: "styles", from: rootNode)
        automaticStyles = ODTStylesCatalog.extractStyles(named: "automatic-styles", from: rootNode)
        masterPages = rootNode.firstChild("master-styles", namespace: .office)?.elementChildren ?? []
        fontFaces = rootNode.firstChild("font-face-decls", namespace: .office)?.elementChildren ?? []
    }

    private static func extractStyles(named containerName: String, from rootNode: ODFXMLNode) -> [ODTStyle] {
        rootNode.firstChild(containerName, namespace: .office)?.elementChildren.map { node in
            ODTStyle(
                family: node.attribute("family", namespace: .style),
                name: node.attribute("name", namespace: .style),
                displayName: node.attribute("display-name", namespace: .style),
                parentStyleName: node.attribute("parent-style-name", namespace: .style),
                nextStyleName: node.attribute("next-style-name", namespace: .style),
                node: node
            )
        } ?? []
    }
}

struct ODTOfficeDocument: Sendable {
    let rootNode: ODFXMLNode
    let version: String?
    let styles: ODTStylesCatalog

    init(rootNode: ODFXMLNode) throws {
        guard rootNode.name.localName.hasPrefix("document"),
              rootNode.name.namespaceURI == ODFNamespace.office.rawValue else {
            throw ODTError.invalidDocumentRoot(rootNode.name.rawName)
        }
        self.rootNode = rootNode
        self.version = rootNode.attribute("version", namespace: .office)
        self.styles = ODTStylesCatalog(rootNode: rootNode)
    }

    var textBody: ODTTextBody? {
        rootNode
            .firstChild("body", namespace: .office)?
            .firstChild("text", namespace: .office)
            .map(ODTTextBody.init)
    }

    func replacingTextBody(with newBody: ODTTextBody) -> ODTOfficeDocument {
        guard let bodyNode = rootNode.firstChild("body", namespace: .office) else {
            return self
        }
        let updatedBodyNode = bodyNode.updatingFirstChild("text", namespace: .office, with: newBody.node)
        let updatedRoot = rootNode.updatingFirstChild("body", namespace: .office, with: updatedBodyNode)
        return try! ODTOfficeDocument(rootNode: updatedRoot)
    }
}

struct ODFPackage: Sendable {
    var entries: [String: Data]

    init(fileURL: URL) throws {
        guard let archive = Archive(url: fileURL, accessMode: .read) else {
            throw ODTError.invalidArchive
        }

        var loadedEntries: [String: Data] = [:]
        for entry in archive {
            var data = Data()
            _ = try archive.extract(entry) { chunk in
                data.append(chunk)
            }
            loadedEntries[entry.path] = data
        }
        entries = loadedEntries
    }

    init(entries: [String: Data]) {
        self.entries = entries
    }

    func data(for path: String) -> Data? {
        entries[path]
    }
}

struct ODTFile: Sendable {
    static let textDocumentMimetype = "application/vnd.oasis.opendocument.text"

    let fileURL: URL
    var package: ODFPackage
    let mimetype: String
    let manifest: ODTManifest
    var contentDocument: ODTOfficeDocument
    let stylesDocument: ODTOfficeDocument
    let metaDocument: ODFXMLNode
    let settingsDocument: ODFXMLNode?

    init(fileURL: URL) throws {
        try self.init(package: ODFPackage(fileURL: fileURL), fileURL: fileURL)
    }

    init(package: ODFPackage, fileURL: URL = URL(fileURLWithPath: "/tmp/document.odt")) throws {
        self.fileURL = fileURL
        self.package = package

        guard let mimetypeData = package.data(for: "mimetype"),
              let mimetype = String(data: mimetypeData, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines),
              !mimetype.isEmpty else {
            throw ODTError.missingRequiredEntry("mimetype")
        }

        guard mimetype == Self.textDocumentMimetype else {
            throw ODTError.unsupportedMimetype(mimetype)
        }

        self.mimetype = mimetype

        let manifestRoot = try Self.parseXMLDocument(at: "META-INF/manifest.xml", from: package)
        manifest = try ODTManifest(rootNode: manifestRoot)

        contentDocument = try ODTOfficeDocument(
            rootNode: Self.parseXMLDocument(at: "content.xml", from: package)
        )
        stylesDocument = try ODTOfficeDocument(
            rootNode: Self.parseXMLDocument(at: "styles.xml", from: package)
        )
        metaDocument = try Self.parseXMLDocument(at: "meta.xml", from: package)
        settingsDocument = try package.data(for: "settings.xml").map(ODFXMLParser.parse(data:))
    }

    var metadata: ODTDocumentMetadata {
        ODTDocumentMetadata(rootNode: metaDocument)
    }

    var styles: ODTStylesCatalog {
        stylesDocument.styles
    }

    var textBody: ODTTextBody? {
        contentDocument.textBody
    }

    var plainText: String {
        textBody?.plainText ?? ""
    }

    var resources: [String: Data] {
        package.entries.filter { path, _ in
            !Self.corePackageEntries.contains(path)
        }
    }

    mutating func replacePlainText(with text: String) {
        let newBody = ODTTextBody.plainTextDocument(text)
        contentDocument = contentDocument.replacingTextBody(with: newBody)
        package.entries["content.xml"] = serializedContentXML().data(using: .utf8)
    }

    func serializedContentXML() -> String {
        Self.xmlDocumentString(for: contentDocument.rootNode)
    }

    func serializedStylesXML() -> String {
        Self.xmlDocumentString(for: stylesDocument.rootNode)
    }

    func serializedMetaXML() -> String {
        Self.xmlDocumentString(for: metaDocument)
    }

    func serializedSettingsXML() -> String? {
        settingsDocument.map(Self.xmlDocumentString(for:))
    }

    func write(to destinationURL: URL) throws {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: destinationURL.path) {
            try fileManager.removeItem(at: destinationURL)
        }

        guard let archive = Archive(url: destinationURL, accessMode: .create) else {
            throw ODTError.invalidArchive
        }

        var updatedEntries = package.entries
        updatedEntries["mimetype"] = Data(mimetype.utf8)
        updatedEntries["content.xml"] = Data(serializedContentXML().utf8)
        updatedEntries["styles.xml"] = Data(serializedStylesXML().utf8)
        updatedEntries["meta.xml"] = Data(serializedMetaXML().utf8)
        if let settingsXML = serializedSettingsXML() {
            updatedEntries["settings.xml"] = Data(settingsXML.utf8)
        }

        let orderedPaths = updatedEntries.keys.sorted {
            if $0 == "mimetype" { return true }
            if $1 == "mimetype" { return false }
            return $0 < $1
        }

        for path in orderedPaths {
            guard let data = updatedEntries[path] else { continue }
            let compressionMethod: CompressionMethod = path == "mimetype" ? .none : .deflate
            try archive.addEntry(
                with: path,
                type: .file,
                uncompressedSize: UInt32(data.count),
                compressionMethod: compressionMethod,
                provider: { position, size in
                    data.subdata(in: Int(position)..<Int(position + size))
                }
            )
        }
    }

    private static let corePackageEntries: Set<String> = [
        "mimetype",
        "META-INF/manifest.xml",
        "content.xml",
        "styles.xml",
        "meta.xml",
        "settings.xml"
    ]

    private static func parseXMLDocument(at path: String, from package: ODFPackage) throws -> ODFXMLNode {
        guard let data = package.data(for: path) else {
            throw ODTError.missingRequiredEntry(path)
        }
        return try ODFXMLParser.parse(data: data)
    }

    private static func xmlDocumentString(for rootNode: ODFXMLNode) -> String {
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" + rootNode.xmlString()
    }
}
