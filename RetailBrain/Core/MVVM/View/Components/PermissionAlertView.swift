//
//  PermissionAlertView.swift
//  RetailBrain
//
//  Created by muhammed.nadeem.m.a on 07/07/26.
//  Copyright © 2026 Accenture. All rights reserved.

import SwiftUI

struct PermissionAlertView: View {

    @ObservedObject var viewModel: StoreViewModel

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            VStack(spacing: 16) {
                Image(.permission)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 158, height: 132)
                VStack(spacing: 16) {
                    Text(String(localized: "permission.alert.title"))
                        .font(.graphik(.bold, size: 28))
                    Text(String(localized: "permission.alert.message"))
                        .font(.graphik(.regular, size: 18))
                }
                .multilineTextAlignment(.center)
                .padding(.vertical)
                // Accept and Reject button
                HStack(spacing: 16) {
                    Button(action: viewModel.dismissPermissionAlert) {
                        Text(String(localized: "permission.alert.decline"))
                            .font(.graphik(.bold, size: 16))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(.white)
                            .clipShape(Capsule())
                    }
                    .shadow(color: .black.opacity(0.25), radius: 8)

                    PrimaryButton(title: String(localized: "permission.alert.accept"), action: viewModel.acceptPermission)
                }
            }
            .padding(25)
            .frame(maxWidth: 450)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(alignment: .topTrailing) {
                Button(action: viewModel.dismissPermissionAlert) {
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
