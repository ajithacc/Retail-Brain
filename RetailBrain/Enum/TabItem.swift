//
//  TabItem.swift
//  RetailBrain
//
//  Created by muhammed.nadeem.m.a on 07/07/26.
//  Copyright © 2026 Accenture. All rights reserved.

import Foundation

enum TabItem: Hashable, CaseIterable {
    case online
    case store
    case wallet
    case account

    var title: String {
        switch self {
        case .online:
            return String(localized: "tab.online.title")
        case .store:
            return String(localized: "tab.store.title")
        case .wallet:
            return String(localized: "tab.wallet.title")
        case .account:
            return String(localized: "tab.account.title")
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
