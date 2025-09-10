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
    let parameters = RequestParameters()
    
    // For testing purposes, you can use DebugGeography to simulate a location.
    let debugSettings = DebugSettings()
    debugSettings.testDeviceIdentifiers = ["b4465261536b1c775bc699401b84862c"] // Your test device
    // Uncomment to test EU consent flow:
    // debugSettings.geography = DebugGeography.EEA
    parameters.debugSettings = debugSettings
    
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
  func startGoogleMobileAdsSDK() {
    guard canRequestAds, !isMobileAdsStartCalled else { return }
    isMobileAdsStartCalled = true
    
    // Configure test devices
    MobileAds.shared.requestConfiguration.testDeviceIdentifiers = ["b4465261536b1c775bc699401b84862c"]
    
    // Initialize the Google Mobile Ads SDK.
    MobileAds.shared.start()
    _ = InterstitialAdManager.shared
  }
}
