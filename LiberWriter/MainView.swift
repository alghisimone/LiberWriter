//
//  MainView.swift
//  LiberWriter
//
//  Created by Simone Alghisi on 09/03/23.
//

import SwiftUI

struct MainView: View {
    
    @EnvironmentObject var userSettings: UserSettings
    
    
    @State var fileContent: String = ""
    @State var selectedSidebarSegment = 0
    
    
    
    
    
    var body: some View {
        HSplitView {
            workingArea.toolbar {
                ToolbarItemGroup{
                    Button(action: {
                                // Add your button action here
                            }) {
                                Label("Chart", systemImage: "chart.bar")
                    }
                    
                    Button(action: {
                        // Add your button action here
                    }) {
                        Label("Button 2", systemImage: "rectangle.and.pencil.and.ellipsis")
                    }
                }
                ToolbarItemGroup{
                    Button(action: {
                        print("Trying to show Quick Formatting from MenuBar. Is it shown?")
                        print(UserSettings().showSecondaryToolbar)
                        userSettings.showSecondaryToolbar.toggle()
                        print("Did I do that?")
                    }) {
                        Label("Button 1", systemImage: "wand.and.stars").help("Toggle Quick Formatting Toolbar")
                    }

                        Button(action: {
                            userSettings.showingSidebar.toggle()
                        }) {
                            Label("Hide Sidebar", systemImage: "sidebar.right").help("Toggle Sidebar")
                        }
                    Spacer()
                    }
                    
            }
            if userSettings.showingSidebar {
                SidebarView(selectedSegment: $selectedSidebarSegment).environmentObject(userSettings)
                
        }
                
            }.environmentObject(userSettings)
        
    }
    
    var workingArea: some View {
        ZStack(alignment: .top) {
            if userSettings.showSecondaryToolbar {
                secondaryToolbar.environmentObject(userSettings)
                    .background(Color(NSColor.windowBackgroundColor))
                    .zIndex(1)
                    .environmentObject(userSettings)
                TextEditor(text: $fileContent)
                    .frame(minWidth: 500, minHeight: 500).environmentObject(userSettings).environmentObject(userSettings)
                    .zIndex(0).offset(x: 0, y: 30)
            } else {
                // Content View
                TextEditor(text: $fileContent)
                    .frame(minWidth: 500, minHeight: 500).environmentObject(userSettings).environmentObject(userSettings)
                
                // Secondary Toolbar
            }
        }
    }
    
    var secondaryToolbar: some View {
        HStack {
            Button(action: {
                userSettings.showSecondaryToolbar.toggle()
            }) {
                Image(systemName: "xmark")
            }.environmentObject(userSettings)
                .buttonStyle(.borderless)
            QuickFormatTable()
            
        }.padding(.horizontal)
            .frame(maxHeight: 30)
    }
}
