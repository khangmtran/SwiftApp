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
    var body: some View {
        List(questions){question in
            Section(header: Text("Câu hỏi \(question.id)")){
                VStack(alignment: .leading){
                    HStack{
                        Text(question.question)
                            .font(.headline)
                        Spacer()
                        Button(action: {
                            synthesizer.stopSpeaking(at: .immediate)
                            let utterance = AVSpeechUtterance(string: question.question)
                            utterance.voice = AVSpeechSynthesisVoice()
                            utterance.rate = 0.3
                            synthesizer.speak(utterance)
                        }){
                            Image(systemName: "speaker.wave.3")
                        }                    }
                    
                    Text(question.questionVie)
                        .font(.subheadline)
                    
                }
                VStack(alignment: .leading){
                    HStack{
                        Text("Trả lời: \(question.answer)")
                            .font(.headline)
                        Spacer()
                        Button(action: {
                            synthesizer.stopSpeaking(at: .immediate)
                            let utterance = AVSpeechUtterance(string: question.answer)
                            utterance.voice = AVSpeechSynthesisVoice()
                            utterance.rate = 0.3
                            synthesizer.speak(utterance)
                        }){
                            Image(systemName: "speaker.wave.3")
                        }
                    }
                    Text(question.answerVie)
                        .font(.subheadline)
                    
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
}
