//
//  LiberWriterApp.swift
//  LiberWriter
//
//  Created by Simone Alghisi on 09/03/23.
//

import SwiftUI

@main
struct LiberWriterApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: LiberWriterDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}
