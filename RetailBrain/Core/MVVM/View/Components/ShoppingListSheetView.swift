//
//  ShoppingListSheetView.swift
//  RetailBrain
//
//  Created by muhammed.nadeem.m.a on 10/07/26.
//  Copyright © 2026 Accenture. All rights reserved.
//

import SwiftUI

struct ShoppingListSheetView: View {

    @Binding var showList: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            // Content (empty state and wishlist)
            if true == false {
                wishListItems
            } else {
                emptyStateView
            }
        }
        .background(Color.appBackground)
    }

}

// MARK: SUBVIEWS
extension ShoppingListSheetView {

    @ViewBuilder
    private var closeButton: some View {
        Button {
            showList.toggle()
        } label: {
            Image(.xmark)
                .resizable()
                .scaledToFit()
                .frame(width: 15, height: 15)
                .padding(12)
                .background(.white)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 0)
        }
    }

    @ViewBuilder
    private var headerView: some View {
        HStack(alignment: .center) {
            Text(String(localized: "shopping_list.title"))
                .font(.graphik(.bold, size: 24))
            Spacer()
            closeButton
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(
            Color.white
                .ignoresSafeArea(edges: .top)
                .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 0)
        )
    }

    @ViewBuilder
    private var emptyStateView: some View {
        VStack(alignment: .center, spacing: 10) {
            Image(.emptystate)
                .resizable()
                .scaledToFit()
                .frame(width: 158, height: 153)
            Group {
                Text(String(localized: "shopping_list.empty.title"))
                    .font(.graphik(.bold, size: 24))
                Text(String(localized: "shopping_list.empty.subtitle"))
                    .font(.graphik(.regular, size: 16))
            }
            .padding(.horizontal)
            .foregroundStyle(.black)
            .multilineTextAlignment(.center)
        }
        .frame(maxHeight: .infinity, alignment: .center)
        .padding()
    }

    @ViewBuilder
    private var wishListItems: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(0..<4, id: \.self) { index in
                    Button {
                        print("index clicked: \(index)")
                    } label: {
                        wishListItem(item: String(localized: "shopping_list.weekly.title"), count: index + 1)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 5)
        }
        .scrollIndicators(.hidden)
        .padding(.top, 15)
    }

    @ViewBuilder
    private func wishListItem(item: String, count: Int) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(item)
                    .font(.graphik(.regular, size: 20))
                Text(String(localized: "shopping_list.product_count") + "\(count)")
                    .font(.graphik(.regular, size: 16))
            }
            .foregroundStyle(.black)
            Spacer()
            Image(.chevron)
                .resizable()
                .scaledToFit()
                .frame(width: 12, height: 13)
                .rotationEffect(.degrees(-90))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 0)
    }

}

#Preview {
    ShoppingListSheetView(showList: .constant(true))
}
