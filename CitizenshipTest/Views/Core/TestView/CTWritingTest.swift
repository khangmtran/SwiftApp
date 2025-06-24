//
//  CTWritingTest.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 6/23/25.
//

import SwiftUI
import AVFoundation

struct CTWritingTest: View {
    @State private var inputText: String
    @State private var synthesizer = AVSpeechSynthesizer()
    @EnvironmentObject var writingQuestionList: WritingQuestions
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var userSetting: UserSetting
    @AppStorage("writingTestIndex") private var currentIndex = 0
    
    private var questionList: [CTWritingQuestion] {
        writingQuestionList.writingQuestions
    }
    
    var body: some View {
        ScrollView{
            Button(action: {
                synthesizer.stopSpeaking(at: .immediate)
                let utterance = AVSpeechUtterance(string: questionList[currentIndex].question)
                utterance.voice = AVSpeechSynthesisVoice(identifier: audioManager.voiceIdentifier)
                utterance.rate = audioManager.speechRate
                synthesizer.speak(utterance)
            }){
                Image(systemName: "speaker.wave.3")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 20)
            }
            .buttonStyle(BorderlessButtonStyle())
            .padding(.bottom)
            
            TextField("Nhập những từ đã nghe", text: $inputText)
                .keyboardType(.default)
        }
    }
    
}


