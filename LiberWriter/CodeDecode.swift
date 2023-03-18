//
//  CodeDecode.swift
//  LiberWriter
//
//  Created by Simone Alghisi on 11/03/23.
//

import Foundation
import XMLCoder


func DecodeXMLMeta() throws {
    
    let metaXML = metadata
    
    // Load the XML data from a file or string
    let xmlFile = """
<office:document-meta xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xlink="http://www.w3.org/1999/xlink" office:version="1.2"><office:meta><meta:generator>MicrosoftOffice/15.0 MicrosoftWord</meta:generator><dc:title>Costituzione della Repubblica insuliana</dc:title><dc:subject>Costituzione federale della Repubblica insuliana</dc:subject><meta:initial-creator>Simone Alghisi</meta:initial-creator><dc:creator>Simone Alghisi</dc:creator><meta:creation-date>2020-07-15T07:10:00Z</meta:creation-date><dc:date>2023-03-03T12:07:00Z</dc:date><meta:template xlink:href="Normal.dotm" xlink:type="simple"/><meta:editing-cycles>1</meta:editing-cycles><meta:editing-duration>PT581580S</meta:editing-duration><meta:user-defined meta:name="Act">L</meta:user-defined><meta:user-defined meta:name="FU" meta:value-type="date">2020-09-19T00:00:00Z</meta:user-defined><meta:user-defined meta:name="Number" meta:value-type="float">45</meta:user-defined><meta:user-defined meta:name="Year" meta:value-type="float">2020</meta:user-defined><meta:document-statistic meta:page-count="53" meta:paragraph-count="186" meta:word-count="13918" meta:character-count="93071" meta:row-count="661" meta:non-whitespace-character-count="79339"/></office:meta></office:document-meta>
"""
    
    guard let xmlData = xmlFile.data(using: .utf8) else {
        fatalError("Unable to convert XML string to data")
    }
    
    // Create an instance of the XMLDecoder class
    let decoder = XMLDecoder()
    
    // Set the decoding strategy to use for element names
    decoder.keyDecodingStrategy = .convertFromKebabCase
    
    // Decode the XML data into the desired type(s)
    let office = try decoder.decode(OfficeMeta.self, from: xmlData)
    
    // Access the decoded values
    print(office.generator) // "MicrosoftOffice/15.0 MicrosoftWord"
    print(office.dcTitle) // "Costituzione della Repubblica insuliana"
    print(office.dcCreator) // "Simone Alghisi"
    print(office.dcDate) // "2023-03-03T12:07:00Z"
    print(office.documentStatistic.metaPageCount) // 53
    print(office.documentStatistic.metaWordCount) // 13918
    
}
