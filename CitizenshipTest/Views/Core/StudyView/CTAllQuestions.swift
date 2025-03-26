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
    @EnvironmentObject var deviceManager: DeviceManager
    @EnvironmentObject var userSetting: UserSetting
    @EnvironmentObject var questionList: QuestionList
    @EnvironmentObject var govCapManager: GovCapManager
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
            List(paginatedQuestions){question in
                Section(header: Text("Câu hỏi \(question.id)")
                    .id(question.id)
                    .font(deviceManager.isTablet ? .body : .footnote)){
                        //question stack
                        HStack{
                            //VStack contains ENG and VIE questions
                            VStack(alignment: .leading) {
                                Text(question.question)
                                    .font(deviceManager.isTablet ? .title3 : .body)
                                    .fontWeight(.bold)
                                
                                Text(question.questionVie)
                                    .font(deviceManager.isTablet ? .title3 : .body)
                            }
                            
                            Spacer()
                            
                            //VStack contains voice and bookmark buttons
                            VStack() {
                                // Voice button
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
                                        .frame(height: deviceManager.isTablet ? 40 : 20)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                        .padding(.vertical)
                        
                        //answer stack
                        HStack{
                            if question.id == 20 || question.id == 23 || question.id == 43 || question.id == 44{
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
                                            .frame(height: deviceManager.isTablet ? 50 : 25)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                            }
                            
                            // all questions except q20 and 23
                            else{
                                //Eng and Vie answer
                                VStack(alignment: .leading){
                                    Text("Trả lời: \(question.answer)")
                                        .font(deviceManager.isTablet ? .title3 : .body)
                                        .fontWeight(.bold)
                                    
                                    Text(question.answerVie)
                                        .font(deviceManager.isTablet ? .title3 : .body)
                                }
                                
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
                                            .frame(height: deviceManager.isTablet ? 40 : 20)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                    .listRowBackground(Color.blue.opacity(0.1))
            }
            .scrollContentBackground(.hidden)
            .sheet(isPresented: $showingZipPrompt) {
                CTZipInput()
                    .environmentObject(userSetting)
                    .environmentObject(deviceManager)
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
        }
    }
    
}
#Preview {
    CTAllQuestions()
        .environmentObject(DeviceManager())
        .environmentObject(UserSetting())
        .environmentObject(QuestionList())
        .environmentObject(GovCapManager())
}

struct NavButtonAllQ: View {
    @EnvironmentObject var deviceManager: DeviceManager
    @Binding var page: Int
    private let totalPages: Int = 9
    
    var body: some View {
        HStack(){
            Button(action: prevQuestion){
                Text("Trở Về")
                    .font(deviceManager.isTablet ? .title3 : .body)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .foregroundStyle(.white)
            .background(.blue)
            .cornerRadius(10)
            
            Spacer()
            
            Button(action: nextQuestion){
                Text("Tiếp Theo")
                    .font(deviceManager.isTablet ? .title3 : .body)
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
