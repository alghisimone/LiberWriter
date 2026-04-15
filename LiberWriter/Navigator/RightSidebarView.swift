//
//  RightSidebarView.swift
//  LiberWriter
//
//  Created by Simone Alghisi on 21/03/2025.
//


import SwiftUI

struct RightSidebarView: View {
    
    @Binding var selectedNavigatorSegment: Int

    var body: some View {
        NavigationStack {
            Picker(selection: $selectedNavigatorSegment, label: Image("")) {
                Image(systemName: "doc").tag(0).help("Navigate by Page")
                Image(systemName: "list.bullet.indent").tag(1).help("Navige by Heading")
                Image(systemName: "2x2grid").tag(2).help("case 2")
                Image(systemName: "3x3grid").tag(3).help("case 3")
                Image(systemName: "text.bubble").tag(4).help("Navigate by comment")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding([.horizontal,.top])
            Divider().padding(.bottom)
            ScrollView(.vertical) {
                    switch selectedNavigatorSegment {
                    case 0:
                        Text("Navigate this document by page")
                    case 1:
                        Text("Navigate this document by heading")
                    case 2:
                        Text("Navigate by case 2")
                    case 3:
                        Text("Navigate by case 3")
                    case 4:
                        Text("Comments in this document")

                        
                    default:
                        FormattingSidebar()
                    }
            }.padding([.leading, .trailing])
        }
        }
        }
