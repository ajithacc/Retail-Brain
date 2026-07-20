//
//  ProductDetailsSheetView.swift
//  RetailBrainApp
//
//  Created by ajith.a.s on 07/07/26.
//

import SwiftUI

struct ProductDetailsSheetView: View {
    @Environment(\.dismiss) private var dismiss
    let product: AppProductDetails
    var onClose: (() -> Void)? = nil
    @State private var isActionRevealed = false
    @State private var dragTranslationX: CGFloat = 0
    @State private var isChecked = false

    private let revealWidth: CGFloat = 94
    private let revealGap: CGFloat = 8

    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            titleRow
            sectionLabel
            productContainer
        }
        .padding(.horizontal)
        .padding(.top, 0)
        .padding(.bottom, 10)
        .background(ProductDetailsSheetConstants.backgroundNeutral)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.08), radius: 2.9, x: 0, y: -3)
    }

    private var titleRow: some View {
        HStack(alignment: .center, spacing: 11) {
            Text(ProductDetailsSheetConstants.titleText)
                .font(sheetFont(size: 24, weight: .bold))
                .foregroundColor(ProductDetailsSheetConstants.buttonNeutralTextPicto)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: handleCloseTap) {
                Image(ProductDetailsSheetConstants.closeIconAssetName)
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(ProductDetailsSheetConstants.buttonNeutralTextPicto)
                    .frame(width: 36, height: 36)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 0)
        .padding(.top, 11)
        .padding(.bottom, 0)
        .frame(width: 390, alignment: .center)
    }

    private func handleCloseTap() {
        if let onClose {
            onClose()
            return
        }

        dismiss()
    }

    private var sectionLabel: some View {
        HStack(alignment: .center, spacing: 8) {
            Image(ProductDetailsSheetConstants.mapPinAssetName)
                .resizable()
                .frame(width: 16, height: 16)
                .foregroundColor(ProductDetailsSheetConstants.accent)

            Text(product.locationName)
                .font(sheetFont(size: 16, weight: .regular))
                .foregroundColor(ProductDetailsSheetConstants.buttonNeutralTextPicto)
                .lineLimit(1)
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 4)
        .frame(height: 24, alignment: .leading)
        .background(ProductDetailsSheetConstants.backgroundNeutral2)
        .cornerRadius(8)
    }

    private var productContainer: some View {
        ZStack(alignment: .trailing) {
            trailingActionArea

            swipeableMainCard
        }
        .frame(width: 390, alignment: .center)
    }

    @ViewBuilder
    private var swipeableMainCard: some View {
        if isChecked {
            mainCard
                .offset(x: 0)
        } else {
            mainCard
                .offset(x: currentCardOffset)
                .gesture(swipeGesture)
        }
    }

    private var mainCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                productImage

                VStack(alignment: .leading, spacing: 3) {
                    Text(ProductDetailsSheetConstants.productNameText)
                        .font(sheetFont(size: 16, weight: .bold))
                        .foregroundColor(ProductDetailsSheetConstants.buttonNeutralTextPicto)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(ProductDetailsSheetConstants.productBrandText)
                        .font(sheetFont(size: 16, weight: .regular))
                        .foregroundColor(ProductDetailsSheetConstants.buttonNeutralTextPicto)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(ProductDetailsSheetConstants.productQuantityText)
                        .font(sheetFont(size: 13, weight: .regular))
                        .foregroundColor(ProductDetailsSheetConstants.buttonNeutralTextPicto)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    offerTag
                }

                VStack {
                    Spacer()

                    mainCardTrailingIcon
                    .buttonStyle(.plain)

                    Spacer()
                }
            }
        }
        .padding(.leading, 11)
        .padding(.trailing, 30)
        .padding(.top, 11)
        .padding(.bottom, 10)
        .background(ProductDetailsSheetConstants.backgroundNeutral)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 0)
    }

    private var trailingActionArea: some View {
        HStack(alignment: .center, spacing: 10) {
            Button(action: handleCheckTap) {
                Image(ProductDetailsSheetConstants.checkIconAssetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 35)
        .padding(.vertical, 37)
        .frame(width: revealWidth)
        .frame(maxHeight: .infinity, alignment: .center)
        .background(ProductDetailsSheetConstants.buttonPrimaryBrandBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 0)
    }

    private var mainCardTrailingIcon: some View {
        Button(action: {}) {
            if isChecked {
                Image(ProductDetailsSheetConstants.checkIconAssetName)
                    .frame(width: 24, height: 24)
                    .background(ProductDetailsSheetConstants.buttonPrimaryBrandBackground)
                    .overlay(
                        Rectangle()
                            .stroke(ProductDetailsSheetConstants.buttonPrimaryBrandBackground, lineWidth: 1)
                    )
                    .cornerRadius(5)
            } else {
                Image(ProductDetailsSheetConstants.moreIconAssetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
        }
    }

    private func handleCheckTap() {
        withAnimation(.interactiveSpring(response: 0.25, dampingFraction: 0.86, blendDuration: 0.18)) {
            isChecked = true
            isActionRevealed = false
            dragTranslationX = 0
        }
    }

    private var currentCardOffset: CGFloat {
        let revealedOffset = -(revealWidth + revealGap)
        let baseOffset = isActionRevealed ? revealedOffset : 0
        let combined = baseOffset + dragTranslationX
        return min(0, max(revealedOffset, combined))
    }

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                dragTranslationX = value.translation.width
            }
            .onEnded { value in
                let revealedOffset = -(revealWidth + revealGap)
                let baseOffset = isActionRevealed ? revealedOffset : 0
                let projected = min(0, max(revealedOffset, baseOffset + value.predictedEndTranslation.width))
                let shouldReveal = projected <= -(revealWidth * 0.45)

                withAnimation(.interactiveSpring(response: 0.25, dampingFraction: 0.86, blendDuration: 0.18)) {
                    isActionRevealed = shouldReveal
                    dragTranslationX = 0
                }
            }
    }

    private var productImage: some View {
        Rectangle()
            .foregroundColor(.clear)
            .frame(width: 77, height: 77)
            .background(
                Image(ProductDetailsSheetConstants.placeholderAssetName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 77, height: 77)
                    .clipped()
            )
            .background(ProductDetailsSheetConstants.buttonNeutralBackground)
            .cornerRadius(4)
    }

    private var offerTag: some View {
        HStack(alignment: .center, spacing: 10) {
            Text(ProductDetailsSheetConstants.offerText)
                .font(sheetFont(size: 13, weight: .bold))
                .foregroundColor(.white)

        }
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .frame(maxHeight: .infinity, alignment: .center)
        .background(
            LinearGradient(
                stops: [
                    Gradient.Stop(color: ProductDetailsSheetConstants.loyaltyBackgroundGradient1, location: 0.00),
                    Gradient.Stop(color: ProductDetailsSheetConstants.loyaltyBackgroundGradient2, location: 1.00)
                ],
                startPoint: UnitPoint(x: 0, y: 0.03),
                endPoint: UnitPoint(x: 1, y: 1.03)
            )
        )
        .cornerRadius(5)
        .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 0)
    }

    private func sheetFont(size: CGFloat, weight: Font.Weight) -> Font {
        Font.custom(ProductDetailsSheetConstants.fontName, size: size).weight(weight)
    }
}

#Preview {
    ProductDetailsSheetView(
        product: AppProductDetails(
            name: "Pommes Gala",
            imageName: "",
            locationName: "Rayon - Fruits, Legumes",
            spaceId: nil,
            coordinates: nil
        )
    )
}
