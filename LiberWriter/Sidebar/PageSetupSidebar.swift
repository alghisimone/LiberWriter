//
//  SidebarPageLayoutView.swift
//  LyberWriter
//
//  Created by Simone Alghisi on 18/11/2023.
//

import SwiftUI

struct PageSetupSidebar: View {
    
    
    @State var paperSizeExpanded = true
    @State var paperSizeSelection = "A4"
    @State var pageWidth = 210 //millimeters
    @State var pageHeight = 297 //millimeters
    @State var printOrientation = "portrait"
    @State var paperTraySelection = 0
    @State var isPresentingCustomPageSizeSheet = false
    
    @State var pagesLayoutExpanded = false
    
    @State var multiplePagesLayoutSelection = 0
    @State var gutterPositionSelection = 0
    @State var pagesNumbersFormatSelection = 0
    @State var usePageLineSpacingToggle = false
    @State var referenceStylePicker = 0
    
    @State var pageMarginsExpanded = true
    @State var pageMarginsLeft = 1.25
    @State var pageMarginsRight = 1.25
    @State var pageMarginsTop = 1.25
    @State var pageMarginsBottom = 1.25
    @State var pageMarginsGutter = 1
    @State var backgroundCoversMarginToggle = true
    var step = 0.01
    var range = 0.00 ... 100.00
    
