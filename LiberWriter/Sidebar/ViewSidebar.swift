//
//  SidebarViewOptionsView.swift
//  LyberWriter
//
//  Created by Simone Alghisi on 08/12/2023.
//

import SwiftUI

struct ViewSidebar: View {
    
    
    
    
    @AppStorage("viewOptionsSidebarDisclosureGroupIsDisclosed") var pageViewOption = 1
    
    
    @State var zoomSidebarDisclosureGroupIsDisclosed = true
    @State var viewOptionsSidebarDisclosureGroupIsDisclosed = false
    @AppStorage("zoomIncrement") private var zoomIncrement = 100.0
    @State var zoomIncrementForPicker = 100
    
    @State var isPresentingReloadAlert = false
    
    var body: some View {
        ScrollView(.vertical) {
                DisclosureGroup(
                    isExpanded: $zoomSidebarDisclosureGroupIsDisclosed, content: { Form{
                        Slider(value: $zoomIncrement, in: 5...400) {
                            Text("\(zoomIncrement, specifier: "%.0f")%")
                        }.padding(.top) }
                        HStack {
                            Button(action: {
                                
                            }, label: {
                                HStack{
                                    Image(systemName: "arrow.up.left.and.arrow.down.right.square")
                                    Text("Optimize View")
                                }
                        })
                            Button(action: {
                                zoomIncrement = 100
                            }, label: {
                                HStack{
                                    Image(systemName: "1.magnifyingglass")
                                    Text("1:1")
                                }
                            })
                        }.padding(.top)
                        HStack {
                            Button(action: {
                                
                            }, label: {
                                HStack{
                                    Image(systemName: "arrow.up.and.line.horizontal.and.arrow.down")
                                    Text("Adapt Height")
                                }
                        })
                            Button(action: {
                                zoomIncrement = 100
                            }, label: {
                                HStack{
                                    Image(systemName: "arrow.left.and.line.vertical.and.arrow.right")
                                    Text("Adapt Width")
                                }
                            })
                        }
                        
                        
                    },
                    label: { HStack{
                        Image(systemName: "magnifyingglass").foregroundStyle(Color.accentColor)
                        Text("Zoom")
                        if zoomSidebarDisclosureGroupIsDisclosed == false {
                            Picker(selection: $zoomIncrement, content: {
                                Button(action: {
                                    
                                }, label: {Text("100%")})
                            }, label: {
                                Text("Zoom Level:")
                            }).labelsHidden()
                        }
                    }.bold()}
                )
                Divider().padding(.top)
                DisclosureGroup(
                    isExpanded: $viewOptionsSidebarDisclosureGroupIsDisclosed, content: { VStack{
                        Picker(selection: $pageViewOption, content: {
                            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                                Image(systemName: "a.square")
                                }
                            ).help("Automatic").tag(1)
                            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                                Image(systemName: "rectangle.portrait")
                                }
                            ).help("Single Page Layout View").tag(2)
                            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                                Image(systemName: "rectangle.split.2x1")
                            }).help("Two Page Layout View").tag(3)
                            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                                Image(systemName: "book")
                            }).help("Book Layout View").tag(4)
                            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                                Image(systemName: "globe")
                            }).help("Web View").tag(5)
                        }, label: {
                            Text("Multiple Page Layout")
                        }).pickerStyle(.segmented).labelsHidden()
                        Button(action: {
                            isPresentingReloadAlert.toggle()
                    
                        }, label: {
                            HStack{
                                Image(systemName: "arrow.clockwise")
                                Text("Reload Document")
                            }
                        }).padding(.top).alert("Reload Document", isPresented: $isPresentingReloadAlert, actions: {
                            
                            Button("Reload", role: .destructive, action: {Alert.Button.destructive(Text("Reload"))})
                        }, message: {Text("This will remove any change you made to this document. Make sure to save important changes before reloading.")})
                        
                    }.padding(.top)
                    },
                    label: { HStack{
                        Image(systemName: "eye.circle").foregroundStyle(Color.accentColor)
                        Text("View Options")
                    }.bold()}
                )
                
            }
        }
}

#Preview {
    ViewSidebar()
}
