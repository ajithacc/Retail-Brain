//
//  ShoppingListDraggableSheet.swift
//  RetailBrain
//
//  Created by muhammed.nadeem.m.a on 10/07/26.
//  Copyright © 2026 Accenture. All rights reserved.
//

import SwiftUI

enum ListSheetDetent: CaseIterable {
    case minimized
    case medium
    case large
}

struct ShoppingListDraggableSheet: View {

    @State private var detent: ListSheetDetent = .minimized
    @GestureState private var dragTranslation: CGFloat = 0

    /// Height of the visible "peek" area when minimized.
    private let peekHeight: CGFloat = 92
    /// Small gap kept at the top so the map peeks under the large detent.
    private let topInset: CGFloat = 2
    /// Corner radius applied to the top edge of the sheet.
    private let cornerRadius: CGFloat = 12

    var body: some View {
        GeometryReader { geo in
            let height = geo.size.height
            let offsets = offsets(for: height)
            let base = offsets[detent] ?? (height - peekHeight)
            // Clamp so the sheet can't be dragged above the top inset or
            // below the minimized peek.
            let current = min(max(base + dragTranslation, topInset), height - peekHeight)

            sheetContent
                .frame(width: geo.size.width, height: height - topInset, alignment: .top)
                // Round only the top corners so the bottom stays flush.
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: cornerRadius,
                        topTrailingRadius: cornerRadius
                    )
                )
                .background(
                    UnevenRoundedRectangle(
                        topLeadingRadius: cornerRadius,
                        topTrailingRadius: cornerRadius
                    )
                    .fill(.white)
                    // Extend the white fill into the bottom safe area so the
                    // map never shows through beneath the sheet.
                    .ignoresSafeArea(edges: .bottom)
                    .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: -2)
                )
                .offset(y: current)
                .gesture(
                    DragGesture()
                        .updating($dragTranslation) { value, state, _ in
                            state = value.translation.height
                        }
                        .onEnded { value in
                            let predicted = base + value.predictedEndTranslation.height
                            detent = nearestDetent(to: predicted, offsets: offsets)
                        }
                )
                .animation(.spring(response: 0.35, dampingFraction: 0.85), value: detent)
                .animation(.interactiveSpring(), value: dragTranslation)
        }
    }

    /// The resting Y offset for each detent given the container height.
    private func offsets(for height: CGFloat) -> [ListSheetDetent: CGFloat] {
        [
            .minimized: height - peekHeight,
            .medium: height * 0.45,
            .large: topInset
        ]
    }

    private func nearestDetent(to offset: CGFloat, offsets: [ListSheetDetent: CGFloat]) -> ListSheetDetent {
        offsets.min { abs($0.value - offset) < abs($1.value - offset) }?.key ?? .minimized
    }

    // MARK: Content

    @ViewBuilder
    private var sheetContent: some View {
        VStack(spacing: 0) {
            grabber
            header
            Divider()
            listContent
        }
    }

    private var grabber: some View {
        Capsule()
            .fill(Color(hex: "#D9D9D9"))
            .frame(width: 40, height: 5)
            .padding(.top, 8)
            .padding(.bottom, 6)
            .frame(maxWidth: .infinity)
            // Let the whole top area (including padding) be draggable.
            .contentShape(Rectangle())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(String(localized: "shopping_list.weekly.title"))
                .font(.graphik(.bold, size: 20))
                .foregroundStyle(.black)
            Text(String(localized: "shopping_list.weekly.count"))
                .font(.graphik(.regular, size: 14))
                .foregroundStyle(Color(hex: "#767676"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
        .contentShape(Rectangle())
    }

    private var listContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                productSection(
                    title: String(localized: "shopping_list.section.produce"),
                    products: [
                        .init(name: "Pommes Gala", brand: "SANS MARQUE", detail: "6 pièces"),
                        .init(name: "Salade Batavia", brand: "SANS MARQUE", detail: "1 pièce  |  France"),
                        .init(name: "Courgettes", brand: "AUCHAN BIO", detail: "750g  |  Espagne")
                    ]
                )
                productSection(
                    title: String(localized: "shopping_list.section.butchery"),
                    products: [
                        .init(name: "Filet de poulet blanc", brand: "LE GAULOIS", detail: "720g  |  Volaille Française")
                    ]
                )
                productSection(
                    title: String(localized: "shopping_list.section.deli"),
                    products: [
                        .init(name: "Le Bon Paris Jambon réduit en sel sans nitrite", brand: "HERTA", detail: "140g  |  Fabriqué en France")
                    ]
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
    }

    @ViewBuilder
    private func productSection(title: String, products: [ShoppingProduct]) -> some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.graphik(.semibold, size: 13))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(hex: "#F7F7F7"))
                .clipShape(RoundedRectangle(cornerRadius: 6))

            ForEach(products) { product in
                ShoppingProductRow(product: product)
            }
        }
    }
}

/// A single product entry in the shopping list.
struct ShoppingProduct: Identifiable {
    let id = UUID()
    let name: String
    let brand: String
    let detail: String
}

private struct ShoppingProductRow: View {
    let product: ShoppingProduct

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: "#F2F2F2"))
                .frame(width: 56, height: 56)

            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.graphik(.bold, size: 14))
                    .foregroundStyle(.black)
                Text(product.brand)
                    .font(.graphik(.regular, size: 13))
                    .foregroundStyle(.black)
                Text(product.detail)
                    .font(.graphik(.regular, size: 12))
                    .foregroundStyle(Color(hex: "#767676"))
                Text("\(10)%" + String(localized: "shopping_list.reward_badge"))
                    .font(.graphik(.semibold, size: 11))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color(hex: "#8B1FA9"))
                    .clipShape(Capsule())
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "ellipsis")
                .rotationEffect(.degrees(90))
                .foregroundStyle(Color(hex: "#767676"))
        }
        .padding(12)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(hex: "#EAEAEA"), lineWidth: 1)
        )
    }
}


#Preview {
    ShoppingListDraggableSheet()
}
