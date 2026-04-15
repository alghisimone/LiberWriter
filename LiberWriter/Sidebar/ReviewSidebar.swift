//
//  SidebarReviewOptionsView.swift
//  LyberWriter
//
//  Created by Simone Alghisi on 02/12/2023.
//

import SwiftUI

struct ReviewSidebar: View {
    @State var ReviewTrackChangesExpand = false
    @State var ReviewTrackChangesToggle = false
    @State var changesTrackingColor = Color.red

    
    

    var body: some View {
        ScrollView(.vertical) {
            DisclosureGroup(
                isExpanded: $ReviewTrackChangesExpand,
                content: {
                    VStack{
                        HStack{
                            Text("Track Changes Made to This Document")
                            Toggle("Track Changes Toggle", isOn: $ReviewTrackChangesToggle).toggleStyle(.switch).labelsHidden()
                        }.padding(.bottom)
                        
                        ColorPicker(selection: $changesTrackingColor, label: {
                            Text("Higlight Changes in")
                        }).help("Color of Font for changes")
                        
                        Button(action: /*@START_MENU_TOKEN@*/ {}/*@END_MENU_TOKEN@*/, label: {
                            HStack {
                                Image(systemName: "questionmark.diamond")
                                Text("Resolve All Changes")
                            }
                        })}.padding([.top,.bottom])},
                label: { HStack {
                    Image(systemName: "highlighter").foregroundStyle(Color.accentColor)
                    Text("Track Changes")
                    Spacer()
                    if ReviewTrackChangesExpand == false {
                        Toggle("Track Changes Toggle", isOn: $ReviewTrackChangesToggle).toggleStyle(.switch).frame(alignment: .trailing).labelsHidden()
                    } else if ReviewTrackChangesExpand == true {
                        Button(action: {}, label: {Image(systemName: "arrow.up.forward.square")}).buttonStyle(.plain)
                    }
                }.bold() }
            )
            Divider()
            

        }.frame(alignment: .leading)
    }
}
