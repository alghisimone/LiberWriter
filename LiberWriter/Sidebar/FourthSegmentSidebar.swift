//
//  FourthSegmentSidebar.swift
//  LiberWriter
//
//  Created by Simone Alghisi on 09/03/23.
//

import SwiftUI

struct FourthSegmentSidebar: View {
    
    
    @EnvironmentObject var userSettings: UserSettings

    
    var body: some View {
        HStack {
            // show pencil controls here
            Button(action: {
                // do something
            }) {
                Text("Draw")
            }
            .padding(.vertical, 5)
            
            Button(action: {
                // do something
            }) {
                Text("Erase")
            }
            .padding(.vertical, 5)
        }
    }
}

struct FourthSegmentSidebar_Previews: PreviewProvider {
    static var previews: some View {
        FourthSegmentSidebar()
    }
}
