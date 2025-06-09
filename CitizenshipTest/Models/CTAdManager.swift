//
//  CTAdManager.swift
//  CitizenshipTest
//
//  Modified on 5/16/25
//

import SwiftUI
import GoogleMobileAds

class InterstitialAdManager: NSObject, ObservableObject {
    static let shared = InterstitialAdManager()
    
    @Published private var interstitialAd: InterstitialAd?
    
    // Minimum interval between ads (in seconds)
    private let minimumAdInterval: TimeInterval = 120 // 2 minutes
    
    // Track when ad timer started (reset when app becomes active)
    private var adTimerStartTime: Date = Date()
    private var isAppActive: Bool = true
    private let interstitialAdUnitID = "ca-app-pub-3940256099942544/4411468910" // Test ID
    
    // Reference to StoreManager - will be set from the app
    private var storeManager: StoreManager?
    
    func setStoreManager(_ manager: StoreManager) {
        self.storeManager = manager
    }
    
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
        // Don't load ads if user has purchased ad removal
        if let storeManager = storeManager, storeManager.isPurchased("KnT.CitizenshipTest.removeAds") {
            return
        }
        
        do {
            interstitialAd = try await InterstitialAd.load(
                with: interstitialAdUnitID, request: Request())
            interstitialAd?.fullScreenContentDelegate = self
        } catch {
#if DEBUG
            print("Failed to load ad: \(error)")
#endif
        }
    }
    
    @MainActor
    func showAd() {
        // Don't show ads if user has purchased ad removal
        if let storeManager = storeManager, storeManager.isPurchased("KnT.CitizenshipTest.removeAds") {
            return
        }
        
        // Only show ad if enough time has passed since timer reset
        if hasEnoughTimePassedSinceTimerReset() {
            guard let interstitialAd = interstitialAd else {
                Task {
                    await loadAd()
                }
                return
            }
            
            interstitialAd.present(from: nil)
        } else {
        }
    }
}

// MARK: - FullScreenContentDelegate
extension InterstitialAdManager: FullScreenContentDelegate {
    func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
    }
    
    func adDidRecordClick(_ ad: FullScreenPresentingAd) {
    }
    
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
    }
    
    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
    }
    
    func adWillDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
    }
    
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        resetAdTimer()
        interstitialAd = nil
        Task {
            await loadAd()
        }
    }
}
