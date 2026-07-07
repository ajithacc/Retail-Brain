//
//  StoreView.swift
//  RetailBrain
//
//  Created by muhammed.nadeem.m.a on 07/07/26.
//  Copyright © 2026 Accenture. All rights reserved.

import SwiftUI

struct StoreView: View {

    @StateObject private var viewModel = StoreViewModel()

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                // Store Selector
                storeSelectorView
                // Feature Title
                featuresTitle
                // Feature List
                featureList
            }
            // Permission alert popup
            if viewModel.showPermissionAlert {
                permissionAlert
            }
        }
    }
}

// MARK: SUBVIEWS
extension StoreView {

    @ViewBuilder
    private var storeSelectorView: some View {
        HStack(alignment: .center) {
            Image(.store)
                .resizable()
                .scaledToFit()
                .frame(width: 26, height: 24)
                .padding(.trailing, 8)
            VStack(alignment: .leading, spacing: 5) {
                Text("Mon Magasin")
                    .font(.graphik(.black, size: 20))
                    .foregroundStyle(.brandPrimary)
                Text("Accenture Store\nParis 13 ème")
                    .font(.graphik(.black, size: 21))
                    .foregroundStyle(.black)
                HStack(spacing: 5) {
                    Circle()
                        .fill(Color(hex: "#009854"))
                        .frame(width: 7, height: 7)
                    Text("Ouvert aujourd’hui jusque 21:30")
                        .font(.graphik(.regular, size: 13))
                        .foregroundStyle(.black)
                }
            }
            Spacer()
            Image(.chevron)
                .resizable()
                .scaledToFit()
                .frame(width: 13, height: 6)
        }
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding()
        .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 0)
    }

    @ViewBuilder
    private var featuresTitle: some View {
        Text("A utiliser dans votre magasin")
            .font(.graphik(.regular, size: 20))
            .foregroundStyle(.black)
            .padding(.horizontal)
            .padding(.top, 20)
            .padding(.bottom, 10)
    }

    @ViewBuilder
    private var featureList: some View {
        ScrollView {
            ForEach(Feature.sampleData) { feature in
                Button {
                    if feature.title == "Itinéraire guidé" {
                        viewModel.showPermissionAlert.toggle()
                    } else {
                        print("\(feature.title) Clicked!")
                    }
                } label: {
                    featureRow(feature)
                }
            }
        }
        .padding(.top, 10)
        .padding(.horizontal)
    }

    @ViewBuilder
    private func featureRow(_ feature: Feature) -> some View {
        HStack(alignment: .center, spacing: 10) {
            Image(feature.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)
            VStack(alignment: .leading, spacing: 5) {
                Text(feature.title)
                    .font(.graphik(.regular, size: 19))
                Text(feature.subtitle)
                    .font(.graphik(.regular, size: 14))
                    .lineSpacing(5)
            }
            .foregroundStyle(.black)
            .multilineTextAlignment(.leading)
            Spacer()
            Image(.chevron)
                .resizable()
                .scaledToFit()
                .rotationEffect(.degrees(-90))
                .frame(width: 13, height: 6)
        }
        .padding(.horizontal, 10)
        .padding(.vertical)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.vertical, 2)
    }

}

// MARK: PERMISSION ALERT
extension StoreView {

    @ViewBuilder
    private var permissionAlert: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            VStack(spacing: 16) {
                Image(.permission)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 158, height: 132)
                VStack(spacing: 16) {
                    Text("Accenture Store\naimerait utiliser votre localisation bluetooth")
                        .font(.graphik(.bold, size: 28))
                    Text("Activez le Bluetooth pour suivre votre parcours d’achat en magasin.")
                        .font(.graphik(.regular, size: 18))
                }
                .multilineTextAlignment(.center)
                .padding(.vertical)
                // Accept and Reject button
                HStack(spacing: 16) {
                    Button("Refuser", action: dismissPermissionAlert)
                        .font(.graphik(.bold, size: 16))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.white)
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.25), radius: 8)

                    PrimaryButton(title: "Accepter", action: dismissPermissionAlert)
                }
            }
            .padding(25)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(alignment: .topTrailing) {
                Button(action: dismissPermissionAlert) {
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

    private func dismissPermissionAlert() {
        viewModel.showPermissionAlert = false
    }

}

#Preview {
    StoreView()
}
