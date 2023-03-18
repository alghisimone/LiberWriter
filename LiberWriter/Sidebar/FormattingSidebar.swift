//
//  FormattingSidebar.swift
//  LiberWriter
//
//  Created by Simone Alghisi on 09/03/23.
//

import SwiftUI


struct FormattingSidebar: View {
    
    @EnvironmentObject var userSettings: UserSettings
    
    @State var groupOneIsExpanded = true
    @State var groupTwoIsExpanded = false

    var body: some View {
        
            DisclosureGroup(isExpanded: $groupOneIsExpanded, content: {
                
                Button("Test") {
                    
                }
                
            }, label: {
                HStack{
                    Image(systemName: "paintbrush.fill").foregroundColor(.accentColor)
                    Text("Main").bold()
                }
            })
        
        
        DisclosureGroup(isExpanded: $groupTwoIsExpanded, content: {
            
            Button("Test2") {
                
            }
            
        }, label: {
            HStack{
                Image(systemName: "paragraph").foregroundColor(.accentColor)
                Text("Paragraph").bold()
            }
        })
        
        }
}

struct FormattingSidebar_Previews: PreviewProvider {
    static var previews: some View {
        FormattingSidebar()
    }
}
