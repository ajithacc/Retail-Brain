//
//  CurrentDestinationView.swift
//  RetailBrain
//
//  Created by muhammed.nadeem.m.a on 13/07/26.
//  Copyright © 2026 Accenture. All rights reserved.
//

import SwiftUI

struct CurrentDestinationView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(String(localized: "guided_nav.route.in_progress"))
                .font(.graphik(.regular, size: 14))
                .foregroundStyle(.brandPrimary)
            HStack(alignment: .center) {
                Image(.bluedot)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                Text(String(localized: "common.location"))
                    .font(.graphik(.bold, size: 14))
                    .foregroundStyle(.black)
                Text(String(localized: "guided_nav.location.value"))
                    .font(.graphik(.regular, size: 14))
                    .foregroundStyle(.black)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color(hex: "#F7F7F7"))
            .clipShape(RoundedRectangle(cornerRadius: 5))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    CurrentDestinationView()
}
