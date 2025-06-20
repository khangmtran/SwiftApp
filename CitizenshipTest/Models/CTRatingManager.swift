//
//  CTRatingManager.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 6/19/25.
//

import SwiftUI
import StoreKit

class RatingManager: ObservableObject{
    static let shared = RatingManager()
    @Published var actionCount: Int{
        didSet{
            UserDefaults.standard.set(actionCount, forKey: "actionCount")
            showRatingPrompt()
        }
    }
    
    @Published var lastPromptDate: Date?{
        didSet{
            if let date = lastPromptDate {
                UserDefaults.standard.set(date, forKey: "lastPromptDate")
            }
        }
    }
    
    private init(){
        self.actionCount = UserDefaults.standard.integer(forKey: "actionCount")
        self.lastPromptDate = UserDefaults.standard.object(forKey: "lastPromptDate") as? Date
    }
    
    func incrementAction(){
        actionCount += 1
    }
    
    func showRatingPrompt(){
        guard actionCount >= 10 else { return }
        
        if let lastDate = lastPromptDate {
            let daysSince = Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
            if daysSince < 20 {
                return
            }
        }
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
            lastPromptDate = Date()
            actionCount = 0
        }
    }
}
