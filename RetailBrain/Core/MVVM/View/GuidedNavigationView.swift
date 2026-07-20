//
//  GuidedNavigationView.swift
//  RetailBrain
//
//  Created by muhammed.nadeem.m.a on 09/07/26.
//  Copyright © 2026 Accenture. All rights reserved.
//

import SwiftUI

struct GuidedNavigationView: View {

    @State private var ignoreStoreSelectionsUntil: Date = .distantPast
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @FocusState private var isSearchFocused: Bool
    @StateObject private var viewModel = GuidedNavigationViewModel()
    @StateObject private var sdkViewModel = RetailSDKViewModel()
    

    var body: some View {
        VStack(spacing: 0) {
            headerView
                .zIndex(1)
            ZStack(alignment: .bottomTrailing) {
                ZStack {
                    
                    // Map
                    sdkViewModel.makeMapView()
                    
                    // for No permission Alert setUp
                    
                    if sdkViewModel.showPermissionRevokedAlert {
                        PermissionDeniedAlertView(
                            message: sdkViewModel.revokedPermissionType,
                            onOpenSettings: {
                                sdkViewModel.openSettings()
                            },
                            onCancel: {
                                sdkViewModel.showPermissionRevokedAlert = false
                            }
                        )
                    }
                    
                    // Current destination
                    CurrentDestinationView()
                    // Search overlay
                    if isSearchFocused {
                        SearchResultsView(
                            isSearchFocused: $isSearchFocused,
                            searchText: $viewModel.searchText
                        )
                        .transition(.opacity)
                    }
                }
                .overlay(
                    (viewModel.floatingMenuExpanded ? Color.black.opacity(0.3) : Color.clear)
                        .ignoresSafeArea()
                )
                .overlay(alignment: .bottom) {
                    if let product = sdkViewModel.selectedProductDetails {
                        ProductDetailsSheetView(
                            product: product,
                            onClose: {
                                ignoreStoreSelectionsUntil = Date().addingTimeInterval(0.35)
                                sdkViewModel.selectedProductDetails = nil
                            }
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: 201, alignment: .top)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: -2)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .zIndex(2)
                    }
                }

                .onAppear {
                    // Initialize SDK when map page appears
                    sdkViewModel.startShopping()
                    sdkViewModel.refreshPermissionStateAfterForeground()
                }
                // Floating Menu Button
                floatingMenuButton
                // NFC Overlay
                if viewModel.showNFCOverlay {
                    NFCOverlayView(showNFCOverlay: $viewModel.showNFCOverlay)
                        .transition(.opacity)
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .animation(.easeInOut, value: isSearchFocused)
        .animation(.easeInOut, value: viewModel.floatingMenuExpanded)
        .animation(.easeInOut, value: viewModel.showNFCOverlay)
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $viewModel.showListSheet) {
            ShoppingListSheet(showList: $viewModel.showListSheet)
                .presentationDetents([.medium])
                .interactiveDismissDisabled()
        }
        .onChange(of: isSearchFocused) { _, _ in
            viewModel.floatingMenuExpanded = false
            viewModel.showNFCOverlay = false
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                sdkViewModel.refreshPermissionStateAfterForeground()
            }
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
                          text: $viewModel.searchText,
                          prompt: Text(String(localized: "guided_nav.search.placeholder"))
                    .foregroundStyle(.textfieldplaceholder)
                )
                .tint(.black)
                .submitLabel(.search)
                .font(.graphik(.regular, size: 15))
                .foregroundStyle(.black)
                .focused($isSearchFocused)
                if !viewModel.searchText.trimmed.isEmpty {
                    Button {
                        viewModel.searchText = ""
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
            ExpandableFloatingMenu(expanded: $viewModel.floatingMenuExpanded) { menu in
                switch menu.type {
                case .challenge:
                    print("Show Challenge view")
                case .enrichedContent:
                    viewModel.showNFCOverlay = true
                case .list:
                    viewModel.showListSheet = true
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
