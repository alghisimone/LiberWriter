//
//  MainMenu.swift
//  LiberWriter
//
//  Created by Simone Alghisi on 09/03/23.
//

import SwiftUI

struct MainMenu: Commands {
    @EnvironmentObject var userSettings: UserSettings
    
    var body: some Commands {
        
        
        CommandMenu("Format") {
            Button("Character…", action: {
                // Add action here
            })
            Button("Paragraph…", action: {
                // Add action here
            })
            Button("Page…", action: {
                // Add action here
            })
            Divider()
            Button("Table…", action: {
                // Add action here
            })
            Button("Shape…", action: {
                // Add action here
            })
            Button("Picture…", action: {
                // Add action here
            })
            Divider()
            Button("Align and rotate…", action: {
                // Add action here
            })
        }
        
        CommandMenu("Insert") {
            Menu("Table") {
                Button("2 x 2", action: {
                    // Add your New file action here
                })
                Button("Customize…", action: {
                    // Add your New file action here
                })
            }
            Button("Chart"){
                //Add action here
            }
            Divider()
            Button("Hyperlink"){
                //Add action here
            }.keyboardShortcut("K", modifiers: [.command])
            
            
        }
        
        
    
       
            CommandMenu("Revision") {
                Button("Comment"){
                    //Add action here
                }.keyboardShortcut("C", modifiers: [.command,.shift])
                
            
        }
            

        
        
        
        
        
        
        CommandMenu("Tools") {
            Button("Spelling…", action: {
                // Add your New file action here
            }).keyboardShortcut("é", modifiers: [.command])
            Button("Check Spelling Automatically", action: {
                // Add your New file action here
            })
            Button("Show Quick Formatting Toolbar", action: {
  //              print("Trying to show Quick Formatting from MenuBar. Is it shown?")
  //              print(UserSettings().showSecondaryToolbar)
  //              userSettings.showSecondaryToolbar.toggle()
  //              print("Did I do that?")
  //              print(UserSettings().showSecondaryToolbar)
            })
            Divider()
            Button("Mail Merge…", action: {
                // Add your New file action here
            })
        }
        
        
        
        CommandGroup(after: CommandGroupPlacement.help, addition: {
            Divider()
            Button("Donate to the Developer", action: {})
        })
                
            }
        }
