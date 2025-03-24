//
//  CTAllMarkedQuestion.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 3/19/25.
//

import SwiftUI
import AVFoundation
import SwiftData

struct CTAllMarkedQuestion: View {
    @State private var synthesizer = AVSpeechSynthesizer()
    @State private var showingZipPrompt = false
    @EnvironmentObject var deviceManager: DeviceManager
    @EnvironmentObject var userSetting: UserSetting
    @EnvironmentObject var questionList: QuestionList
    @EnvironmentObject var govCapManager: GovCapManager
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var context
    @Query private var markedQuestions: [MarkedQuestion]
    
    // Get only marked questions from the question list
    private var filteredQuestions: [CTQuestion] {
        return questionList.questions.filter { question in
            markedQuestions.contains { $0.id == question.id }
        }.sorted(by: { $0.id < $1.id }) // Sort by ID for consistency
    }
    
    var body: some View {
        VStack {
            if filteredQuestions.isEmpty {
                VStack {
                    Spacer()
                    Text("Chưa có câu hỏi đánh dấu")
                        .font(deviceManager.isTablet ? .title : .body)
                        .foregroundColor(.gray)
                    Text("Hãy đánh dấu những câu hỏi bạn muốn ôn tập")
                        .font(deviceManager.isTablet ? .title3 : .callout)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Image(systemName: "bookmark.slash")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                        .padding()
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Quay Lại")
                            .font(deviceManager.isTablet ? .title3 : .body)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.top)
                    
                    Spacer()
                }
            } else {
                List(filteredQuestions) { question in
                    Section(header: Text("Câu hỏi \(question.id)")
                        .font(deviceManager.isTablet ? .title3 : .footnote)) {
                            // Question stack
                            HStack {
                                // VStack contains ENG and VIE questions
                                VStack(alignment: .leading) {
                                    Text(question.question)
                                        .font(deviceManager.isTablet ? .largeTitle : .title3)
                                        .fontWeight(.bold)
                                    
                                    Text(question.questionVie)
                                        .font(deviceManager.isTablet ? .title : .body)
                                }
                                
                                Spacer()
                                
                                // VStack contains voice and bookmark buttons
                                VStack {
                                    // Voice button
                                    Button(action: {
                                        synthesizer.stopSpeaking(at: .immediate)
                                        let utterance = AVSpeechUtterance(string: question.question)
                                        utterance.voice = AVSpeechSynthesisVoice()
                                        utterance.rate = 0.3
                                        synthesizer.speak(utterance)
                                    }) {
                                        Image(systemName: "speaker.wave.3")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: deviceManager.isTablet ? 50 : 25)
                                    }
                                    .padding(.bottom)
                                    
                                    // Bookmark button
                                    Button(action: {
                                        if let existingMark = markedQuestions.first(where: {$0.id == question.id}) {
                                            context.delete(existingMark)
                                        } else {
                                            let newMark = MarkedQuestion(id: question.id)
                                            context.insert(newMark)
                                        }
                                    }) {
                                        Image(systemName: "bookmark.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: deviceManager.isTablet ? 50 : 25)
                                    }
                                }
                            }
                            .padding(.vertical)
                            
                            // Answer stack
                            HStack {
                                if question.id == 20 || question.id == 23 || question.id == 43 || question.id == 44 {
                                    VStack{
                                        Text("Trả lời:")
                                            .font(deviceManager.isTablet ? .largeTitle : .title3)
                                            .fontWeight(.bold)
                                            .padding(.bottom, 1)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        ServiceQuestions(
                                            questionId: question.id,
                                            showingZipPrompt: $showingZipPrompt,
                                            govAndCap: govCapManager.govAndCap
                                        )
                                    }
                                    Spacer()
                                    
                                    VStack(alignment: .leading){
                                        Button(action: {
                                            synthesizer.stopSpeaking(at: .immediate)
                                            
                                            // Get the appropriate text to speak based on the question ID
                                            var textToSpeak = ""
                                            
                                            if question.id == 20 {
                                                // Senator
                                                let senators = userSetting.legislators.filter { $0.type == "senator" }
                                                if !senators.isEmpty {
                                                    let senatorNames = senators.map { "\($0.firstName) \($0.lastName)" }.joined(separator: ", ")
                                                    textToSpeak = senatorNames
                                                }
                                            } else if question.id == 23 {
                                                // Representative
                                                let representatives = userSetting.legislators.filter { $0.type == "representative" }
                                                if let representative = representatives.first {
                                                    textToSpeak = "\(representative.firstName) \(representative.lastName)"
                                                }
                                            } else if question.id == 43 {
                                                // Governor
                                                let state = userSetting.state
                                                if let govCap = govCapManager.govAndCap.first(where: { $0.state == state }) {
                                                    textToSpeak = govCap.gov
                                                }
                                            } else if question.id == 44 {
                                                // Capital
                                                let state = userSetting.state
                                                if let govCap = govCapManager.govAndCap.first(where: { $0.state == state }) {
                                                    textToSpeak = govCap.capital
                                                }
                                            }
                                            
                                            let utterance = AVSpeechUtterance(string: textToSpeak)
                                            utterance.voice = AVSpeechSynthesisVoice()
                                            utterance.rate = 0.3
                                            synthesizer.speak(utterance)
                                        }) {
                                            Image(systemName: "speaker.wave.3")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: deviceManager.isTablet ? 50 : 25)
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                    }
                                } else {
                                    // Regular questions
                                    // Eng and Vie answer
                                    VStack(alignment: .leading) {
                                        Text("Trả lời: \(question.answer)")
                                            .font(deviceManager.isTablet ? .largeTitle : .title3)
                                            .fontWeight(.bold)
                                        
                                        Text(question.answerVie)
                                            .font(deviceManager.isTablet ? .title : .body)
                                    }
                                    
                                    Spacer()
                                    
                                    // Voice button for answer
                                    Button(action: {
                                        synthesizer.stopSpeaking(at: .immediate)
                                        let utterance = AVSpeechUtterance(string: question.answer)
                                        utterance.voice = AVSpeechSynthesisVoice()
                                        utterance.rate = 0.3
                                        synthesizer.speak(utterance)
                                    }) {
                                        Image(systemName: "speaker.wave.3")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: deviceManager.isTablet ? 50 : 25)
                                    }
                                }
                            }
                            .padding(.vertical)
                        }
                        .listRowBackground(Color.blue.opacity(0.1))
                }
                .scrollContentBackground(.hidden)
            }
        }
        .sheet(isPresented: $showingZipPrompt) {
            CTZipInput()
                .environmentObject(userSetting)
                .environmentObject(deviceManager)
        }
        .navigationTitle("Câu Hỏi Đánh Dấu")
    }
    

}

#Preview {
    CTAllMarkedQuestion()
        .environmentObject(DeviceManager())
        .environmentObject(UserSetting())
        .environmentObject(QuestionList())
        .environmentObject(GovCapManager())
}
