//
//  FloatingMenuItem.swift
//  RetailBrain
//
//  Created by muhammed.nadeem.m.a on 09/07/26.
//  Copyright © 2026 Accenture. All rights reserved.
//

import Foundation

struct FloatingMenuItem: Identifiable {
    let id = UUID()
    let title: String
    let image: String
    let highlight: Bool
    let tag: Int?
}

extension FloatingMenuItem {

    static var totalTagCount: Int {
        menu.compactMap(\.tag).reduce(0, +)
    }

    static let menu: [Self] = [
        .init(
            title: "Mes Défis",
            image: "mesdefis",
            highlight: true,
            tag: 5,
        ),
        .init(
            title: "Contenu Enrichi",
            image: "contenuenrichi",
            highlight: false,
            tag: nil,
        ),
        .init(
            title: "Mes Listes",
            image: "meslistes",
            highlight: false,
            tag: nil,
        )
    ]
}
