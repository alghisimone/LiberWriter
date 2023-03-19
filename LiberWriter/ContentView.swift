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
    @ObservedObject var documentData = DocumentData()
    @ObservedObject var documentContents = DocumentContents()
    
    var body: some View {
        VStack {
            Button("Open File") {
                presentFilePickerAndLoadDocument()
            }
            
            TextEditor(text: $content)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}
