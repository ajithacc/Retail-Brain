//
//  NFCOverlayView.swift
//  RetailBrain
//
//  Created by muhammed.nadeem.m.a on 13/07/26.
//  Copyright © 2026 Accenture. All rights reserved.
//

import SwiftUI

struct NFCOverlayView: View {

    @Binding var showNFCOverlay: Bool

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            VStack(alignment: .center, spacing: 16) {
                Image(.nfcdescimage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 288, height: 151)
                    .padding(.top)

                VStack(spacing: 8) {
                    Text(String(localized: "nfcoverlay.title"))
                        .font(.graphik(.regular, size: 24))
                        .foregroundStyle(.brandPrimary)
                    Group {
                        Text(String(localized: "nfc.overlay.parnfc"))
                        Text(String(localized: "nfc.overlay.description"))
                    }
                    .font(.graphik(.regular, size: 16))
                    .foregroundStyle(.black)
                }
                .multilineTextAlignment(.center)

                HStack(alignment: .center) {
                    Image(.nfcbadge)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    Text(String(localized: "nfc.overlay.hint"))
                        .font(.graphik(.bold, size: 12))
                        .foregroundStyle(.red)
                }

                Spacer()
                    .frame(height: 80)
            }
            .padding(25)
            .frame(maxWidth: 450)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(alignment: .topTrailing) {
                Button {
                    showNFCOverlay = false
                } label: {
                    Image(.close)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .padding()
                }
            }
            .padding()
        }
    }
}

#Preview {
    NFCOverlayView(showNFCOverlay: .constant(true))
}
