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
    let onClick: (FloatingMenuItem) -> Void

    private var totalTagCount: Int {
        FloatingMenuItem.totalTagCount
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .trailing, spacing: 18) {
                ForEach(Array(FloatingMenuItem.menu.enumerated()), id: \.element.id) { index, menu in
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
                Image(.chevron)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .rotationEffect(.degrees(expanded ? 0 : 180))
                    .padding(20)
                    .background(.white)
                    .clipShape(Circle())
                    .shadow(radius: 10)
                if totalTagCount > 0 && !expanded {
                    Text("\(totalTagCount)")
                        .font(.graphik(.bold, size: 16))
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(.brandPrimary)
                        .clipShape(Circle())
                        .overlay {
                            Circle()
                                .stroke(.white, lineWidth: 2)
                        }
                        .offset(y: -6)
                        .transition(.scale)
                }
            }
        }
        .buttonStyle(NoAnimationButton())
    }

    @ViewBuilder
    private func menuItem(menu: FloatingMenuItem) -> some View {
        Button {
            withAnimation(.spring()) {
                expanded = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                onClick(menu)
            }
        } label: {
            HStack(spacing: 16) {
                Text(menu.title)
                    .foregroundStyle(menu.highlight ? .white : .black)
                    .font(.graphik(.regular, size: 16))
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(menu.highlight ? AnyShapeStyle(
                        LinearGradient(
                            colors: [
                                Color(hex: "#460073"),
                                Color(hex: "#8400D9")
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    ) : AnyShapeStyle(Color.white))
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .shadow(color: .black.opacity(0.2), radius: 8)

                ZStack(alignment: .topTrailing) {
                    Image(menu.image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .padding(20)
                        .background(menu.highlight ? AnyShapeStyle(
                            LinearGradient(
                                colors: [
                                    Color(hex: "#460073"),
                                    Color(hex: "#8400D9")
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        ) : AnyShapeStyle(Color.white))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.25), radius: 8)
                    // Tag
                    if let tag = menu.tag {
                        Text("\(tag)")
                            .font(.graphik(.bold, size: 16))
                            .foregroundStyle(.white)
                            .padding(8)
                            .background(Color(hex: "#FF50A0"))
                            .clipShape(Circle())
                            .overlay {
                                Circle()
                                    .stroke(.white, lineWidth: 1.3)
                            }
                            .offset(y: -6)
                    }
                }
            }
        }
        .buttonStyle(NoAnimationButton())
    }
}
