//
//  LiberWriterApp.swift
//  LiberWriter
//
//  Created by Simone Alghisi on 09/03/23.
//

import SwiftUI

@main
struct LiberWriterApp: App {
    
    @StateObject var userSettings = UserSettings()

    var body: some Scene {
        DocumentGroup(newDocument: LiberWriterDocument()) { file in
            MainView()
                .environmentObject(userSettings)
        }
        .commands {
            MainMenu()
        }
    }
}


class UserSettings: ObservableObject {
    @Published var showingSidebar = true
    @Published var showSecondaryToolbar = false
    @Published var showOnboarding = true
}
