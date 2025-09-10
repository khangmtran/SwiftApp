//
//  CTPrivacyOption.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 9/9/25.
//

import SwiftUI

struct CTPrivacyOptionsButton: View {
    @EnvironmentObject var consentManager: GoogleMobileAdsConsentManager
    @State private var isProcessing = false
    
    var body: some View {
            Button(action: {
                Task {
                    isProcessing = true
                    defer { isProcessing = false }
                    do {
                        try await consentManager.presentPrivacyOptionsForm()
                    } catch {
                    }
                }
            }) {
                HStack {
                    Text("Tùy Chọn Quyền Riêng Tư")
                    Spacer()
                    if isProcessing {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }
                .foregroundColor(.primary)
            }
            .disabled(isProcessing)
    }
}
