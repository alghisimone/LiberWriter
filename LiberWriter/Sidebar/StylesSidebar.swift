//
//  StylesSidebar.swift
//  LiberWriter
//
//  Created by Simone Alghisi on 09/03/23.
//

import SwiftUI

struct StylesSidebar: View {
    
    @EnvironmentObject var userSettings: UserSettings

    var body: some View {
        HStack {
            // show style controls here
            Button(action: {
                // do something
            }) {
                Text("Title")
            }
            .padding(.vertical, 5)
            
            Button(action: {
                // do something
            }) {
                Text("Subtitle")
            }
            .padding(.vertical, 5)
        }
    }
}

struct StylesSidebar_Previews: PreviewProvider {
    static var previews: some View {
        StylesSidebar()
    }
}
