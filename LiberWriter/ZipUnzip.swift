//
//  ZipUnzip.swift
//  LiberWriter
//
//  Created by Simone Alghisi on 13/03/23.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers
import ZIPFoundation

public let appBundle = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
public var cacheURL = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
public var tempAppStorage = cacheURL.appendingPathComponent(appBundle)

public let openPanel = NSOpenPanel()

// FILE PICKER PANEL

public func presentFilePickerAndLoadDocument() {
    openPanel.allowedContentTypes = [UTType.openDocumentText]
    openPanel.canChooseDirectories = false
    openPanel.allowsMultipleSelection = false
    openPanel.begin { result in
        if result == .OK {
            guard let selectedFileUrl = openPanel.urls.first else { return }
            DocumentData().fileURL = selectedFileUrl
        }
    }
}

// FILE ZIPPING AND UNZIPPING

func unzipFile() {
    var chosenFile = DocumentData().fileURL
    var tempExpandedFile = tempAppStorage.appendingPathExtension(String(describing: chosenFile))
    do {
        try FileManager().createDirectory(at: tempExpandedFile, withIntermediateDirectories: true)
        try FileManager().unzipItem(at: chosenFile!, to: tempExpandedFile)

        print("XML estraction successful!")
        print("Temp extracted file is available at this address until you close LiberWriter: \(tempExpandedFile.path())")

    } catch {
        print("XML extraction FAILED! (Check permissions?)")
        print("Any temp extracted and partially extracted file (if any) is available at this address until you close LiberWriter: \(tempExpandedFile)")
    }
    
        var documentContentURL: URL?
        var documentStylesURL: URL?
        var documentMetaURL: URL?
        var documentSettingsURL: URL?
        var documentManifestURL: URL?
        var documentResourcesURL:URL?
    
    documentContentURL = tempExpandedFile.appending(component: "/content.xml")
}

func deleteTemps() {
    do {
        try FileManager().removeItem(atPath: "\(tempAppStorage.path())/*")
        print("Purged LiberWriter temp files at: \(tempAppStorage.path()).")

    } catch {
        print("Couldn't delete temp files! (Permissions?)")
        print("To delete them manually, temp folder is located at: \(tempAppStorage.path())")
    }
}
