//
//  CTUserSetting.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 4/24/25.
//

import SwiftUI
import SwiftData
import AVFoundation

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
    
    @Published var zipSearchCount: Int {
        didSet {
            UserDefaults.standard.set(zipSearchCount, forKey: "zipSearchCount")
        }
    }
    
    @Published var lastZipSearchDate: Date {
        didSet {
            UserDefaults.standard.set(lastZipSearchDate, forKey: "lastZipSearchDate")
        }
    }
    
    init() {
        self.zipSearchCount = UserDefaults.standard.integer(forKey: "zipSearchCount")
        self.lastZipSearchDate = UserDefaults.standard.object(forKey: "lastZipSearchDate") as? Date ?? Date.distantPast
        self.zipCode = UserDefaults.standard.string(forKey: "userZip") ?? ""
        self.state = UserDefaults.standard.string(forKey: "userState") ?? ""
        if let savedLegislatorsData = UserDefaults.standard.data(forKey: "userLegislators"),
           let decodedLegislators = try? JSONDecoder().decode([Legislator].self, from: savedLegislatorsData) {
            self.legislators = decodedLegislators
        } else {
            self.legislators = []
        }
    }
    
    func canSearchZip() -> Bool {
        let calendar = Calendar.current
        if !calendar.isDateInToday(lastZipSearchDate) {
            zipSearchCount = 0
            lastZipSearchDate = Date()
        }
        return zipSearchCount < 5
    }
    
    func incrementZipSearchCount() {
        if Calendar.current.isDateInToday(lastZipSearchDate) {
            zipSearchCount += 1
        } else {
            zipSearchCount = 1
            lastZipSearchDate = Date()
        }
    }
}

class SelectedPart: ObservableObject {
    @Published var partChosen: String {
        didSet {
            UserDefaults.standard.set(partChosen, forKey: "selectedLearningPart")
        }
    }
    
    init() {
        self.partChosen = UserDefaults.standard.string(forKey: "selectedLearningPart") ?? "Phần 1"
    }
}

@Model
class MarkedQuestion{
    @Attribute(.unique) var id: Int
    
    init(id: Int) {
        self.id = id
    }
}

class QuestionList: ObservableObject {
    @Published var questions: [CTQuestion]
    
    init() {
        self.questions = CTDataLoader().loadQuestions()
    }
    
}


class GovCapManager: ObservableObject {
    @Published var govAndCap: [CTGovAndCapital]
    
    init(){
        self.govAndCap = CTDataLoader().loadGovAndCapital()
    }
    
}

class WrongAnswer: ObservableObject{
    @Published var wrongAns: [CTWrongAnswer]
    
    init(){
        self.wrongAns = CTDataLoader().loadWrongAnswers()
    }
}


