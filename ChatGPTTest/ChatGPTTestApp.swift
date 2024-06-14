//
//  ChatGPTTestApp.swift
//  ChatGPTTest
//
//  Created by Russell Gordon on 2024-06-12.
//

import SwiftUI

@main
struct ChatGPTTestApp: App {
    
    // MARK: Stored properties
    @State private var tab: Int = 1
    
    // MARK: Computed properties
    var body: some Scene {
        WindowGroup {
            LandingView(selectedTab: $tab)
        }
    }
}
