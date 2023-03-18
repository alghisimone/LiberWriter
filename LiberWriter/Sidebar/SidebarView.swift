//
//  SidebarView.swift
//  LiberWriter
//
//  Created by Simone Alghisi on 09/03/23.
//

import SwiftUI

struct SidebarView: View {
    @Binding var selectedSegment: Int
    @EnvironmentObject var userSettings: UserSettings
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                    switch selectedSegment {
                    case 0:
                        FormattingSidebar()
                    case 1:
                        StylesSidebar()
                    case 2:
                        NavigatorSidebar()
                    case 3:
                        FourthSegmentSidebar()
                    default:
                        Text("Invalid selection")
                    }
            }.padding(.leading).padding(.trailing).padding(.top)
        }
        .environmentObject(userSettings)
        .frame(minWidth: 300, maxWidth: 450) // adjust the width to match the width of the sidebar
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction){
                
                    Picker(selection: $selectedSegment, label: Image("")) {
                        Image(systemName: "paintbrush").tag(0).help("Formatting")
                        Image(systemName: "textformat").tag(1).help("Styles")
                        Image(systemName: "helm").tag(2).help("Navigator")
                        Image(systemName: "pencil").tag(3)
                    }.frame(width: 250)
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 10)
            }
            }
        }

    }
