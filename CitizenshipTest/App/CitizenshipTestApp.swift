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
           configureAudioSessionForSpeech()
       }
       
    private func configureAudioSessionForSpeech() {
            do {
                try AVAudioSession.sharedInstance().setCategory(
                    .playback,
                    mode: .spokenAudio,
                    options: [.duckOthers]
                )
                
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("Failed to configure audio session: \(error)")
            }
        }
    
    func getVoices() -> [AVSpeechSynthesisVoice] {
        let allVoices = AVSpeechSynthesisVoice.speechVoices()
        let selectedActors = ["Karen", "Arthur", "Nicky", "Aaron", "Samantha", "Tessa"]
        let filteredVoices = allVoices.filter { voice in
            return selectedActors.contains(voice.name)
        }
        if filteredVoices.isEmpty {
            return allVoices.filter { $0.language.contains("en-") }
        }
        return filteredVoices
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
