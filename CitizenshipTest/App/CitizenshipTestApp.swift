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
    @Published var questions: [CTQuestion] {
        didSet {
            if let encoded = try? JSONEncoder().encode(questions) {
                UserDefaults.standard.set(encoded, forKey: "cachedQuestions")
            }
        }
    }
    
    init() {
        //increase currentDataVersion every change to the questionsJSON file
        let currentDataVersion = 1 // Last update: 03/01/25
        let savedDataVersion = UserDefaults.standard.integer(forKey: "dataVersion")
        
        if savedDataVersion < currentDataVersion {
            self.questions = CTDataLoader().loadQuestions()
            
            if let encoded = try? JSONEncoder().encode(questions) {
                UserDefaults.standard.set(encoded, forKey: "cachedQuestions")
            }
            
            UserDefaults.standard.set(currentDataVersion, forKey: "dataVersion")
        }
        
        //load from past data
        else {
            if let savedQuestionsData = UserDefaults.standard.data(forKey: "cachedQuestions"),
               let decodedQuestions = try? JSONDecoder().decode([CTQuestion].self, from: savedQuestionsData) {
                self.questions = decodedQuestions
            } else {
                self.questions = CTDataLoader().loadQuestions()
            }
        }
        
    }
    
}

class GovCapManager: ObservableObject {
    @Published var govAndCap: [CTGovAndCapital] {
        didSet {
            if let encoded = try? JSONEncoder().encode(govAndCap) {
                UserDefaults.standard.set(encoded, forKey: "cachedgovAndCap")
            }
        }
    }
    
    init() {
        //increase currentDataVersion every change to the govAndCapJSON file
        let currentDataVersion = 1 // Last update: 03/01/25
        let savedDataVersion = UserDefaults.standard.integer(forKey: "govCapDataVersion")
        
        if savedDataVersion < currentDataVersion {
            self.govAndCap = CTDataLoader().loadGovAndCapital()
            
            if let encoded = try? JSONEncoder().encode(govAndCap) {
                UserDefaults.standard.set(encoded, forKey: "cachedgovAndCap")
            }
            UserDefaults.standard.set(currentDataVersion, forKey: "govCapDataVersion")
        }
        //load from past data
        else {
            if let savedGovCapData = UserDefaults.standard.data(forKey: "cachedgovAndCap"),
               let decodedGovCap = try? JSONDecoder().decode([CTGovAndCapital].self, from: savedGovCapData) {
                self.govAndCap = decodedGovCap
            } else {
                self.govAndCap = CTDataLoader().loadGovAndCapital()
            }
        }
    }
    
}

@main
struct CitizenshipTestApp: App{
    @StateObject private var selectedPart = SelectedPart()
    @StateObject private var deviceManager = DeviceManager()
    @StateObject private var userSetting = UserSetting()
    @StateObject private var starredQuestions = StarredQuestions()
    @StateObject private var questionList = QuestionList()
    @StateObject private var govCapManager = GovCapManager()
    var body: some Scene {
        WindowGroup {
            CTInitialScreen()
                .environmentObject(selectedPart)
                .environmentObject(deviceManager)
                .environmentObject(userSetting)
                .environmentObject(starredQuestions)
                .environmentObject(questionList)
                .environmentObject(govCapManager)
        }
    }
}
