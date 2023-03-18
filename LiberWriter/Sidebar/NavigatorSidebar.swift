//
//  NavigatorSidebar.swift
//  LiberWriter
//
//  Created by Simone Alghisi on 09/03/23.
//

import SwiftUI

struct NavigatorSidebar: View {
    
    @EnvironmentObject var userSettings: UserSettings

    var body: some View {
        HStack {
            // show navigation controls here
            Button(action: {
                // do something
            }) {
                Text("Go to beginning")
            }
            .padding(.vertical, 5)
            
            Button(action: {
                // do something
            }) {
                Text("Go to end")
            }
            .padding(.vertical, 5)
        }
    }
}

struct NavigatorSidebar_Previews: PreviewProvider {
    static var previews: some View {
        NavigatorSidebar()
    }
}
