//
//  SearchResultsView.swift
//  RetailBrain
//
//  Created by muhammed.nadeem.m.a on 16/07/26.
//  Copyright © 2026 Accenture. All rights reserved.
//

import SwiftUI

struct SearchResultsView: View {

    @FocusState<Bool>.Binding var isSearchFocused: Bool
    @Binding var searchText: String

    var body: some View {
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
            .padding(.horizontal)
            // Content
            if searchText.trimmed.isEmpty {
                seachResult
            } else {
                ContentUnavailableView.search(text: searchText)
            }
        }
        .padding(.top, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .ignoresSafeArea(edges: .bottom)
        .background(Color.appbackground.ignoresSafeArea())
    }
}

extension SearchResultsView {

    @ViewBuilder
    private var seachResult: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(0..<3, id: \.self) { _ in
                    Button {

                    } label: {
                        searchItemRow()
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.top, 16)
    }

    @ViewBuilder
    private func searchItemRow() -> some View {
        HStack(alignment: .center, spacing: 16) {
            Image(.productplaceholder)
                .resizable()
                .scaledToFit()
                .frame(width: 73, height: 73)
                .overlay(alignment: .bottomLeading) {
                    Image(.nfcbadge)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .padding(5)
                }
            VStack(alignment: .leading, spacing: 5) {
                Text("Déjà consulté")
                    .font(.graphik(.bold, size: 16))
                    .foregroundStyle(.brandprimary)
                Group {
                    Text("AUCHAN Café soluble intensité 6")
                        .font(.graphik(.regular, size: 18))
                    Text("200g | 26,65€ / kg | 100 tasses")
                        .font(.graphik(.regular, size: 12))
                }
                .multilineTextAlignment(.leading)
                .foregroundStyle(.black)
                Text("10% Jour GO! cagnottés")
                    .font(.graphik(.bold, size: 12))
                    .foregroundStyle(.white)
                    .padding(5)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "#460073"), Color(hex: "#8400D9")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .padding(.top, 2)
            }
            Spacer()
            Image(.recenticon)
                .resizable()
                .scaledToFit()
                .foregroundStyle(.brandprimary)
                .frame(width: 18, height: 18)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background()
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: Color.black.opacity(0.25), radius: 2, x: 0, y: 0)
        .padding(.vertical, 2)
    }

}


#Preview {
    @Previewable @FocusState var focused: Bool
    SearchResultsView(
        isSearchFocused: $focused,
        searchText: .constant("NA")
    )
}
