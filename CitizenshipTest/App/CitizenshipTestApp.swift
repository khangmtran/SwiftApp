//
//  CitizenshipTestApp.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 1/18/25.
//

import SwiftUI

class UserSetting: ObservableObject {
    @Published var state: String{
        didSet{
            UserDefaults.standard.set(state, forKey: "userState")
        }
    }
    
    @Published var zipCode: String {
        didSet {
            UserDefaults.standard.set(zipCode, forKey: "userZip")
        }
    }
    
    @Published var legislators: [Legislator] {
        didSet {
            if let encoded = try? JSONEncoder().encode(legislators) {
                UserDefaults.standard.set(encoded, forKey: "userLegislators")
            }
        }
    }
    
    init() {
        self.zipCode = UserDefaults.standard.string(forKey: "userZip") ?? ""
        self.state = UserDefaults.standard.string(forKey: "userState") ?? ""
        if let savedLegislatorsData = UserDefaults.standard.data(forKey: "userLegislators"),
           let decodedLegislators = try? JSONDecoder().decode([Legislator].self, from: savedLegislatorsData) {
            self.legislators = decodedLegislators
        } else {
            self.legislators = []
        }
    }
}

class SelectedPart: ObservableObject{
    @Published var partChosen: String = "Phần 1"
}

class DeviceManager: ObservableObject{
    @Published var isTablet: Bool = UIDevice.current.userInterfaceIdiom == .pad
}

class StarredQuestions: ObservableObject{
    @Published var starredQuestions: [CTQuestion] = []
}

class QuestionList: ObservableObject{
    @Published var questionList: [CTQuestion] = CTDataLoader().loadQuestions()
}
@main
struct CitizenshipTestApp: App{
    @StateObject private var selectedPart = SelectedPart()
    @StateObject private var deviceManager = DeviceManager()
    @StateObject private var userSetting = UserSetting()
    @StateObject private var starredQuestions = StarredQuestions()
    @StateObject private var questionList = QuestionList()
    var body: some Scene {
        WindowGroup {
            CTInitialScreen()
                .environmentObject(selectedPart)
                .environmentObject(deviceManager)
                .environmentObject(userSetting)
                .environmentObject(starredQuestions)
        }
    }
}
