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
        VStack(spacing: 0) {
            ZStack {
                switch selectedTab {
                case .online:
                    OnlineView()
                case .store:
                    StoreView()
                case .wallet:
                    WalletView()
                case .account:
                    AccountView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // Tabbar
            customTabBar
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    @ViewBuilder
    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(TabItem.allCases, id: \.self) { tab in
                tabBarButton(for: tab)
            }
        }
        .padding(.top, 10)
        .padding(.horizontal, 8)
        .background(
            Color.white
                .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: -2)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    @ViewBuilder
    private func tabBarButton(for tab: TabItem) -> some View {
        let isSelected = selectedTab == tab
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 6) {
                Image(tab.imageName)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 27, height: 27)
                Text(tab.title)
                    .font(.graphik(isSelected ? .bold : .regular, size: 13))
            }
            .foregroundStyle(isSelected ? Color.brandPrimary : Color.black)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .disabled(tab != .store)
    }
}

#Preview {
    TabContainerView()
}

struct OnlineView: View {
    var body: some View {
        Text(String(localized: "placeholder.online"))
    }
}

struct WalletView: View {
    var body: some View {
        Text(String(localized: "placeholder.wallet"))
    }
}

struct AccountView: View {
    var body: some View {
        Text(String(localized: "placeholder.account"))
    }
}
