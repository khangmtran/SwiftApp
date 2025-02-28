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
    @State private var govAndCap: [CTGovAndCapital] = []
    @State private var synthesizer = AVSpeechSynthesizer()
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
                EmptyView()
                    .id("topId")
                Section(header: Text("Câu hỏi \(question.id)")
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
                            if question.id == 20 || question.id == 23 || question.id == 43 || question.id == 44{
                                
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
                                        Button(action: {
                                            showingZipPrompt = true
                                        }){
                                            Text("Nhap ZIP Code de tim Senators cua ban")
                                                .font(deviceManager.isTablet ? .largeTitle : .title3)
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
                                        Button(action: {
                                            showingZipPrompt = true
                                        }){
                                            Text("Nhap ZIP Code de tim Representative cua ban")
                                                .font(deviceManager.isTablet ? .largeTitle : .title3)
                                        }
                                    }
                                }
                                
                                //q43
                                else if question.id == 43{
                                    VStack(alignment: .leading){
                                        Text("Trả lời:")
                                            .font(deviceManager.isTablet ? .largeTitle : .title3)
                                            .fontWeight(.bold)
                                        let state = userSetting.state
                                        ForEach(govAndCap) { gnc in
                                            if gnc.state == state{
                                                Text("\(gnc.gov)")
                                                    .font(deviceManager.isTablet ? .largeTitle : .title3)
                                                    .fontWeight(.bold)
                                            }
                                        }
                                        Button(action: {
                                            showingZipPrompt = true
                                        }){
                                            Text("Nhap ZIP Code de tim Governor cua ban")
                                                .font(deviceManager.isTablet ? .largeTitle : .title3)
                                        }
                                    }
                                }
                                
                                else if question.id == 44{
                                    VStack(alignment: .leading){
                                        Text("Trả lời:")
                                            .font(deviceManager.isTablet ? .largeTitle : .title3)
                                            .fontWeight(.bold)
                                        let state = userSetting.state
                                        ForEach(govAndCap) { gnc in
                                            if gnc.state == state{
                                                Text("\(gnc.capital)")
                                                    .font(deviceManager.isTablet ? .largeTitle : .title3)
                                                    .fontWeight(.bold)
                                            }
                                        }
                                        Button(action: {
                                            showingZipPrompt = true
                                        }){
                                            Text("Nhap ZIP Code de tim Capital cua ban")
                                                .font(deviceManager.isTablet ? .largeTitle : .title3)
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
                govAndCap = CTDataLoader().loadGovAndCapital()
            }
            .safeAreaInset(edge: .bottom) {
                NavButtonAllQ(page: $page)
                    .padding()
                    .background(Color.white)
            }
            .navigationTitle("100 Câu Hỏi")
            .onChange(of: page) { oldValue, newValue in
                withAnimation{
                    scrollProxy.scrollTo("topId", anchor: .top)
                }
            }
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
            
            Spacer()
            
            Button(action: nextQuestion){
                Text("Tiep Theo")
                    .font(deviceManager.isTablet ? .largeTitle : .title3)
            }
            .padding()
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
