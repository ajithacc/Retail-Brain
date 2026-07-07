//
//  GraphikFont.swift
//  RetailBrain
//
//  Created by muhammed.nadeem.m.a on 07/07/26.
//  Copyright © 2026 Accenture. All rights reserved.

import SwiftUI

enum GraphikFont: String {
    case regular = "GraphikWeb-Regular"
    case semibold = "GraphikWeb-Semibold"
    case bold = "GraphikWeb-Bold"
    case black = "GraphikWeb-Black"

    func font(size: CGFloat) -> Font {
        Font(uiFont(size: size) as CTFont)
    }

    func uiFont(size: CGFloat) -> UIFont {
        UIFont(name: rawValue, size: size) ?? .systemFont(ofSize: size)
    }
}

extension Font {
    static func graphik(_ style: GraphikFont, size: CGFloat) -> Font {
        style.font(size: size)
    }
}
