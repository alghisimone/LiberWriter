//
//  QuickFormatTable.swift
//  LiberWriter
//
//  Created by Simone Alghisi on 10/03/23.
//

import SwiftUI



struct QuickFormatTable: View {
    
    @EnvironmentObject var userSettings: UserSettings


    var body: some View {
        
            Image(systemName: "tablecells").foregroundColor(.accentColor)
        Text("Table:").foregroundColor(.accentColor)
            Divider()
            ScrollView(.horizontal){
                
                HStack{
                    Button(action: {
                        // Add your action here
                    }) {
                        Label("Font", systemImage: "textformat")
                    }.environmentObject(userSettings).buttonStyle(.plain)
                    
                    Button(action: {
                        // Add your action here
                    }) {
                        Label("Color", systemImage: "eyedropper")
                    }.environmentObject(userSettings).buttonStyle(.plain)
                        .disabled(true)
                    
                    
                    
                    
                    
                    
                    
                    Spacer()
                    Divider()
                    Button(action: {}) {
                        Label("More Options", systemImage: "ellipsis")
                    }.buttonStyle(.bordered).help("Shows the Table Options window for more precise controls")
                    
                }
            }.environmentObject(userSettings)
            
            
        }
        
        
    }

struct QuickFormatTable_Previews: PreviewProvider {
    static var previews: some View {
        QuickFormatTable()
    }
}
