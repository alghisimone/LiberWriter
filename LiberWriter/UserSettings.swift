//
//  UserSettings.swift
//  LiberWriter
//
//  Created by Simone Alghisi on 16/03/2025.
//

import SwiftUI

class UserSettings: ObservableObject {
    @Published var isLeftSidebarVisible: Bool = true
    @Published var isRightSidebarVisible: Bool = false
    @Published var isSecondarySidebarVisible: Bool = false
    @Published var windowSize: CGSize = CGSize(width: 800, height: 600)
    
    // Placeholder for future preferences
    @Published var placeholderSetting1: String = ""
    @Published var placeholderSetting2: Int = 0
}
