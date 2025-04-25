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

@main
struct CitizenshipTestApp: App{
    @StateObject private var selectedPart = SelectedPart()
    @StateObject private var userSetting = UserSetting()
    @StateObject private var questionList = QuestionList()
    @StateObject private var govCapManager = GovCapManager()
    @StateObject private var wrongAnswer = WrongAnswer()
    @StateObject private var audioManager = AudioManager()

    init() {
        MobileAds.shared.start(completionHandler: nil)
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
                .modelContainer(for: [MarkedQuestion.self, CTTestProgress.self])
        }
    }
}
