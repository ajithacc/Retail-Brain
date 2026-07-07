//
//  TabContainerView.swift
//  RetailBrain
//
//  Created by muhammed.nadeem.m.a on 07/07/26.
//  Copyright © 2026 Accenture. All rights reserved.

import SwiftUI

struct TabContainerView: View {

    @State private var selectedTab: TabItem = .store

    var body: some View {
        Text("Tab Container")
    }
}

#Preview {
    TabContainerView()
}

struct OnlineView: View {
    var body: some View {
        Text("OnlineView")
    }
}

struct WalletView: View {
    var body: some View {
        Text("WalletView")
    }
}

struct AccountView: View {
    var body: some View {
        Text("AccountView")
    }
}
