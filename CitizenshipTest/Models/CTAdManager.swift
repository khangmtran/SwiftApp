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
    @Published var testQuestionCounter = 0
    @Published var audioQuestionCounter = 0
    
    // Constants for when to show ads
    private let testQuestionThreshold = 10
    private let audioQuestionThreshold = 10
    
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
    func incrementTestQuestionCounter() -> Bool {
        testQuestionCounter += 1
        
        if testQuestionCounter >= testQuestionThreshold {
            testQuestionCounter = 0
            showAd()
            return true
        }
        return false
    }
    
    // Method to increment audio question counter and show ad if needed
    func incrementAudioQuestionCounter() -> Bool {
        audioQuestionCounter += 1
        
        if audioQuestionCounter >= audioQuestionThreshold {
            audioQuestionCounter = 0
            showAd()
            return true
        }
        return false
    }
    
    // Method to show ad after test completion
    func showAdAfterTest() {
        // Reset the test question counter
        testQuestionCounter = 0
        showAd()
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
