//
//  CitizenshipTestApp.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 1/18/25.
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

class DeviceManager: ObservableObject{
    @Published var isTablet: Bool = UIDevice.current.userInterfaceIdiom == .pad
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

class AudioManager: ObservableObject{
    @Published var speechRate: Float {
            didSet {
                UserDefaults.standard.set(speechRate, forKey: "speechRate")
            }
        }
    
    @Published var voiceActor: String {
           didSet {
               UserDefaults.standard.set(voiceActor, forKey: "voiceActor")
           }
       }
    
    @Published var voiceIdentifier: String {
           didSet {
               UserDefaults.standard.set(voiceIdentifier, forKey: "voiceIdentifier")
           }
       }
       
       init() {
           let savedRate = UserDefaults.standard.float(forKey: "speechRate")
           self.speechRate = savedRate == 0 ? 0.4 : savedRate
           self.voiceActor = UserDefaults.standard.string(forKey: "voiceActor") ?? "Samantha"
           self.voiceIdentifier = UserDefaults.standard.string(forKey: "voiceIdentifier") ?? "com.apple.voice.compact.en-US.Samantha"
       }
       
    func getVoices() -> [AVSpeechSynthesisVoice] {
        return AVSpeechSynthesisVoice.speechVoices().filter { voice in
            return voice.language.contains("en-US")
        }
    }
}

@main
struct CitizenshipTestApp: App{
    @StateObject private var selectedPart = SelectedPart()
    @StateObject private var deviceManager = DeviceManager()
    @StateObject private var userSetting = UserSetting()
    @StateObject private var questionList = QuestionList()
    @StateObject private var govCapManager = GovCapManager()
    @StateObject private var wrongAnswer = WrongAnswer()
    @StateObject private var audioManager = AudioManager()

    var body: some Scene {
        WindowGroup {
            CTTab()
                .environmentObject(selectedPart)
                .environmentObject(deviceManager)
                .environmentObject(userSetting)
                .environmentObject(questionList)
                .environmentObject(govCapManager)
                .environmentObject(wrongAnswer)
                .environmentObject(audioManager)
                .modelContainer(for: [MarkedQuestion.self, CTTestProgress.self])
        }
    }
}
