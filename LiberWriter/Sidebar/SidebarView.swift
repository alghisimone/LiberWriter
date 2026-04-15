//
//  SidebarView.swift
//  LiberWriter
//
//  Created by Simone Alghisi on 09/03/23.
//

import SwiftUI

struct SidebarView: View {
    
    @Binding var selectedSidebarSegment: Int

    
    var body: some View {
        NavigationStack {
            Picker(selection: $selectedSidebarSegment, label: Image("")) {
                Image(systemName: "paintbrush").tag(0).help("Formatting")
                Image(systemName: "doc").tag(1).help("Page Setup")
                Image(systemName: "eye").tag(2).help("View")
                Image(systemName: "paintpalette").tag(3).help("Styles")
                Image(systemName: "highlighter").tag(4).help("Review")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding([.horizontal,.top]).buttonStyle(.bordered)
            Divider()
            ScrollView(.vertical) {
                    switch selectedSidebarSegment {
                    case 0:
                        FormattingSidebar()
                    case 1:
                        PageSetupSidebar()
                    case 2:
                        ViewSidebar()
                    case 3:
                        StylesSidebar()
                    case 4:
                        ReviewSidebar()

                        
                    default:
                        FormattingSidebar()
                    }
            }.padding([.leading, .trailing])
        }
        }

    }
