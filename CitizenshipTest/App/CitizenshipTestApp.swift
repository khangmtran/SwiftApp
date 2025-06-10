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

    init() {
        MobileAds.shared.start(completionHandler: nil)
        _ = InterstitialAdManager.shared
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
                .modelContainer(for: [MarkedQuestion.self, CTTestProgress.self])
                .onAppear {
                    InterstitialAdManager.shared.setStoreManager(storeManager)
                    
                    Task {
                        await storeManager.updatePurchasedProducts()
                    }
                }
        }
    }
}
