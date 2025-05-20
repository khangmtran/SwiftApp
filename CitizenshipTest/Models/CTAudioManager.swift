//
//  CTAudioManager.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 4/24/25.
//

import SwiftUI
import SwiftData
import AVFoundation

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
#if DEBUG
                print("Failed to configure audio session: \(error)")
#endif
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
