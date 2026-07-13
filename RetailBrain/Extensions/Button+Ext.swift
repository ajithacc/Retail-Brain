//
//  Button+Ext.swift
//  RetailBrain
//
//  Created by muhammed.nadeem.m.a on 07/07/26.
//  Copyright © 2026 Accenture. All rights reserved.

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let image: String?
    let action: () -> Void

    init(title: String, image: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.image = image
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let image {
                    Image(image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                }
                Text(title)
                    .font(.graphik(.bold, size: 16))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(.brandPrimary)
            .clipShape(Capsule())
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct NoAnimationButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 1.0 : 1.0)
    }
}
