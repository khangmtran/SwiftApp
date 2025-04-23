//
//  CTAllQuestions.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 1/24/25.
//

import SwiftUI
import AVFoundation
import SwiftData

struct CTAllQuestions: View {
    @State private var synthesizer = AVSpeechSynthesizer()
    @State private var showingZipPrompt = false
    @State private var page = 0
    @EnvironmentObject var userSetting: UserSetting
    @EnvironmentObject var questionList: QuestionList
    @EnvironmentObject var govCapManager: GovCapManager
    @EnvironmentObject var audioManager: AudioManager
    @Environment(\.modelContext) private var context
    @Query private var markedQuestions: [MarkedQuestion]
    
    private var paginatedQuestions: [CTQuestion]{
        let startIndex = page * 10
        let endIndex = min(startIndex + 9, questionList.questions.count - 1)
        if startIndex >= questionList.questions.count{
            return []
        }
        return Array(questionList.questions[startIndex...endIndex])
    }
    
    var body: some View {
        ScrollViewReader{ scrollProxy in
            List{
                ForEach(paginatedQuestions) { question in
                    Section(header: Text("Câu hỏi \(question.id)")
                        .id(question.id)
                        .font(.footnote)){
                            //question stack
                            HStack{
                                //VStack contains ENG and VIE questions
                                VStack(alignment: .leading) {
                                    Text(question.question)
                                        .font(.headline)
                                    
                                    Text(question.questionVie)
                                        .font(.subheadline)
                                }
                                .padding(.trailing, 5)
                                
                                Spacer()
                                
                                //VStack contains voice and bookmark buttons
                                VStack() {
                                    // Voice button
                                    Button(action: {
                                        synthesizer.stopSpeaking(at: .immediate)
                                        let utterance = AVSpeechUtterance(string: question.question)
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
                                    
                                    // Bookmark button
                                    Button(action: {
                                        if let existingMark = markedQuestions.first(where: {$0.id == question.id}){
                                            context.delete(existingMark)
                                        }
                                        else{
                                            let newMark = MarkedQuestion(id: question.id)
                                            context.insert(newMark)
                                        }
                                    }){
                                        Image(systemName: markedQuestions.contains {$0.id == question.id} ? "bookmark.fill" : "bookmark")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 20)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                            }
                            .padding(.vertical, 10)
                            
                            //answer stack
                            HStack{
                                if question.id == 20 || question.id == 23 || question.id == 43 || question.id == 44{
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
                                }
                                
                                // all questions except q20 and 23
                                else{
                                    //Eng and Vie answer
                                    VStack(alignment: .leading){
                                        Text("Trả lời: \(question.answer)")
                                            .font(.headline)
                                        Text(question.answerVie)
                                            .font(.subheadline)
                                    }
                                    .padding(.trailing, 5)
                                    
                                    Spacer()
                                    
                                    //voice button
                                    VStack(alignment: .leading){
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
                                                .frame(height: 20)
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                    }
                                }
                            }
                            .padding(.vertical, 10)
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
            .scrollContentBackground(.hidden)
            .sheet(isPresented: $showingZipPrompt) {
                CTZipInput()
                    .environmentObject(userSetting)
            }
            .safeAreaInset(edge: .bottom) {
                NavButtonAllQ(page: $page)
                    .padding()
                    .background(Color.white)
            }
            .navigationTitle("100 Câu Hỏi")
            .onChange(of: page) { oldValue, newValue in
                withAnimation{
                    let firstQId = paginatedQuestions.first?.id
                    scrollProxy.scrollTo(firstQId, anchor: .center)
                }
            }
            .onDisappear(){
                synthesizer.stopSpeaking(at: .immediate)
            }
        }
        
    }
    
}
#Preview {
    CTAllQuestions()
        .environmentObject(UserSetting())
        .environmentObject(QuestionList())
        .environmentObject(GovCapManager())
        .environmentObject(AudioManager())
}

struct NavButtonAllQ: View {
    @Binding var page: Int
    private let totalPages: Int = 9
    
    var body: some View {
        HStack(){
            Button(action: prevQuestion){
                Text("Trở Về")
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .foregroundStyle(.white)
            .background(.blue)
            .cornerRadius(10)
            
            Spacer()
            
            Button(action: nextQuestion){
                Text("Tiếp Theo")
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .foregroundStyle(.white)
            .background(.blue)
            .cornerRadius(10)
            
        }//hstack contains prv and nxt arrows
        
    }
    
    private func nextQuestion(){
        if page < totalPages {
            page += 1
        }
        else if page == totalPages{
            page = 0
        }
    }
    
    private func prevQuestion(){
        if page > 0{
            page -= 1
        }
        else if page == 0{
            page = totalPages
        }
    }
}
