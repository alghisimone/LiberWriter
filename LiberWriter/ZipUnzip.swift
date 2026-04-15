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

struct ZipUnzipODT: View {
    @State var selectedFileURL: URL?
    @State private var showAlert = false
    
    var body: some View {
        VStack {
            Button("Select ODT File") {
                openFilePicker()
            }
        }
        .alert("ODT File Opened", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        }
    }
    
    private func openFilePicker() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [UTType(filenameExtension: "odt")!]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        
        if panel.runModal() == .OK, let url = panel.url {
            selectedFileURL = url
            do {
                let odtFile = try ODTFile(fileURL: url)
                print("Content XML: \(odtFile.contentXML.prefix(100))...")
                print("Styles XML: \(odtFile.stylesXML.prefix(100))...")
                print("Meta XML: \(odtFile.metaXML.prefix(100))...")
                
                showAlert = true
            } catch {
                print("Failed to open ODT file: \(error.localizedDescription)")
            }
        }
    }
}

struct ZipUnzipODT_Previews: PreviewProvider {
    static var previews: some View {
        ZipUnzipODT()
    }
}
