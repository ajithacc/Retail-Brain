//
//  CustomLoader.swift
//  RetailBrain
//
//  Created by muhammed.nadeem.m.a on 14/07/26.
//  Copyright © 2026 Accenture. All rights reserved.

import SwiftUI

struct LoaderView: View {

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(1.5)
                .tint(.brandPrimary)
                .padding(28)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

enum CustomLoader {

    fileprivate static var loaderWindow: UIWindow?

    static func show() {
        let windowScenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
        guard loaderWindow == nil,
              let scene = windowScenes.first(where: { $0.activationState == .foregroundActive })
                ?? windowScenes.first else { return }
        let hostingController = UIHostingController(rootView: LoaderView())
        hostingController.view.backgroundColor = .clear
        let window = UIWindow(windowScene: scene)
        window.rootViewController = hostingController
        window.backgroundColor = .clear
        window.windowLevel = .alert + 1
        window.isHidden = false
        window.makeKeyAndVisible()
        loaderWindow = window
    }

    static func hide() {
        loaderWindow?.isHidden = true
        loaderWindow = nil
    }
}
