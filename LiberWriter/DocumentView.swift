//
//  DocumentView.swift
//  LiberWriter
//
//  Created by Simone Alghisi on 16/03/2025.
//


import SwiftUI

struct DocumentView: View {
    @State private var documentText: String = "This is where the document will be displayed and interacted with."
    
    var body: some View {
        VStack {
            TextEditor(text: $documentText)
                .padding()
                .border(Color.gray, width: 1)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle("Document Editor")
    }
}

struct DocumentView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentView()
    }
}
