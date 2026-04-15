//
//  FormattingSidebar.swift
//  LiberWriter
//
//  Created by Simone Alghisi on 09/03/23.
//

import SwiftUI


struct FormattingSidebar: View {
    
    @EnvironmentObject var userSettings: UserSettings
    
    @State var characterFormattingOptionsIsExpanded = true
    @State var asianCharacterFormattingOptionsIsExpanded = false

    
    @State var currentFontSelection = "font"
    @State var currentFontSize = 12.0
    @State var currentFontIsBold = false
    @State var currentFontIsItalic = false
    @State var currentFontIsUnderlined = false
    @State var currentFontIsStrikethrough = false
    @State var currentFontColor = Color(NSColor(red: 0, green: 0, blue: 0, alpha: 1))
    @State var currentFontHighlightingColor = Color(NSColor(red: 1, green: 1, blue: 0, alpha: 0))
    @State var currentFontSpacing = 0.0
    
    @State var paragraphIsExpanded = true
    @State var textareaHorizontalAlign = "left"
    @State var currentParagraphBackgroundColor = Color(NSColor(red: 1, green: 1, blue: 0, alpha: 0))
    @State var currentParagraphIsAList = false
    
    var body: some View {
        ScrollView(.vertical) {
            DisclosureGroup(
                isExpanded: $characterFormattingOptionsIsExpanded,
                content: {
                    Form{
                        VStack(alignment: .leading, content: {
                            HStack{
                                Picker("Font", selection: $currentFontSelection, content: {
                                    Text("Placeholder")
                                }).labelsHidden()
                                Picker("Font Size", selection: $currentFontSize, content: {
                                    Text("Placeholder")
                                }).labelsHidden().frame(width: 75)
                            }.padding(.bottom)
                            HStack{
                                Toggle(isOn: $currentFontIsBold, label: {
                                    Image(systemName: "bold")
                                }).toggleStyle(.button)
                                Toggle(isOn: $currentFontIsItalic, label: {
                                    Image(systemName: "italic")
                                }).toggleStyle(.button)
                                Toggle(isOn: $currentFontIsUnderlined, label: {
                                    Image(systemName: "underline")
                                }).toggleStyle(.button)
                                Toggle(isOn: $currentFontIsStrikethrough, label: {
                                    Image(systemName: "strikethrough")
                                }).toggleStyle(.button)
                                Spacer()
                                Button(action: {}, label: {
                                    Image(systemName: "textformat.size.smaller")
                                }).help("Decrease text size")
                                Button(action: {}, label: {
                                    Image(systemName: "textformat.size.larger")
                                }).help("Increase text size")
                            }.padding(.bottom)
                            HStack{
                                ColorPicker(selection: $currentFontColor, label: {
                                    Image(systemName: "character")
                                }).help("Text Color")
                                ColorPicker(selection: $currentFontHighlightingColor, label: {
                                    Image(systemName: "highlighter")
                                }).help("Text highlighting")
                                Spacer()
                                HStack(spacing: 0.2, content: {
                                    Stepper(value: $currentFontSpacing, step: 0.1, label: {
                                        Image("format.character.spacing")
                                    })
                                    TextField(value: $currentFontSpacing, format: .number, label: {Text( "Character Spacing")}).labelsHidden()
                                }).help("Character Spacing")
                                
                            }.padding(.bottom)
                            HStack{
                                
                            }
                            
                        }).padding(.top)}
                    
                    
                    
                },
                label: {
                    HStack{
                        Image(systemName: "character.cursor.ibeam").foregroundStyle(Color.accentColor)
                        Text("Character Formatting")
                        Spacer()
                        Button(action: {}, label: {Image(systemName: "arrow.up.forward.square")}).buttonStyle(.plain)
                    }.bold()}
            )
            Divider()
            DisclosureGroup(isExpanded: $paragraphIsExpanded, content: {
                Form{
                    HStack{
                        Picker("Paper Orientation Selection", selection: $textareaHorizontalAlign, content: {
                            Label(
                                title: { Text("Align Left") },
                                icon: { Image(systemName: "text.alignleft") }
                            ).tag("left").labelStyle(.iconOnly).help("Left align text")
                            Label(title: { Text("Align Center") }, icon: { Image(systemName: "text.aligncenter") }).tag("center").labelStyle(.iconOnly).help("Center text")
                            Label(title: {
                                Text("Align Right")}, icon: {
                                    Image(systemName: "text.alignright")
                                }).tag("right").labelStyle(.iconOnly).help("Right align text")
                            Label(title: {
                                Text("Justify Text")}, icon: {
                                    Image(systemName: "text.justify")
                                }).tag("justify").labelStyle(.iconOnly).help("Justify Text")
                        }).labelsHidden().pickerStyle(.segmented).frame(width: 150)
                        
                        Spacer()
                        ColorPicker(selection: $currentParagraphBackgroundColor, label: {
                            Image(systemName: "text.viewfinder")
                        }).help("Color of Paragraph Area")
                    }.padding([.bottom, .top])
                    HStack{
                        Toggle(isOn: $currentParagraphIsAList, label: {
                            Image(systemName: "list.bullet")
                        }).toggleStyle(.button)
                    }
                }
            }, label: {
                HStack{
                    Image(systemName: "paragraphsign").foregroundStyle(Color.accentColor)
                    Text("Paragraph Formatting")
                    Spacer()
                    Button(action: {}, label: {Image(systemName: "arrow.up.forward.square")}).buttonStyle(.plain)
                }.bold()})
            
            
            
            Divider()
            DisclosureGroup(
                isExpanded: $asianCharacterFormattingOptionsIsExpanded,
                content: {
                    Form{
                        VStack(alignment: .leading, content: {
                            HStack{
                                Picker("Font", selection: $currentFontSelection, content: {
                                    Text("Placeholder")
                                }).labelsHidden()
                                Picker("Font Size", selection: $currentFontSize, content: {
                                    Text("Placeholder")
                                }).labelsHidden().frame(width: 75)
                            }.padding(.bottom)
                        })
                    }.padding(.top)
                }, label: {
                    HStack{
                        Image(systemName: "character.phonetic").foregroundStyle(Color.accentColor)
                        Text("Complex & Asian Typography")
                        Spacer()
                        Button(action: {}, label: {Image(systemName: "arrow.up.forward.square")}).buttonStyle(.plain)
                    }.bold()})
        }
    }
        
        struct FormattingSidebar_Previews: PreviewProvider {
            static var previews: some View {
                FormattingSidebar()
            }
        }
    }
