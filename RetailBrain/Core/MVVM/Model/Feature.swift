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
            title: "Itinéraire guidé",
            subtitle: "Chercher un produit en magasin et laissez l’app vous guider !",
            imageName: "guided_route"
        ),
        Feature(
            title: "Scan to Go",
            subtitle: "Scanner et payez vos produits directement depuis l’app.",
            imageName: "scan_to_go"
        ),
        Feature(
            title: "Ma carte GO!",
            subtitle: "Présentez votre carte de fidélité à la caisse, et faites des économies !",
            imageName: "go_card"
        ),
        Feature(
            title: "Scan Prix",
            subtitle: "Affichez le prix magasin d’un produit de n’importe où.",
            imageName: "scan_price"
        ),
        Feature(
            title: "Mes mémos",
            subtitle: "Pratiques ! Préparez vos listes de courses pour ne rien oublier...",
            imageName: "memos"
        )
    ]
}
