//
//  TabItem.swift
//  RetailBrain
//
//  Created by muhammed.nadeem.m.a on 07/07/26.
//  Copyright © 2026 Accenture. All rights reserved.

import Foundation

enum TabItem: Hashable {
    case online
    case store
    case wallet
    case account

    var title: String {
        switch self {
        case .online:
            return "En ligne"
        case .store:
            return "En magasin"
        case .wallet:
            return "4,48 €"
        case .account:
            return "Mon compte"
        }
    }

    var imageName: String {
        switch self {
        case .online:
            return "online"
        case .store:
            return "store"
        case .wallet:
            return "go"
        case .account:
            return "account"
        }
    }
}