    @State var pageAreaIsExpanded = false
    @State var pageFill = "0"
    @State var pageFillColor = Color(NSColor(red: 255, green: 255, blue: 255, alpha: 0))
    @State var pageFillImageTransparencyIsOn = false
    @State var pageFillImageTransparencyValue = 0.0
    
    
    var body: some View {
        ScrollView(.vertical) {
            DisclosureGroup(isExpanded: $paperSizeExpanded,
                            content: { HStack {
                Picker("Paper Size Selection", selection: $paperSizeSelection, content: {
                    Button(action: {
                        pageWidth = 210 //millimeters
                        pageHeight = 297 //mm
                        print("A4Page: \(pageWidth)x\(pageHeight)")
                    }, label: {
                        Text("A4 Paper")
                    }).tag("A4")
                    Button(action: {
                        pageWidth = 297 //millimeters
                        pageHeight = 420 //mm
                        print("A3Page: \(pageWidth)x\(pageHeight)")
                    }, label: {
                        Text("A3 Paper")
                    }).tag("A3")
                    Text("A5 Paper").tag("A5")
                    Text("A6 Paper").tag("A6")
                    Text("US Letter").tag("Letter")
                    Text("US Legal").tag("Legal")
                    Text("Tabloid").tag("Tabloid")
                    Text("B6 (ISO)").tag("B6")
                    Text("B5 (ISO)").tag("B5")
                    Text("B4 (ISO)").tag("B4")
                    Text("B6 (JIS)").tag("B6JIS")
                    Text("B5 (JIS)").tag("B5JIS")
                    Text("B4 (JIS)").tag("B4JIS")
                    Text("C6 Envelope").tag("C6")
                    Text("C5 Envelope").tag("C5")
                    Text("C4 Envelope").tag("C5")
                    Text("#6¾ Envelope").tag("6E")
                    Text("#7¾ Envelope (Monarch)").tag("7E")
                    Text("#9 Envelope").tag("9E")
                    Text("#10 Envelope").tag("10E")
                    Text("#11 Envelope").tag("11E")
                    Text("#12 Envelope").tag("12E")
                    Text("Japanese Postcard").tag("Postcard")
                    Text("Long Bond").tag("Long")
                    Text("16 Kai").tag("16Kai")
                    Text("32 Kai").tag("32Kai")
                    Text("Big 32 Kai").tag("Big32Kai")
                    Divider()
                    Text("Custom Size…").tag("custom").sheet(isPresented: $isPresentingCustomPageSizeSheet, content: {
                        Form{
                            
                        }
                        HStack{
                            Button(role: .cancel, action: {}, label: {
                                Text("Cancel")
                            })
                            Button(action: {}, label: {
                                Text("OK")
                            })
                        }
                    })
                    Button(action: {
                        isPresentingCustomPageSizeSheet.toggle()
                        paperSizeSelection = "custom"
                    }, label: {Text("Custom Size…")})
                }).pickerStyle(.menu).labelsHidden()
                Picker("Paper Orientation Selection", selection: $printOrientation, content: {
                    Button(action: {
                        
                    }, label: {
                        Image(systemName: "arrow.up.and.person.rectangle.portrait")
                    }).tag("portrait")
                    Button(action: {
                        var tempWidth = pageHeight
                        pageHeight = pageWidth
                        pageWidth = tempWidth
                        
                        print("rotated page")
                    }, label: {
                        Image(systemName: "person.crop.rectangle")
                    }).tag("landscape")
                }).labelsHidden().pickerStyle(.segmented).frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                
            }.padding(.top).padding(.bottom)
                Picker("Paper Tray:", selection: $paperTraySelection, content: {
                    Text("From printer settings").tag(0)
                }).pickerStyle(.menu).padding(.bottom)
            },
                            label: { HStack {
                Image(systemName: "doc").foregroundStyle(Color.accentColor)
                Text("Paper Selection")
            }.bold() }
            ).frame(alignment: .leading)
            
            Divider()
            
            DisclosureGroup(content: {
                Picker("Multiple Pages:", selection: $multiplePagesLayoutSelection, content: {
                    Text("Left & Right").tag(0)
                    Text("Mirrored").tag(1)
                    Text("Only Right").tag(2)
                    Text("Only Left").tag(3)
                }).padding(.top).padding(.bottom)
                Picker("Gutter Position:", selection: $gutterPositionSelection, content: {
                    Text("Left").tag(0)
                    Text("Top").tag(1)
                    Text("Right").tag(2)
                }).padding(.bottom)
                Picker("Page Numbers:", selection: $pagesNumbersFormatSelection, content: {
                    Text("1, 2, 3, …").tag(0)
                    Text("A, B, C, …").tag(1)
                    Text("a, b, c, …").tag(2)
                    Text("I, II, III, …").tag(3)
                    Text("i, ii, iii, …").tag(4)
                    Text("1st, 2nd, 3rd, …").tag(5)
                    Text("One, Two, Three, …").tag(6)
                    Text("First, Second, Third, …").tag(7)
                    Text("Α, Β, Γ, Δ …").tag(8)
                    Text("α, β, γ, δ …").tag(9)
                    Text("А, Б, В, Г … (Bulgarian)").tag(10)
                    Text("А, Б, В, Г … (Russian)").tag(11)
                    Text("А, Б, В, Г … (Serbian)").tag(12)
                    Text("А, Б, В, Г … (Ukrainian)").tag(13)
                    Text("а, б, в, г … (Bulgarian)").tag(14)
                    Text("а, б, в, г … (Russian)").tag(15)
                    Text("а, б, в, г … (Serbian)").tag(16)
                    Text("а, б, в, г … (Ukrainian)").tag(17)
                    
                }).pickerStyle(.menu).padding(.bottom)
                HStack {
                    Toggle("Use Page-Line Spacing", isOn: $usePageLineSpacingToggle).toggleStyle(.checkbox)
                    Spacer()
                }.padding(.leading).padding(.bottom)
                
                if usePageLineSpacingToggle == true {
                    Picker("Reference Style:", selection: $referenceStylePicker, content: {
                        Text("Nothing to show")
                    }).padding(.leading).padding(.bottom).disabled(true)
                }
                
            }, label: { HStack {
                Image(systemName: "book.and.wrench").foregroundStyle(Color.accentColor)
                Text("Pages Layout")
            }.bold() })
            
            Divider()
            
            DisclosureGroup(content: {
                HStack {
                    if multiplePagesLayoutSelection == 1 {
                        Text("Inner:")
                    } else {
                        Text("Left:")
                    }
                    TextField(value: $pageMarginsLeft, format: .number, label: { Text("Left or inner margin") }).textFieldStyle(.roundedBorder)
                    if multiplePagesLayoutSelection == 1 {
                        Text("Outer:")
                    } else {
                        Text("Right:")
                    }
                    TextField(value: $pageMarginsRight, format: .number, label: { Text("Right or outer margin") }).textFieldStyle(.roundedBorder)
                }.padding(.bottom).padding(.top)
                HStack {
                    Text("Top:")
                    TextField(value: $pageMarginsTop, format: .number, label: { Text("Top margin") }).textFieldStyle(.roundedBorder)
                    Text("Bottom:")
                    TextField(value: $pageMarginsBottom, format: .number, label: { Text("Bottom margin") }).textFieldStyle(.roundedBorder)
                }.padding(.bottom)
                HStack {
                    Text("Gutter:")
                    TextField(value: $pageMarginsGutter, format: .number, label: { Text("Gutter margin") }).textFieldStyle(.roundedBorder)
                }.padding(.bottom).frame(width: 150)
                Toggle(isOn: $backgroundCoversMarginToggle, label: { Text("Background Covers Margins") })
            }, label: {
                HStack {
                    Image(systemName: "viewfinder.rectangular").foregroundStyle(Color.accentColor)
                    Text("Page Margins")
                }.bold()
            })
            
            
            Divider()
            
            DisclosureGroup(
                isExpanded: $pageAreaIsExpanded,
                content: { Form{
                    HStack {
                        Picker(selection: $pageFill, content: {
                            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                                Text("None")
                            }).tag("0")
                            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                                Text("Color")
                            }).tag("1")
                            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                                Text("Gradient")
                            }).tag("2")
                            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                                Text("Image")
                            }).tag("3")
                        }, label: {
                            Text("Area Fill:")
                        })
                        if pageFill == "1" {
                            ColorPicker(selection: $pageFillColor, label: {
                                Text("Page Fill Solid Color Picket")
                            }).labelsHidden()
                        }
                    }
                    if pageFill == "2" {
                        Text("PLEASE ADD GRADIENT SUPPORT")
                    } else if pageFill == "3" {
                        Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                            HStack{
                                Image(systemName: "photo")
                                Text("Choose an Image…")
                            }}).padding(.top)
                        
                        Stepper(value: $pageFillImageTransparencyValue,step: 0.1, label: {Text("Transparency")}).padding(.top)
                        
                                
                        }
                }.padding(.top)
                },
                label: { HStack {
                    Image(systemName: "rectangle.fill").foregroundStyle(Color.accentColor)
                    Text("Page Area")
                }.bold()
                }
            )
        }
    }
}
    
    #Preview {
        PageSetupSidebar()
    }

