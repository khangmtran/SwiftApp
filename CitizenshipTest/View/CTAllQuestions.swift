//
//  CTAllQuestions.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 1/24/25.
//

import SwiftUI
import AVFoundation

struct CTAllQuestions: View {
    @State private var questions: [CTQuestion] = []
    @State private var synthesizer = AVSpeechSynthesizer()
    @State private var isLoadingLegislators = false
    @State private var showingZipPrompt = false
    @EnvironmentObject var deviceManager: DeviceManager
    @EnvironmentObject var userSetting: UserSetting
    @State private var page = 0
    
    private var paginatedQuestions: [CTQuestion]{
        let startIndex = page * 10
        let endIndex = startIndex + 9
        if startIndex >= questions.count{
            return []
        }
        return Array(questions[startIndex...endIndex])
    }
    
    var body: some View {
        ScrollViewReader{ scrollProxy in
            List(paginatedQuestions){question in
                Section(header: Text("Câu hỏi \(question.id)")
                    .id(question.id)
                    .font(deviceManager.isTablet ? .title3 : .footnote)){
                        //question stack
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
                        
                        //answer stack
                        VStack(alignment: .leading){
                            if question.id == 20 || question.id == 23{
                                
                                //q20
                                if question.id == 20{
                                    VStack(alignment: .leading){
                                        Text("Trả lời: Chon 1 trong nhung Senator duoi day:")
                                            .font(deviceManager.isTablet ? .largeTitle : .title3)
                                            .fontWeight(.bold)
                                        let senators = userSetting.legislators.filter {$0.type == "senator"}
                                        ForEach(senators) { sen in
                                            Text("\(sen.firstName) \(sen.lastName)")
                                                .font(deviceManager.isTablet ? .largeTitle : .title3)
                                                .fontWeight(.bold)
                                        }
                                        Button("Nhap ZIP Code de tim \(question.id == 23 ? "Representative" : "Senators") cua ban") {
                                            showingZipPrompt = true
                                        }
                                    }
                                }
                                
                                //q23
                                else if question.id == 23{
                                    VStack(alignment: .leading){
                                        Text("Trả lời:")
                                            .font(deviceManager.isTablet ? .largeTitle : .title3)
                                            .fontWeight(.bold)
                                        let represenatatives = userSetting.legislators.filter {$0.type == "representative"}
                                        ForEach(represenatatives) { rep in
                                            Text("\(rep.firstName) \(rep.lastName)")
                                                .font(deviceManager.isTablet ? .largeTitle : .title3)
                                                .fontWeight(.bold)
                                        }
                                        Button("Nhap ZIP Code de tim \(question.id == 23 ? "Representative" : "Senators") cua ban") {
                                            showingZipPrompt = true
                                        }
                                    }
                                }
                            }
                            
                            // all questions except q20 and 23
                            else{
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
            }
            
            .sheet(isPresented: $showingZipPrompt) {
                CTZipInput()
                    .environmentObject(userSetting)
                    .environmentObject(deviceManager)
            }
            .onAppear {
                questions = CTDataLoader().loadQuestions()
            }
            .safeAreaInset(edge: .bottom) {
                NavButtonAllQ(page: $page, scrollProxy: scrollProxy)
                    .padding()
                    .background(Color.white)
            }
            .navigationTitle("100 Câu Hỏi")
        }
    }
    
}
#Preview {
    CTAllQuestions()
        .environmentObject(DeviceManager())
        .environmentObject(UserSetting())
}

struct NavButtonAllQ: View {
    @EnvironmentObject var deviceManager: DeviceManager
    @Binding var page: Int
    let scrollProxy: ScrollViewProxy
    private let totalPages: Int = 9
    
    var body: some View {
        HStack(){
            Button(action: prevQuestion){
                Text("Tro Ve")
                    .font(deviceManager.isTablet ? .largeTitle : .title3)
            }
            .padding()
            .foregroundStyle(.white)
            .background(.blue)
            .cornerRadius(10)
            .disabled(page == 0)
            
            Spacer()
            
            Button(action: nextQuestion){
                Text("Tiep Theo")
                    .font(deviceManager.isTablet ? .largeTitle : .title3)
            }
            .padding()
            .foregroundStyle(.white)
            .background(.blue)
            .cornerRadius(10)
            .disabled(page == totalPages)
            
        }//hstack contains prv and nxt arrows
        
    }
    
    private func nextQuestion(){
        withAnimation{
            if page < totalPages {
                page += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    let newFirstQuestionId = (page * 10) + 1
                    scrollProxy.scrollTo(newFirstQuestionId, anchor: .top)
                }
            }
        }
    }
    
    private func prevQuestion(){
        withAnimation{
            if page > 0{
                page -= 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    let newFirstQuestionId = (page * 10) + 1
                    scrollProxy.scrollTo(newFirstQuestionId, anchor: .top)
                }
            }
        }
    }
}
