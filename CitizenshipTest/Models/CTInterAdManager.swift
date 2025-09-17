//
//  CTAdManager.swift
//  CitizenshipTest
//
//  Modified to pause/resume timer instead of resetting
//

import SwiftUI
import GoogleMobileAds

class InterstitialAdManager: NSObject, ObservableObject {
    static let shared = InterstitialAdManager()
    @Published private var interstitialAd: InterstitialAd?
    // FLAG TO DISABLE ADS
    private let adsDisabled = false
    // Minimum interval between ads
    private let minimumAdInterval: TimeInterval = 120 // 2 minutes
    
    // Timer tracking variables
    private var timerStartTime: Date = Date()
    private var accumulatedTime: TimeInterval = 0
    private var isTimerRunning: Bool = true
    
    //ads ID
    //private let interstitialAdUnitID = "ca-app-pub-3940256099942544/4411468910" // Test ID
    private let interstitialAdUnitID = "ca-app-pub-7559937369988658/4112727092" // Real ID
    
    // Reference to StoreManager - will be set from the app
    private var storeManager: StoreManager?
    private let networkMonitor = NetworkMonitor.shared
    
    private var isLoadingAd = false
    
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
        
        // Start the timer
        startTimer()
    }
    
    // Resume the timer when app becomes active
    @objc private func appDidBecomeActive() {
        if adsDisabled { return }
        resumeTimer()
    }
    
    // Pause the timer when app goes to background
    @objc private func appWillResignActive() {
        if adsDisabled { return }
        pauseTimer()
    }
    
    // Start/restart the timer from the beginning
    private func startTimer() {
        if adsDisabled { return }
        timerStartTime = Date()
        accumulatedTime = 0
        isTimerRunning = true
    }
    
    // Pause the timer and accumulate the elapsed time
    private func pauseTimer() {
        if adsDisabled { return }
        guard isTimerRunning else { return }
        
        let elapsedTime = Date().timeIntervalSince(timerStartTime)
        accumulatedTime += elapsedTime
        isTimerRunning = false
    }
    
    // Resume the timer from where it was paused
    private func resumeTimer() {
        if adsDisabled { return }
        guard !isTimerRunning else { return }
        timerStartTime = Date()
        isTimerRunning = true
    }
    
    // Reset the timer completely (call this after showing an ad)
    private func resetTimer() {
        if adsDisabled { return }
        accumulatedTime = 0
        timerStartTime = Date()
        isTimerRunning = true
    }
    
    // Calculate total elapsed time (accumulated + current session if running)
    private func getTotalElapsedTime() -> TimeInterval {
        if adsDisabled { return 0 }
        
        var totalTime = accumulatedTime
        
        if isTimerRunning {
            let currentSessionTime = Date().timeIntervalSince(timerStartTime)
            totalTime += currentSessionTime
        }
        
        return totalTime
    }
    
    // Check if enough time has passed since timer started
    private func hasEnoughTimePassedSinceTimerStart() -> Bool {
        if adsDisabled { return false }
        
        let totalElapsedTime = getTotalElapsedTime()
        
        return totalElapsedTime >= minimumAdInterval
    }
    
    @MainActor
    func loadAd() async {
        guard GoogleMobileAdsConsentManager.shared.isMobileAdsStartCalled else {
#if DEBUG
            print("MobileAds not initialized yet - skipping inter ad load")
#endif
            return
        }
        
        guard GoogleMobileAdsConsentManager.shared.canRequestAds else {
#if DEBUG
            print("cannot request ads - ConsentInformation.shared.canRequestAds")
#endif
            return
        }
        
        // Don't load ads if disabled or user has purchased ad removal
        if adsDisabled || isLoadingAd { return }
        
        if let storeManager = storeManager, storeManager.isPurchased("KnT.CitizenshipTest.removeAds") {
            return
        }
        
        guard networkMonitor.isConnected else {
#if DEBUG
            print("No internet connection - skipping ad load")
#endif
            return
        }
        
        isLoadingAd = true
        defer {
#if DEBUG
            print("Done loading new ad")
#endif
            isLoadingAd = false
        }
        
        do {
            if interstitialAd == nil {
#if DEBUG
            print("Load ad")
#endif
                interstitialAd = try await InterstitialAd.load(
                    with: interstitialAdUnitID, request: Request())
                interstitialAd?.fullScreenContentDelegate = self
            }
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
        
        if interstitialAd == nil {
#if DEBUG
            print("No ads yet, proceed to load new ad")
#endif
            Task {
                await loadAd()
            }
            return
        }
        else{
#if DEBUG
            print("Ad is ready")
#endif
            if !hasEnoughTimePassedSinceTimerStart(){
#if DEBUG
                print("However, time elapsed has not passed timer, so no show ad. Time elapsed: \(getTotalElapsedTime())")
#endif
            }
        }
        
        // Only show ad if enough time has passed since timer started
        if hasEnoughTimePassedSinceTimerStart() {
            interstitialAd?.present(from: nil)
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
        resetTimer() // Reset timer after showing an ad
        interstitialAd = nil
        Task {
            await loadAd()
        }
    }
}
