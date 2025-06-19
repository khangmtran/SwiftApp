//
//  CTAdManager.swift
//  CitizenshipTest
//
//  Modified to disable ads for App Store submission
//

import SwiftUI
import GoogleMobileAds

class InterstitialAdManager: NSObject, ObservableObject {
    static let shared = InterstitialAdManager()
    @Published private var interstitialAd: InterstitialAd?
    // FLAG TO DISABLE ADS
    private let adsDisabled = false
    // Minimum interval between ads
    private let minimumAdInterval: TimeInterval = 60 // 1 minute
    // Track when ad timer started (reset when app becomes active)
    private var adTimerStartTime: Date = Date()
    private var isAppActive: Bool = true
    //private let interstitialAdUnitID = "ca-app-pub-3940256099942544/4411468910" // Test ID
    private let interstitialAdUnitID = "ca-app-pub-7559937369988658/4112727092" // Real ID
    // Reference to StoreManager - will be set from the app
    private var storeManager: StoreManager?
    private let networkMonitor = NetworkMonitor.shared
    
    func setStoreManager(_ manager: StoreManager) {
        self.storeManager = manager
    }
    
    private override init() {
        super.init()
        
        // Don't initialize anything if ads are disabled
        if adsDisabled {
            return
        }
        
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
        if adsDisabled { return }
        resetAdTimer()
        isAppActive = true
    }
    
    // Mark app as inactive when it goes to background
    @objc private func appWillResignActive() {
        if adsDisabled { return }
        isAppActive = false
    }
    
    // Reset the ad timer - called when app becomes active
    private func resetAdTimer() {
        if adsDisabled { return }
        adTimerStartTime = Date()
    }
    
    // Check if enough time has passed since timer was reset
    private func hasEnoughTimePassedSinceTimerReset() -> Bool {
        if adsDisabled { return false }
        
        // If app is not active, then time requirement isn't met
        if !isAppActive {
            return false
        }
        
        let timeSinceReset = Date().timeIntervalSince(adTimerStartTime)
        return timeSinceReset >= minimumAdInterval
    }
    
    @MainActor
    func loadAd() async {
        // Don't load ads if disabled or user has purchased ad removal
        if adsDisabled { return }
        
        if let storeManager = storeManager, storeManager.isPurchased("KnT.CitizenshipTest.removeAds") {
            return
        }
        
        guard networkMonitor.isConnected else {
#if DEBUG
            print("No internet connection - skipping ad load")
#endif
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
        // Don't show ads if disabled or user has purchased ad removal
        if adsDisabled { return }
        
        if let storeManager = storeManager, storeManager.isPurchased("KnT.CitizenshipTest.removeAds") {
            return
        }
        
        guard networkMonitor.isConnected else {
#if DEBUG
            print("No internet connection - skipping ad display")
#endif
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
        if adsDisabled { return }
        resetAdTimer()
        interstitialAd = nil
        Task {
            await loadAd()
        }
    }
}
