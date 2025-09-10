//
//  CTConsentManager.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 9/9/25.
//

import Foundation
import GoogleMobileAds
import UserMessagingPlatform

@MainActor
class GoogleMobileAdsConsentManager: NSObject, ObservableObject {
    static let shared = GoogleMobileAdsConsentManager()
    
    @Published var isMobileAdsStartCalled = false
    
    var canRequestAds: Bool {
        return ConsentInformation.shared.canRequestAds
    }
    
    var isPrivacyOptionsRequired: Bool {
        return ConsentInformation.shared.privacyOptionsRequirementStatus == .required
    }
    
    /// Helper method to call the UMP SDK methods to request consent information and load/present a
    /// consent form if necessary.
    func gatherConsent(consentGatheringComplete: @escaping (Error?) -> Void) {
        //TESTING PURPOSE
        //ConsentInformation.shared.reset()
        let parameters = RequestParameters()
        
        // For testing purposes, use DebugGeography to simulate a location.
#if DEBUG
        let debugSettings = DebugSettings()
        debugSettings.testDeviceIdentifiers = ["C8E45AB3-5E48-4D96-AAF6-A4589A718307"]
        // Uncomment to test EU consent flow:
        debugSettings.geography = DebugGeography.EEA
        debugSettings.geography = DebugGeography.regulatedUSState
        parameters.debugSettings = debugSettings
#endif
        
        // Requesting an update to consent information should be called on every app launch.
        ConsentInformation.shared.requestConsentInfoUpdate(with: parameters) {
            requestConsentError in
            guard requestConsentError == nil else {
                return consentGatheringComplete(requestConsentError)
            }
            
            Task { @MainActor in
                do {
                    try await ConsentForm.loadAndPresentIfRequired(from: nil)
                    // Consent has been gathered.
                    consentGatheringComplete(nil)
                } catch {
                    consentGatheringComplete(error)
                }
            }
        }
    }
    
    /// Helper method to call the UMP SDK method to present the privacy options form.
    @MainActor func presentPrivacyOptionsForm() async throws {
        try await ConsentForm.presentPrivacyOptionsForm(from: nil)
    }
    
    /// Method to initialize the Google Mobile Ads SDK. The SDK should only be initialized once.
    func startGoogleMobileAdsSDK(storeManager: StoreManager) {
        guard canRequestAds, !isMobileAdsStartCalled else { return }
        isMobileAdsStartCalled = true
#if DEBUG
        print("start mobile ads")
#endif
        // Configure test devices
#if DEBUG
        MobileAds.shared.requestConfiguration.testDeviceIdentifiers = ["c64b645687012dfda0f0866b0c537b67"]
#endif

        // Initialize the Google Mobile Ads SDK.
        MobileAds.shared.start()
        _ = InterstitialAdManager.shared
        InterstitialAdManager.shared.setStoreManager(storeManager)
        Task {
#if DEBUG
            print("done")
#endif
            
#if DEBUG
            print("update store product")
#endif
            
            await storeManager.updatePurchasedProducts()
#if DEBUG
            print("done")
#endif
            
#if DEBUG
            print("load inter ad")
#endif
            await InterstitialAdManager.shared.loadAd()
        }
    }
}
