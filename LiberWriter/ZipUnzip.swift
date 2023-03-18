//
//  ZipUnzip.swift
//  LiberWriter
//
//  Created by Simone Alghisi on 13/03/23.
//

import Foundation
import SwiftUI
import ZIPFoundation
import UniformTypeIdentifiers

public let fileManager = FileManager()
public let tempFolder = fileManager.temporaryDirectory
public let appBundle = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
public var tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(appBundle)
public var tempCopies = tempURL.appendingPathComponent("ODT ZIPs")
public var tempStorage = tempURL.appendingPathComponent("Extracted documents")
public let openPanel = NSOpenPanel()




// FILE PICKER PANEL

public func presentFilePickerAndLoadDocument() {
    
    @ObservedObject var document: Document
    
    openPanel.allowedContentTypes = [UTType.openDocumentText]
    openPanel.canChooseDirectories = false
    openPanel.allowsMultipleSelection = false
    openPanel.begin { result in
        if result == .OK {
            guard let selectedFileUrl = openPanel.urls.first else { return }
            document.load(from: selectedFileUrl)
            
        }
    }
}


// FILE ZIPPING AND UNZIPPING


func unzipFile() {
    
    var chosenFile = openPanel.url
    var copyToUnzip = tempCopies.appendingPathComponent("\(String(describing: chosenFile)).zip")
    var unzippedFile = tempStorage.appendingPathComponent("\(String(describing: chosenFile))")
    do {
        
        try fileManager.createDirectory(at: tempCopies, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: tempStorage, withIntermediateDirectories: true)
        try fileManager.copyItem(at: chosenFile!, to: copyToUnzip)
        try fileManager.unzipItem(at: copyToUnzip, to: unzippedFile)
        
        print("XML estraction successful!")
        print("Temp zip copy of your file is available at this address until you close LiberWriter: \(tempCopies)")
        print("Temp extracted file is available at this address until you close LiberWriter: \(tempStorage)")
        
    } catch {
        
        print("XML extraction FAILED! (Check permissions?)")
        print("Any temp zip copy (if any) of the original ODT you selected is available at this address until you close LiberWriter: \(tempCopies)")
        print("Any temp extracted and partially extracted file (if any) is available at this address until you close LiberWriter: \(tempStorage)")
    }
}


func deleteTemps() {
    do {
        try fileManager.removeItem(atPath: "\(tempURL)/*")
        print("Purged LiberWriter temp files at: \(tempURL).")

    } catch {
        print("Couldn't delete temp files! (Permissions?)")
        print("To delete them manually, temp folder is located at: \(tempURL)")
    }
}
