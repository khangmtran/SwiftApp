//
//  SwiftUIView.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 3/13/25.
//

import SwiftUI
import SwiftData
import AVFoundation

struct CTResultView: View {
    let score: Int
    let questions: [CTQuestion]
    @State private var synthesizer = AVSpeechSynthesizer()
    @Environment(\.modelContext) private var context
    @Query private var markedQuestions: [MarkedQuestion]
    @EnvironmentObject var deviceManager: DeviceManager
    
    var body: some View {
        GeometryReader{geo in
            ZStack{
                Circle()
                    .fill(.blue.opacity(0.7))
                    .shadow(radius: 5)
                    .frame(width: geo.size.width/2)
                Text("\(score) / 10")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
            }
            .position(x: geo.size.width/2, y: geo.size.height/5)
            
//            List(questions){ question in
//                HStack{
//                    VStack{
//                        Text(question.question)
//                        Text(question.answer)
//                    }
//                    VStack{
//                        Button(action: {
//                            synthesizer.stopSpeaking(at: .immediate)
//                            let utterance = AVSpeechUtterance(string: question.question)
//                            utterance.voice = AVSpeechSynthesisVoice()
//                            utterance.rate = 0.3
//                            synthesizer.speak(utterance)
//                        }){
//                            Image(systemName: "speaker.wave.3")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(height: deviceManager.isTablet ? 50 : 25)
//                        }
//                        .padding(.bottom)
//                        
//                        // Bookmark button
//                        Button(action: {
//                            if let existingMark = markedQuestions.first(where: {$0.id == question.id}){
//                                context.delete(existingMark)
//                            }
//                            else{
//                                let newMark = MarkedQuestion(id: question.id)
//                                context.insert(newMark)
//                            }
//                        }){
//                            Image(systemName: markedQuestions.contains {$0.id == question.id} ? "bookmark.fill" : "bookmark")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(height: deviceManager.isTablet ? 50 : 25)
//                        }
//                    }
//                }
//            }
            
        }
    }
}

//#Preview {
//    SwiftUIView(score: 10)
//}
