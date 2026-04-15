//
//  LiberWriterTests.swift
//  LiberWriterTests
//
//  Created by Simone Alghisi on 09/03/23.
//

import Foundation
import XCTest
@testable import LiberWriter

final class LiberWriterTests: XCTestCase {
    func testODTFileParsesStructuredTextContent() throws {
        let document = try ODTFile(package: samplePackage())

        XCTAssertEqual(document.mimetype, ODTFile.textDocumentMimetype)
        XCTAssertEqual(document.metadata.title, "Sample Document")
        XCTAssertEqual(document.metadata.creator, "LiberWriter Tests")
        XCTAssertEqual(document.styles.styles.count, 1)
        XCTAssertTrue(document.resources.keys.contains("Pictures/example.png"))

        let blocks = document.textBody?.blocks ?? []
        XCTAssertEqual(blocks.count, 4)
        XCTAssertEqual(document.plainText, """
        Heading
        First paragraph with emphasis.
        1. Item one
        2. Item two
        Cell 1\tCell 2
        """)
    }

    func testODTFileCanReplaceEditablePlainText() throws {
        var document = try ODTFile(package: samplePackage())

        document.replacePlainText(with: "Alpha\nBeta")

        XCTAssertEqual(document.plainText, "Alpha\nBeta")
        XCTAssertTrue(document.contentXML.contains("<text:p>Alpha</text:p>"))
        XCTAssertTrue(document.contentXML.contains("<text:p>Beta</text:p>"))
    }

    private func samplePackage() -> ODFPackage {
        ODFPackage(entries: [
            "mimetype": Data(ODTFile.textDocumentMimetype.utf8),
            "META-INF/manifest.xml": Data(manifestXML.utf8),
            "content.xml": Data(contentXML.utf8),
            "styles.xml": Data(stylesXML.utf8),
            "meta.xml": Data(metaXML.utf8),
            "Pictures/example.png": Data([0x89, 0x50, 0x4E, 0x47])
        ])
    }

    private let manifestXML = """
    <?xml version="1.0" encoding="UTF-8"?>
    <manifest:manifest xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0" manifest:version="1.3">
        <manifest:file-entry manifest:full-path="/" manifest:media-type="application/vnd.oasis.opendocument.text"/>
        <manifest:file-entry manifest:full-path="content.xml" manifest:media-type="text/xml"/>
        <manifest:file-entry manifest:full-path="styles.xml" manifest:media-type="text/xml"/>
        <manifest:file-entry manifest:full-path="meta.xml" manifest:media-type="text/xml"/>
        <manifest:file-entry manifest:full-path="Pictures/example.png" manifest:media-type="image/png"/>
    </manifest:manifest>
    """

    private let contentXML = """
    <?xml version="1.0" encoding="UTF-8"?>
    <office:document-content
        xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
        xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
        xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0"
        xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
        xmlns:xlink="http://www.w3.org/1999/xlink"
        office:version="1.3">
        <office:automatic-styles/>
        <office:body>
            <office:text>
                <text:h text:outline-level="1">Heading</text:h>
                <text:p>First paragraph with <text:span text:style-name="Emphasis">emphasis</text:span>.</text:p>
                <text:list>
                    <text:list-item>
                        <text:p>Item one</text:p>
                    </text:list-item>
                    <text:list-item>
                        <text:p>Item two</text:p>
                    </text:list-item>
                </text:list>
                <table:table table:name="Table1">
                    <table:table-row>
                        <table:table-cell><text:p>Cell 1</text:p></table:table-cell>
                        <table:table-cell><text:p>Cell 2</text:p></table:table-cell>
                    </table:table-row>
                </table:table>
            </office:text>
        </office:body>
    </office:document-content>
    """

    private let stylesXML = """
    <?xml version="1.0" encoding="UTF-8"?>
    <office:document-styles
        xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
        xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
        office:version="1.3">
        <office:styles>
            <style:style style:name="Standard" style:family="paragraph"/>
        </office:styles>
        <office:automatic-styles/>
        <office:master-styles/>
    </office:document-styles>
    """

    private let metaXML = """
    <?xml version="1.0" encoding="UTF-8"?>
    <office:document-meta
        xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
        xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0"
        xmlns:dc="http://purl.org/dc/elements/1.1/"
        office:version="1.3">
        <office:meta>
            <dc:title>Sample Document</dc:title>
            <dc:creator>LiberWriter Tests</dc:creator>
            <meta:initial-creator>LiberWriter Tests</meta:initial-creator>
            <meta:keyword>sample</meta:keyword>
        </office:meta>
    </office:document-meta>
    """
}
