//
//  ContentView.swift
//  LiberWriter
//
//  Created by Simone Alghisi on 09/03/23.
//

import SwiftUI
import Foundation
import UniformTypeIdentifiers



struct ContentView: View {
    @EnvironmentObject var userSettings: UserSettings
    
    @State private var document: ODTDocument
    
    
    
    
    
    var body: some View {
        // pass the document to child views
        ChildView(document: $document)
        
        
        
        Button("Open File") {
            presentFilePickerAndLoadDocument()
        }
        Button("Save") {
                    saveDocument(document)
                }
            }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}
