//
//  CTAdBannerManager.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 6/27/25.
//

import SwiftUI
import GoogleMobileAds

//bannerView.adUnitID = "ca-app-pub-7559937369988658/2534269159" //Real ID

class BannerAdManager: NSObject, ObservableObject, BannerViewDelegate {
    let bannerView: BannerView
    @Published var isAdReady = false

    init(storeManager: StoreManager, networkMonitor: NetworkMonitor = .shared) {
        self.bannerView = BannerView(adSize: AdSizeBanner)
        super.init()

        bannerView.adUnitID = "ca-app-pub-3940256099942544/2435281174" // Test ID
        bannerView.delegate = self

        if !storeManager.isPurchased("KnT.CitizenshipTest.removeAds") && networkMonitor.isConnected {
            bannerView.load(Request())
        }
    }

    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        isAdReady = true
    }

    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        isAdReady = false
    }
}


struct CTAdBannerView: UIViewControllerRepresentable {
    @EnvironmentObject var storeManager: StoreManager
    @EnvironmentObject var adManager: BannerAdManager
    @StateObject private var networkMonitor = NetworkMonitor.shared

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()

        // Only add ad if user hasn’t removed ads
        if storeManager.isPurchased("KnT.CitizenshipTest.removeAds") || !networkMonitor.isConnected {
            return viewController
        }

        let banner = adManager.bannerView
        banner.rootViewController = viewController

        // Avoid adding the banner multiple times
        if banner.superview == nil {
            viewController.view.addSubview(banner)
        }

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
