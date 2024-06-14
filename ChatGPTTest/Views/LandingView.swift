//
//  LandingView.swift
//  ChatGPTTest
//
//  Created by Russell Gordon on 2024-06-13.
//

import SwiftUI

struct LandingView: View {
    
    @Binding var selectedTab: Int
    
    var body: some View {
        
        TabView(selection: $selectedTab) {
            
            LessFancyView()
                .tabItem {
                    Label {
                        Text("Less Fancy")
                    } icon: {
                        Image(systemName: "book")
                    }
                }
                .tag(1)

            FancyView()
                .tabItem {
                    Label {
                        Text("Fancy")
                    } icon: {
                        Image(systemName: "sparkles")
                    }
                }
                .tag(2)
            
        }
    }
}

#Preview {
    LandingView(selectedTab: Binding.constant(1))
}
