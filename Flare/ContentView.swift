//
//  ContentView.swift
//  Flare
//
//  Created by Himaja Mankala on 2024-11-14.
//

import SwiftUI

struct ContentView: View {
    @State private var bottomTabSelection = 1
    var body: some View {
        TabView(selection: $bottomTabSelection){
            Journal()
                .tag(1)
            
           Report()
                .tag(2)
        }
        .tabViewStyle(DefaultTabViewStyle())
        .ignoresSafeArea()
        .overlay(alignment: .bottom)
        {
            Main_Navigation_Bar(bottomTabSelection: $bottomTabSelection)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
