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
    @EnvironmentObject var userSetting: UserSetting
    @EnvironmentObject var questionList: QuestionList
    @EnvironmentObject var govCapManager: GovCapManager
    @EnvironmentObject var audioManager: AudioManager
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
                    Spacer()
                    Image(systemName: "bookmark.slash")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                    
                    Text("Bạn chưa đánh dấu câu hỏi nào")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text("Hãy đánh dấu câu hỏi để ôn tập tại đây")
                        .font(.callout)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Quay Lại")
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.top)
                    Spacer()
                    CTAdBannerView()
                }
                .padding()
            } else {
                VStack{
                    List {
                        Section {
                            Button(action: {
                                showingConfirmationDialog = true
                            }) {
                                HStack {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                    Text("Xóa Tất Cả Câu Hỏi Đánh Dấu")
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
                                .font(.footnote)) {
                                    // Question stack
                                    HStack {
                                        // VStack contains ENG and VIE questions
                                        VStack(alignment: .leading) {
                                            Text(question.question)
                                                .font(.headline)
                                            Text(question.questionVie)
                                                .font(.subheadline)
                                        }
                                        
                                        Spacer()
                                        
                                        // VStack contains voice and bookmark buttons
                                        VStack {
                                            // Voice button
                                            Button(action: {
                                                synthesizer.stopSpeaking(at: .immediate)
                                                let utterance = AVSpeechUtterance(string: question.question)
                                                utterance.voice = AVSpeechSynthesisVoice(identifier: audioManager.voiceIdentifier)
                                                utterance.rate = audioManager.speechRate
                                                synthesizer.speak(utterance)
                                            }) {
                                                Image(systemName: "speaker.wave.3")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(height: 20)
                                            }
                                            .buttonStyle(BorderlessButtonStyle())
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
                                                    .frame(height: 20)
                                            }
                                            .buttonStyle(BorderlessButtonStyle())
                                        }
                                    }
                                    .padding(.vertical)
                                    
                                    // Answer stack
                                    HStack {
                                        if question.id == 20 || question.id == 23 || question.id == 43 || question.id == 44 {
                                            VStack{
                                                Text("Trả lời:")
                                                    .font(.headline)
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
                                                        if !representatives.isEmpty {
                                                            let repNames = representatives.map { "\($0.firstName) \($0.lastName)" }.joined(separator: ", ")
                                                            textToSpeak = repNames
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
                                                    utterance.voice = AVSpeechSynthesisVoice(identifier: audioManager.voiceIdentifier)
                                                    utterance.rate = audioManager.speechRate
                                                    synthesizer.speak(utterance)
                                                }) {
                                                    Image(systemName: "speaker.wave.3")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(height: 20)
                                                }
                                                .buttonStyle(BorderlessButtonStyle())
                                            }
                                        } else {
                                            // Regular questions
                                            // Eng and Vie answer
                                            VStack(alignment: .leading) {
                                                Text("Trả lời: \(question.answer)")
                                                    .font(.headline)
                                                Text(question.answerVie)
                                                    .font(.subheadline)
                                            }
                                            
                                            Spacer()
                                            
                                            // Voice button for answer
                                            Button(action: {
                                                synthesizer.stopSpeaking(at: .immediate)
                                                let utterance = AVSpeechUtterance(string: question.answer)
                                                utterance.voice = AVSpeechSynthesisVoice(identifier: audioManager.voiceIdentifier)
                                                utterance.rate = audioManager.speechRate
                                                synthesizer.speak(utterance)
                                            }) {
                                                Image(systemName: "speaker.wave.3")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(height: 20)
                                            }
                                            .buttonStyle(BorderlessButtonStyle())
                                        }
                                    }
                                    .padding(.vertical)
                                }
                                .listRowBackground(Color.blue.opacity(0.1))
                        }
                        Section {
                            Text("Một số câu hỏi bao gồm nhiều đáp án khả thi đã được chọn lọc ra những đáp án dễ học. Nếu bạn muốn tham khảo thêm các đáp án khác, vui lòng truy cập uscis.gov")
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                    }
                    CTAdBannerView()
                }
                .scrollContentBackground(.hidden)
            }
        }
        .onDisappear(){
            synthesizer.stopSpeaking(at: .immediate)
        }
        .sheet(isPresented: $showingZipPrompt) {
            CTZipInput()
                .environmentObject(userSetting)
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
        .environmentObject(UserSetting())
        .environmentObject(QuestionList())
        .environmentObject(GovCapManager())
        .environmentObject(AudioManager())
}
