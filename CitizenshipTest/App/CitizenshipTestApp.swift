//
//  CitizenshipTestApp.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 1/18/25.
//

import SwiftUI
import SwiftData
import AVFoundation
import GoogleMobileAds
import StoreKit
import FirebaseCore
import FirebaseCrashlytics
import UserMessagingPlatform

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
}

@main
struct CitizenshipTestApp: App{
    @StateObject private var selectedPart = SelectedPart()
    @StateObject private var userSetting = UserSetting()
    @StateObject private var questionList = QuestionList()
    @StateObject private var govCapManager = GovCapManager()
    @StateObject private var wrongAnswer = WrongAnswer()
    @StateObject private var audioManager = AudioManager()
    @StateObject private var storeManager = StoreManager()
    @StateObject private var networkMonitor = NetworkMonitor.shared
    @StateObject private var writingQuestionList = WritingQuestions()
    @StateObject private var bannerAdManger: BannerAdManager
    @StateObject private var updateChecker = AppUpdateChecker()
    @StateObject private var consentManager = GoogleMobileAdsConsentManager.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var hasInitialized = false
    
    init() {
        let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? "unknown_device"
        Crashlytics.crashlytics().setUserID(deviceID)
        
        let storeManager = StoreManager()
        let networkMonitor = NetworkMonitor.shared
        
        _storeManager = StateObject(wrappedValue: storeManager)
        _networkMonitor = StateObject(wrappedValue: networkMonitor)
        _bannerAdManger = StateObject(wrappedValue: BannerAdManager(storeManager: storeManager, networkMonitor: networkMonitor))
    }
    
    var body: some Scene {
        WindowGroup {
            CTTab()
                .environmentObject(selectedPart)
                .environmentObject(userSetting)
                .environmentObject(questionList)
                .environmentObject(govCapManager)
                .environmentObject(wrongAnswer)
                .environmentObject(audioManager)
                .environmentObject(storeManager)
                .environmentObject(networkMonitor)
                .environmentObject(writingQuestionList)
                .environmentObject(bannerAdManger)
                .environmentObject(consentManager)
                .modelContainer(for: [MarkedQuestion.self, CTTestProgress.self, UserAnswerPref.self])
                .onAppear {
                    Task {
                        guard !hasInitialized else { return }
                        hasInitialized = true
#if DEBUG
                        print("check app update")
#endif
                        await updateChecker.checkForUpdate()
#if DEBUG
                        print("done")
#endif
                        
                        if !updateChecker.showUpdateAlert{
#if DEBUG
                        print("ask consent")
#endif
                            consentManager.gatherConsent { [consentManager] error in
                                if let error = error {
#if DEBUG
                                    print("Consent gathering failed: \(error.localizedDescription)")
#endif
                                }
                                
                                // Start Google Mobile Ads SDK if consent allows
#if DEBUG
                                print("done")
#endif
                                consentManager.startGoogleMobileAdsSDK(storeManager: storeManager)
                            }
                        }
                    }
                }
                .alert("Phiên bản mới đã có mặt trên App Store. Vui lòng cập nhật ứng dụng để có thông tin mới nhất.",
                       isPresented: $updateChecker.showUpdateAlert) {
                    Button("Cập nhật") {
                        updateChecker.openAppStore()
                    }
                }
        }
    }
}
