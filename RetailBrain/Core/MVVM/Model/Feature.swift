//
//  Feature.swift
//  RetailBrain
//
//  Created by muhammed.nadeem.m.a on 07/07/26.
//  Copyright © 2026 Accenture. All rights reserved.

import Foundation

struct Feature: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let imageName: String
}

extension Feature {

    static let sampleData: [Self] = [
        Feature(
            title: String(localized: "feature.guided_route.title"),
            subtitle: String(localized: "feature.guided_route.subtitle"),
            imageName: "guided_route"
        ),
        Feature(
            title: String(localized: "feature.scan_to_go.title"),
            subtitle: String(localized: "feature.scan_to_go.subtitle"),
            imageName: "scan_to_go"
        ),
        Feature(
            title: String(localized: "feature.go_card.title"),
            subtitle: String(localized: "feature.go_card.subtitle"),
            imageName: "go_card"
        ),
        Feature(
            title: String(localized: "feature.scan_price.title"),
            subtitle: String(localized: "feature.scan_price.subtitle"),
            imageName: "scan_price"
        ),
        Feature(
            title: String(localized: "feature.memos.title"),
            subtitle: String(localized: "feature.memos.subtitle"),
            imageName: "memos"
        )
    ]
}
