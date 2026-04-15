import SwiftUI

struct MainView: View {
    let fileURL: URL // Added fileURL to store the document location
    @EnvironmentObject var userSettings: UserSettings // Added environment object
    
    @State private var isLeftSidebarVisible: Bool = true
    @State private var columnVisibility = NavigationSplitViewVisibility.doubleColumn
    @State private var isSecondaryToolbarVisible: Bool = false
    
    @State private var selectedSidebarSegment: Int = 0
    @State private var selectedNavigatorSegment: Int = 0
    
    var body: some View {
        
        NavigationSplitView {
            RightSidebarView(selectedNavigatorSegment: $selectedNavigatorSegment).frame(minWidth: 200, maxWidth: 300)
        } content: {
            DocumentView().toolbar(content: {
                ToolbarItem(placement: .automatic) {
                    Button("Save") {
                        print("Save action triggered")
                    }
                }
                ToolbarItem(placement: .automatic) {
                    Button("Export") {
                        print("Export action triggered")
                    }
                }
                ToolbarItem(placement: .automatic) {
                    Button("Print") {
                        print("Print action triggered")
                    }
                }
            })
        } detail: {
            SidebarView(selectedSidebarSegment: $selectedSidebarSegment).frame(minWidth: 300, maxWidth: 500)
        }
    }
}



        

