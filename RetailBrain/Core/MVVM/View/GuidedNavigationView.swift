//
//  GuidedNavigationView.swift
//  RetailBrain
//
//  Created by muhammed.nadeem.m.a on 09/07/26.
//  Copyright © 2026 Accenture. All rights reserved.
//

import SwiftUI

struct GuidedNavigationView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""
    @FocusState private var isSearchFocused: Bool
    @State private var showListSheet: Bool = false
    @State private var floatingMenuExpanded: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            headerView
                .zIndex(1)
            ZStack(alignment: .bottomTrailing) {
                ZStack {
                    // Map
                    MapPlaceholderView()
                    // Current destination
                    CurrentDestinationView()
                    // Search overlay
                    if isSearchFocused {
                        searchOverlayView
                            .transition(.opacity)
                    }
                }
                .overlay(
                    (floatingMenuExpanded ? Color.black.opacity(0.3) : Color.clear)
                        .ignoresSafeArea()
                )
                // Floating Menu Button
                floatingMenuButton
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .animation(.easeInOut, value: isSearchFocused)
        .animation(.easeInOut, value: floatingMenuExpanded)
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showListSheet) {
            ShoppingListSheet(showList: $showListSheet)
                .presentationDetents([.medium])
                .interactiveDismissDisabled()
        }
        .onChange(of: isSearchFocused) { _, _ in
            floatingMenuExpanded = false
        }
    }
}

// MARK: SUBVIEW
extension GuidedNavigationView {

    @ViewBuilder
    private var headerView: some View {
        HStack(spacing: 20) {
            // Back Button
            Button {
                dismiss()
            } label: {
                Image(.arrowback)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 17.5, height: 14)
                    .padding(20)
                    .background(.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 0)
            }
            // Search
            HStack {
                Image(.search)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                TextField("",
                          text: $searchText,
                          prompt: Text(String(localized: "guided_nav.search.placeholder"))
                    .foregroundStyle(.textfieldplaceholder)
                )
                .tint(.black)
                .submitLabel(.search)
                .font(.graphik(.regular, size: 15))
                .foregroundStyle(.black)
                .focused($isSearchFocused)
                if !searchText.trimmed.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(.searchclear)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                            .foregroundStyle(.black)
                    }
                }
            }
            .padding()
            .background(
                Capsule()
                    .fill(.white)
            )
            .overlay(
                Capsule().stroke(isSearchFocused ? .brandprimary : .textfieldborder, lineWidth: 1)
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            Color.white
                .ignoresSafeArea(edges: .top)
                .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 0)
        )
    }

    @ViewBuilder
    private var floatingMenuButton: some View {
        if !isSearchFocused {
            ExpandableFloatingMenu(expanded: $floatingMenuExpanded) { menu in
                switch menu.type {
                case .challenge:
                    print("Show Challenge view")
                case .enrichedContent:
                    print("Show NFC Overlay")
                case .list:
                    showListSheet = true
                }
            }
            .padding()
        }
    }

    @ViewBuilder
    private var searchOverlayView: some View {
        VStack {
            // Search View Header
            HStack {
                Text(String(localized: "guided_nav.recently_viewed"))
                    .font(.graphik(.bold, size: 24))
                    .foregroundStyle(.black)
                Spacer()
                Button {
                    isSearchFocused = false
                } label: {
                    Image(.xmark)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                }
            }
            Spacer() // Search results
        }
        .padding(.top, 20)
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(edges: .bottom)
        .background(Color.white.ignoresSafeArea())
    }

}

#Preview {
    GuidedNavigationView()
}

struct MapPlaceholderView: View {
    var body: some View {
        Color.brandprimary
            .ignoresSafeArea()
            .overlay {
                Text(String(localized: "map.placeholder"))
                    .bold()
                    .foregroundStyle(.black)
            }
    }
}
