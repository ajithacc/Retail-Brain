//
//  ProductDetailsSheetView.swift
//  RetailBrain
//
//  Created by ajith.a.s on 07/07/26.
//  Copyright © 2026 Accenture. All rights reserved.

import SwiftUI

struct ProductDetailsSheet: View {

    @Binding var showProductSheet: Bool
    @State private var productMarked: Bool = false
    @State private var offset: CGFloat = 0
    @State private var isSwiped: Bool = false
    @State private var cardHeight: CGFloat = 0

    private let buttonWidth: CGFloat = 90

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            sectionLabel
            productContainer
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            Color.white
                .ignoresSafeArea(edges: .bottom)
        )
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 10, topTrailingRadius: 10))
    }
}

// SUBVIEWS
extension ProductDetailsSheet {

    @ViewBuilder
    private var header: some View {
        HStack {
            Text("Produit(s) selectionné(s)")
                .font(.graphik(.bold, size: 20))
            Spacer()
            Button {
                showProductSheet = false
            } label: {
                Image(.xmark)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
            }
        }
        .padding(.top, 10)
    }

    @ViewBuilder
    private var sectionLabel: some View {
        HStack(alignment: .center, spacing: 8) {
            Image(.mappin)
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
            Text("Rayon - Fruits, Légumes")
                .font(.graphik(.regular, size: 14))
                .foregroundColor(.black)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(.appbackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.top, 10)
    }

    @ViewBuilder
    private var productContainer: some View {
        ZStack(alignment: .trailing) {
            if !productMarked {
                markButton
            }
            productView
                .offset(x: offset)
                .gesture(productMarked ? nil : dragGesture)
                .onTapGesture {
                    if isSwiped {
                        closeSwipe()
                    }
                }
        }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let translation = value.translation.width
                if isSwiped {
                    offset = min(0, max(-buttonWidth, -buttonWidth + translation))
                } else if translation < 0 {
                    offset = max(translation, -buttonWidth)
                }
            }
            .onEnded { value in
                withAnimation(.easeOut(duration: 0.25)) {
                    if value.translation.width < -buttonWidth / 2 {
                        offset = -buttonWidth
                        isSwiped = true
                    } else {
                        offset = 0
                        isSwiped = false
                    }
                }
            }
    }

    private func closeSwipe() {
        withAnimation(.easeOut(duration: 0.25)) {
            offset = 0
            isSwiped = false
        }
    }

    @ViewBuilder
    private var markButton: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                productMarked = true
                offset = 0
                isSwiped = false
            }
        } label: {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.brandprimary)
                .frame(width: buttonWidth - 5, height: cardHeight)
                .overlay(
                    Image(.checkwhite)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                )
        }
    }

    @ViewBuilder
    private var productView: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(.productplaceholder)
                .resizable()
                .scaledToFit()
                .frame(width: 77, height: 77)
            VStack(alignment: .leading, spacing: 5) {
                // Product name
                productTitle
                Text("SANS MARQUE")
                    .font(.graphik(.regular, size: 16))
                Text("6 pièces")
                    .font(.graphik(.regular, size: 13))
                offerTagView(offer: 10)
            }
            Spacer()
            if productMarked {
                actionButton(image: .checked)
            } else {
                actionButton(image: .moremenu)
            }
        }
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 0)
        .contentShape(Rectangle())
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear { cardHeight = geo.size.height }
                    .onChange(of: geo.size.height) { _, newValue in
                        cardHeight = newValue
                    }
            }
        )
    }

    @ViewBuilder
    private var productTitle: some View {
        Group {
            if productMarked {
                HStack(alignment: .center, spacing: 2) {
                    Text("[Récupéré] ")
                        .foregroundStyle(.brandprimary)
                    Text("Pommes Gala")
                        .foregroundStyle(.black)
                }
            } else {
                Text("Pommes Gala")
            }
        }
        .lineLimit(1)
        .minimumScaleFactor(0.5)
        .font(.graphik(.bold, size: 16))
        .animation(.none, value: productMarked)
    }

    @ViewBuilder
    private func actionButton(image: ImageResource) -> some View {
        Button {
            productMarked.toggle()
        } label: {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
        }
    }

    @ViewBuilder
    private func offerTagView(offer: Int) -> some View {
        Text("\(offer)% Jour GO! cagnottés")
            .font(.graphik(.bold, size: 12))
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(AnyShapeStyle(.brandGradient))
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

// MARK: PREVIEW
struct ProductDetailsSheet_Preview: PreviewProvider {
    static var previews: some View {
        ProductDetailsSheet(showProductSheet: .constant(true))
            .previewLayout(.sizeThatFits)
            .background(.black)
    }
}
