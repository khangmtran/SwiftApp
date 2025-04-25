//
//  CTAdBanner.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 4/23/25.
//

import SwiftUI
import GoogleMobileAds

struct CTAdBannerView: View {
    // Preset test Ad Unit ID from Google
    private let adUnitID = "ca-app-pub-3940256099942544/2435281174"

    var body: some View {
        GeometryReader { geometry in
            let adSize = currentOrientationAnchoredAdaptiveBanner(width: geometry.size.width)

            VStack {
                //Spacer()
                CTBannerViewContainer(adUnitID: adUnitID, adSize: adSize)
                    .frame(height: adSize.size.height)
            }.frame(height: adSize.size.height)
        }
    }
}

private struct CTBannerViewContainer: UIViewRepresentable {
    let adUnitID: String
    let adSize: AdSize

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.addSubview(context.coordinator.bannerView)
        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.bannerView.adSize = adSize
    }

    class Coordinator: NSObject, BannerViewDelegate {
        let parent: CTBannerViewContainer

        private(set) lazy var bannerView: BannerView = {
            let banner = BannerView(adSize: parent.adSize)
            banner.adUnitID = parent.adUnitID
            banner.delegate = self
            banner.rootViewController = UIApplication.shared
                .connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first(where: { $0.isKeyWindow })?
                .rootViewController
            banner.load(Request())
            return banner
        }()

        init(_ parent: CTBannerViewContainer) {
            self.parent = parent
        }

        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            print("Ad received.")
        }

        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            print("Ad failed to load: \(error.localizedDescription)")
        }
    }
}
