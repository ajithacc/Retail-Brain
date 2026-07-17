//
//  ExpandableFloatingMenu.swift
//  RetailBrain
//
//  Created by muhammed.nadeem.m.a on 09/07/26.
//  Copyright © 2026 Accenture. All rights reserved.
//

import SwiftUI

struct ExpandableFloatingMenu: View {

    @Binding var expanded: Bool
    let onClick: (FloatingMenu) -> Void

    private var totalTagCount: Int {
        FloatingMenu.totalTagCount
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .trailing, spacing: 10) {
                ForEach(Array(FloatingMenu.menu.enumerated()), id: \.element.id) { index, menu in
                    menuItem(menu: menu)
                        .scaleEffect(expanded ? 1 : 0.2, anchor: .bottomTrailing)
                        .opacity(expanded ? 1 : 0)
                        .offset(y: expanded ? 0 : 35)
                        .animation(
                            .spring(response: 0.42, dampingFraction: 0.82).delay(Double(index) * 0.05),
                            value: expanded
                        )
                }
                // Floating button
                fabButton
            }
        }
    }

    @ViewBuilder
    private var fabButton: some View {
        Button {
            withAnimation(.spring(response: 0.45,dampingFraction: 0.82)) {
                expanded.toggle()
            }
        } label: {
            ZStack(alignment: .topTrailing) {
                Image(.floatmenu)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(expanded ? 0 : 180))
                if totalTagCount > 0 && !expanded {
                    Text("\(totalTagCount)")
                        .font(.graphik(.bold, size: 16))
                        .foregroundStyle(.white)
                        .padding(6)
                        .background(.brandprimary)
                        .clipShape(Circle())
                        .overlay {
                            Circle()
                                .stroke(.white, lineWidth: 2)
                        }
                        .transition(.opacity)
                }
            }
        }
        .buttonStyle(NoAnimationButton())
    }

    @ViewBuilder
    private func menuItem(menu: FloatingMenu) -> some View {
        Button {
            withAnimation(.spring()) {
                expanded = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                onClick(menu)
            }
        } label: {
            HStack(spacing: 10) {
                Text(menu.title)
                    .foregroundStyle(menu.highlight ? .white : .black)
                    .font(.graphik(.regular, size: 16))
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(menu.highlight ? AnyShapeStyle(.brandGradient) : AnyShapeStyle(.white))
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .shadow(color: .black.opacity(0.2), radius: 8)

                ZStack(alignment: .topTrailing) {
                    Image(menu.image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                    // Tag
                    if let tag = menu.tag {
                        Text("\(tag)")
                            .font(.graphik(.bold, size: 16))
                            .foregroundStyle(.white)
                            .padding(6)
                            .background(.tagbackground)
                            .clipShape(Circle())
                            .overlay {
                                Circle()
                                    .stroke(.white, lineWidth: 1.3)
                            }
                    }
                }
            }
        }
        .buttonStyle(NoAnimationButton())
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    ExpandableFloatingMenu(expanded: .constant(true)) { _ in }
}
