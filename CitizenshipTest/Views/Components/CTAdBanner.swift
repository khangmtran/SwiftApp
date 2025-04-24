//
//  CTAdBanner.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 4/23/25.
//

import SwiftUI
import GoogleMobileAds

struct CTAdBanner: UIViewRepresentable {
    let adUnitID: String

    func makeUIView(context: Context) -> BannerView {
        let bannerView = BannerView(adSize: AdSizeBanner)
        bannerView.adUnitID = adUnitID

        if let rootVC = UIApplication.shared
            .connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?
            .rootViewController {
            bannerView.rootViewController = rootVC
        }

        bannerView.load(Request())
        return bannerView
    }

    func updateUIView(_ uiView: BannerView, context: Context) {
    }
}

