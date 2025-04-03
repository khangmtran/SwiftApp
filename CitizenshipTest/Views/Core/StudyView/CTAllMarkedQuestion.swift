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
    @State private var showingConfirmationDialog = false
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
        }.sorted(by: { $0.id < $1.id })
    }
    
    var body: some View {
        VStack {
            if filteredQuestions.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "bookmark.slash")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                    
                    Text("Bạn chưa đánh dấu câu hỏi nào")
                        .font(deviceManager.isTablet ? .title : .headline)
                        .foregroundColor(.gray)
                    
                    Text("Hãy đánh dấu câu hỏi để ôn tập tại đây")
                        .font(deviceManager.isTablet ? .body : .callout)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
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
                }
                .padding()
            } else {
                List {
                    Section {
                        Button(action: {
                            showingConfirmationDialog = true
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                Text("Xóa Tất Cả Câu Hỏi Đánh Dấu")
                                    .font(deviceManager.isTablet ? .title3 : .body)
                                    .foregroundColor(.red)
                            }
                        }
                        .confirmationDialog(
                            "Xóa tất cả câu hỏi đánh dấu?",
                            isPresented: $showingConfirmationDialog,
                            titleVisibility: .visible
                        ) {
                            Button("Xóa Tất Cả", role: .destructive) {
                                removeAllMarkedQuestions()
                            }
                            Button("Hủy", role: .cancel) {}
                        } message: {
                            Text("Bạn có chắc chắn muốn xóa tất cả câu hỏi đánh dấu không?")
                        }
                    }
                    .listRowBackground(Color.white)
                    
                    // Questions
                    ForEach(filteredQuestions) { question in
                        Section(header: Text("Câu hỏi \(question.id)")
                            .font(deviceManager.isTablet ? .title3 : .footnote)) {
                                // Question stack
                                HStack {
                                    // VStack contains ENG and VIE questions
                                    VStack(alignment: .leading) {
                                        Text(question.question)
                                            .font(deviceManager.isTablet ? .title3 : .body)
                                            .fontWeight(.bold)
                                        
                                        Text(question.questionVie)
                                            .font(deviceManager.isTablet ? .title3 : .body)
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
                                                .frame(height: deviceManager.isTablet ? 40 : 20)
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
                                                .frame(height: deviceManager.isTablet ? 40 : 20)
                                        }
                                    }
                                }
                                .padding(.vertical)
                                
                                // Answer stack
                                HStack {
                                    if question.id == 20 || question.id == 23 || question.id == 43 || question.id == 44 {
                                        VStack{
                                            Text("Trả lời:")
                                                .font(deviceManager.isTablet ? .title3 : .body)
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
                                                    .frame(height: deviceManager.isTablet ? 40 : 20)
                                            }
                                            .buttonStyle(BorderlessButtonStyle())
                                        }
                                    } else {
                                        // Regular questions
                                        // Eng and Vie answer
                                        VStack(alignment: .leading) {
                                            Text("Trả lời: \(question.answer)")
                                                .font(deviceManager.isTablet ? .title3 : .body)
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
                                                .frame(height: deviceManager.isTablet ? 40 : 20)
                                        }
                                    }
                                }
                                .padding(.vertical)
                            }
                            .listRowBackground(Color.blue.opacity(0.1))
                    }
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
    
    // Function to remove all marked questions
    private func removeAllMarkedQuestions() {
        for question in markedQuestions {
            context.delete(question)
        }
    }
}

#Preview {
    CTAllMarkedQuestion()
        .environmentObject(DeviceManager())
        .environmentObject(UserSetting())
        .environmentObject(QuestionList())
        .environmentObject(GovCapManager())
}
