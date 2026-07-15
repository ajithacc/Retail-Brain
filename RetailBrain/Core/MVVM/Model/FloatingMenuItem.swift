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
    let type: MenuType

    enum MenuType: CaseIterable {
        case list
        case enrichedContent
        case challenge
    }
}

extension FloatingMenuItem {

    static var totalTagCount: Int {
        menu.compactMap(\.tag).reduce(0, +)
    }

    static let menu: [Self] = [
        .init(
            title: String(localized: "floating_menu.challenges.title"),
            image: "mesdefis",
            highlight: true,
            tag: 5,
            type: .challenge,
        ),
        .init(
            title: String(localized: "floating_menu.enriched_content.title"),
            image: "contenuenrichi",
            highlight: false,
            tag: nil,
            type: .enrichedContent,
        ),
        .init(
            title: String(localized: "floating_menu.lists.title"),
            image: "meslistes",
            highlight: false,
            tag: nil,
            type: .list,
        )
    ]
}
