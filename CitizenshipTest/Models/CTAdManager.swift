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
    
    // Minimum interval between ads (in seconds)
    private let minimumAdInterval: TimeInterval = 10 // 2 minutes
    
    // Track when ad timer started (reset when app becomes active)
    private var adTimerStartTime: Date = Date()
    private var isAppActive: Bool = true
    
    private let interstitialAdUnitID = "ca-app-pub-3940256099942544/4411468910" // Test ID
    
    private override init() {
        super.init()
        
        // Register for app lifecycle notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        
        // Start with a fresh timer
        resetAdTimer()
        
        Task {
            await loadAd()
        }
    }
    
    // Reset the ad timer when app becomes active
    @objc private func appDidBecomeActive() {
        resetAdTimer()
        isAppActive = true
    }
    
    // Mark app as inactive when it goes to background
    @objc private func appWillResignActive() {
        isAppActive = false
    }
    
    // Reset the ad timer - called when app becomes active
    private func resetAdTimer() {
        adTimerStartTime = Date()
    }
    
    // Check if enough time has passed since timer was reset
    private func hasEnoughTimePassedSinceTimerReset() -> Bool {
        // If app is not active, then time requirement isn't met
        if !isAppActive {
            return false
        }
        
        let timeSinceReset = Date().timeIntervalSince(adTimerStartTime)
        return timeSinceReset >= minimumAdInterval
    }
    
    @MainActor
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
        // Only show ad if enough time has passed since timer reset
        if hasEnoughTimePassedSinceTimerReset() {
            guard let interstitialAd = interstitialAd else {
                print("Ad wasn't ready.")
                Task {
                    await loadAd()
                }
                return
            }
            
            interstitialAd.present(from: nil)

        } else {
            print("Skipping ad due to minimum time interval not met (time since reset: \(Date().timeIntervalSince(adTimerStartTime)) seconds)")
        }
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
        resetAdTimer()
        // Clear the interstitial ad and load a new one
        interstitialAd = nil
        Task {
            await loadAd()
        }
    }
}
