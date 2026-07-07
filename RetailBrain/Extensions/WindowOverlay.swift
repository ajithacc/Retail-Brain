//
//  WindowOverlay.swift
//  RetailBrain
//
//  Created by muhammed.nadeem.m.a on 07/07/26.
//  Copyright © 2026 Accenture. All rights reserved.

import SwiftUI

extension View {
    func windowOverlay<OverlayContent: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> OverlayContent) -> some View {
        modifier(WindowOverlayModifier(isPresented: isPresented, overlayContent: content))
    }
}

private struct WindowOverlayModifier<OverlayContent: View>: ViewModifier {

    @Binding var isPresented: Bool
    @ViewBuilder let overlayContent: () -> OverlayContent
    @State private var overlayWindow: UIWindow?

    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { _, newValue in
                newValue ? present() : dismiss()
            }
            .onDisappear(perform: dismiss)
    }

    private func present() {
        guard overlayWindow == nil, let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) else { return }

        let hostingController = UIHostingController(rootView: overlayContent())
        hostingController.view.backgroundColor = .clear

        let window = UIWindow(windowScene: scene)
        window.rootViewController = hostingController
        window.backgroundColor = .clear
        window.windowLevel = .alert + 1
        window.isHidden = false
        window.makeKeyAndVisible()

        overlayWindow = window
    }

    private func dismiss() {
        overlayWindow?.isHidden = true
        overlayWindow = nil
    }
}
