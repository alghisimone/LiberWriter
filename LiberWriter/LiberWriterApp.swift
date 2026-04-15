import SwiftUI
import UniformTypeIdentifiers

@main
struct LiberWriterApp: App {
    @EnvironmentObject var userSettings: UserSettings // Added environment object

    @State private var selectedFileURL: URL?
    @State private var isValidODT: Bool = false
    @State private var showFilePicker = false
    
    var body: some Scene {
        WindowGroup {
            if isValidODT, let fileURL = selectedFileURL {
                MainView(fileURL: fileURL) // Show MainView with a placeholder for now
            } else {
                VStack {
                    Button("Open ODT File") {
                        showFilePicker = true
                    }
                    .fileImporter(
                        isPresented: $showFilePicker,
                        allowedContentTypes: [UTType(filenameExtension: "odt")!]
                    ) { result in
                        switch result {
                        case .success(let url):
                            selectedFileURL = url
                            isValidODT = validateODTFile(url) // Validate the file
                            print("Selected ODT file: \(url)")
                            print("\(url) is a valid ODT file")
                        case .failure(let error):
                            print("Error selecting file: \(error.localizedDescription)")
                        }
                    }
                    if let selectedFileURL = selectedFileURL, !isValidODT {
                        Text("Invalid ODT file").foregroundColor(.red)
                    }
                }
            }
        }.commands(content: {
            MainMenu()
        })
    }
    
    
    
    private func validateODTFile(_ url: URL) -> Bool {
        // Simple validation: Check if the file has an .odt extension
        return url.pathExtension.lowercased() == "odt"
    }
}
