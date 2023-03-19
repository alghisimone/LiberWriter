//
//  CodeDecode.swift
//  LiberWriter
//
//  Created by Simone Alghisi on 11/03/23.
//

import Foundation
import XMLCoder


func DecodeXMLMeta() throws {
    
    /// Here there is no var or let to reference the meta.xml file since it has been set in the ZipUnzip and passed to DocumentData class in ODTDocument (or it should be, at least)
    
    // Create an instance of the XMLDecoder class
    let decoder = XMLDecoder()
    
    // Set the decoding strategy to use for element names
    decoder.keyDecodingStrategy = .convertFromKebabCase
    decoder.shouldProcessNamespaces = true
    
    // Decode the XML data into the desired type(s)
    
    guard var meta = try decoder.decode(<#T##type: Decodable.Protocol##Decodable.Protocol#>, from: DocumentData().metaXML) else {
        fatalError("Unable to get meta.xml of ODT bundle")
    }
    
    // Access the decoded values
    print("Loading document:")
    print("")
    print("Generator: \(meta.generator)") // "MicrosoftOffice/15.0 MicrosoftWord"
    print("Title: \(meta.dcTitle)") // "Costituzione della Repubblica insuliana"
    print("Creator: \(meta.dcCreator)") // "Simone Alghisi"
    print("Date: \(meta.dcDate)") // "2023-03-03T12:07:00Z"
    print("Page count: \(meta.documentStatistic.metaPageCount)") // 53
    print("Word count: \(meta.documentStatistic.metaWordCount)") // 13918
    print("")
    
    DocumentContents().meta = meta
    
}
