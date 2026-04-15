//
//  WelcomeScreen.swift
//  LiberWriter
//
//  Created by Simone Alghisi on 22/03/2025.
//

import SwiftUI
import UniformTypeIdentifiers


struct WelcomeScreen: View {
    let fileURL: URL // Added fileURL to store the document location
    @EnvironmentObject var userSettings: UserSettings // Added environment object
    
    @State var selectedFileURL: URL?
    @State var isValidODT: Bool = false
    @State private var showFilePicker = false
    
    
    
    var body: some View {
        
        Button("Open ODT File") {
            showFilePicker = true
        }
        .fileImporter(
            isPresented: $showFilePicker,
            allowedContentTypes: [UTType(filenameExtension: "odt")!]
        ) { result in
            switch result {
            case .success(let url):
                selectedFileURL = url
                isValidODT = validateODTFile(url) // Validate the file
                print("Selected ODT file: \(url)")
                print("\(url) is a valid ODT file")
            case .failure(let error):
                print("Error selecting file: \(error.localizedDescription)")
            }
        }
        if let selectedFileURL = selectedFileURL, !isValidODT {
            Text("Invalid ODT file").foregroundColor(.red)
        }
    }
    
    private func validateODTFile(_ url: URL) -> Bool {
        // Simple validation: Check if the file has an .odt extension
        return url.pathExtension.lowercased() == "odt"
    }
}



        

