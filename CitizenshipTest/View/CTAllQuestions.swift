//
//  CTAllQuestions.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 1/24/25.
//

import SwiftUI
import AVFoundation

struct CTAllQuestions: View {
    @State private var questions:[CTQuestion] = []
    @State private var synthesizer = AVSpeechSynthesizer()
    @EnvironmentObject var deviceManager: DeviceManager
    var body: some View {
        List(questions){question in
            Section(header: Text("Câu hỏi \(question.id)")
                .font(deviceManager.isTablet ? .title3 : .footnote)){
                VStack(alignment: .leading){
                    HStack{
                        Text(question.question)
                            .font(deviceManager.isTablet ? .largeTitle : .title3)
                            .fontWeight(.bold)
                        Spacer()
                        Button(action: {
                            synthesizer.stopSpeaking(at: .immediate)
                            let utterance = AVSpeechUtterance(string: question.question)
                            utterance.voice = AVSpeechSynthesisVoice()
                            utterance.rate = 0.3
                            synthesizer.speak(utterance)
                        }){
                            Image(systemName: "speaker.wave.3")
                                .resizable()
                                .scaledToFit()
                                .frame(height: deviceManager.isTablet ? 40 : 20)
                        }
                    }
                    
                    Text(question.questionVie)
                        .font(deviceManager.isTablet ? .title : .body)
                    
                }
                VStack(alignment: .leading){
                    HStack{
                        Text("Trả lời: \(question.answer)")
                            .font(deviceManager.isTablet ? .largeTitle : .title3)
                            .fontWeight(.bold)
                        Spacer()
                        Button(action: {
                            synthesizer.stopSpeaking(at: .immediate)
                            let utterance = AVSpeechUtterance(string: question.answer)
                            utterance.voice = AVSpeechSynthesisVoice()
                            utterance.rate = 0.3
                            synthesizer.speak(utterance)
                        }){
                            Image(systemName: "speaker.wave.3")
                                .resizable()
                                .scaledToFit()
                                .frame(height: deviceManager.isTablet ? 40 : 20)
                        }
                    }
                    Text(question.answerVie)
                        .font(deviceManager.isTablet ? .title : .body)
                    
                }
            }
        }
        .onAppear{
            questions = CTDataLoader().loadQuestions()
        }
        .navigationTitle("100 Câu Hỏi")
    }
}

#Preview {
    CTAllQuestions()
        .environmentObject(DeviceManager())
}
