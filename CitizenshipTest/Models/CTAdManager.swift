//
//  CTAdManager.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 4/24/25.
//

import SwiftUI
import GoogleMobileAds

class InterstitialAdManager: NSObject, ObservableObject {
    static let shared = InterstitialAdManager()
    
    @Published private var interstitialAd: InterstitialAd?
    private let interstitialAdUnitID = "ca-app-pub-3940256099942544/4411468910" // Test ID
    
    // Counters for different activities
    @Published var buttonClicked = 0
    
    // Constants for when to show ads
    private let buttonThreshold = 20
    
    private override init() {
        super.init()
        Task {
            await loadAd()
        }
    }
    
    func loadAd() async {
        do {
            interstitialAd = try await InterstitialAd.load(
                with: interstitialAdUnitID, request: Request())
            interstitialAd?.fullScreenContentDelegate = self
        } catch {
            print("Failed to load interstitial ad with error: \(error.localizedDescription)")
        }
    }
    
    func showAd() {
        guard let interstitialAd = interstitialAd else {
            print("Ad wasn't ready.")
            Task {
                await loadAd()
            }
            return
        }
        
        interstitialAd.present(from: nil)
    }
    
    // Method to increment test question counter and show ad if needed
    func incrementButtonCounter() -> Bool {
        buttonClicked += 1
        
        if buttonClicked >= buttonThreshold {
            buttonClicked = 0
            showAd()
            return true
        }
        return false
    }
}

// MARK: - FullScreenContentDelegate
extension InterstitialAdManager: FullScreenContentDelegate {
    func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
        print("Interstitial ad impression recorded")
    }
    
    func adDidRecordClick(_ ad: FullScreenPresentingAd) {
        print("Interstitial ad click recorded")
    }
    
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Interstitial ad failed to present with error: \(error.localizedDescription)")
    }
    
    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("Interstitial ad will present")
    }
    
    func adWillDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("Interstitial ad will dismiss")
    }
    
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("Interstitial ad did dismiss")
        // Clear the interstitial ad and load a new one
        interstitialAd = nil
        Task {
            await loadAd()
        }
    }
}
