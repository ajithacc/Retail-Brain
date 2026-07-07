//
//  RetailBrainApp.swift
//  RetailBrain
//
//  Created by muhammed.nadeem.m.a on 07/07/26.
//  Copyright © 2026 Accenture. All rights reserved.

import SwiftUI

@main
struct RetailBrainApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                StoreView()
            }
        }
    }
}
