//
//  ProductDetailsSheetConstants.swift
//  RetailBrainApp
//
//  Created by ajith.a.s on 08/07/26.
//

import SwiftUI

enum ProductDetailsSheetConstants {
    private static let requestedBrandColor = Color(UIColor(red: 0.63, green: 0, blue: 1, alpha: 1))

    static let fontName = "Helvetica Neue"

    static let backgroundNeutral = Color.white
    static let backgroundNeutral2 = Color(UIColor.systemGray6)
    static let buttonNeutralTextPicto = Color.black
    static let buttonNeutralBackground = Color.white
    static let buttonPrimaryBrandBackground = requestedBrandColor
    static let loyaltyBackgroundGradient1 = Color(red: 0.52, green: 0.08, blue: 0.88)
    static let loyaltyBackgroundGradient2 = Color(red: 0.75, green: 0.20, blue: 0.86)
    static let accent = requestedBrandColor

    // Image assets
    static let closeIconAssetName = "closeIcon"
    static let mapPinAssetName = "mapPin"
    static let moreIconAssetName = "moreIcon"
    static let checkIconAssetName = "check"
    static let placeholderAssetName = "sampleProduct"

    // Display text
    static let titleText = "Produit(s) selectionne(s)"
    static let productNameText = "Pommes Gala"
    static let productBrandText = "SANS MARQUE"
    static let productQuantityText = "6 pieces"
    static let offerText = "10% Jour GO! cagnottes"

    static let sheetHeight: CGFloat = 340
}
