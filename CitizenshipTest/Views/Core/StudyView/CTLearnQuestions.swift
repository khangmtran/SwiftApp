//
//  CTLearnQuestions.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 1/24/25.
//

import SwiftUI
import AVFoundation
import SwiftData
import FirebaseCrashlytics

struct CTLearnQuestions: View {
    @EnvironmentObject var userSetting: UserSetting
    @EnvironmentObject var selectedPart: SelectedPart
    @EnvironmentObject var questionList: QuestionList
    @EnvironmentObject var govCapManager: GovCapManager
    @State private var synthesizer = AVSpeechSynthesizer()
    @AppStorage("learnQuestionsIndex") private var qIndex = -1
    @AppStorage("learnQuestionsQCount") private var questionCount = 0
    @ObservedObject private var adManager = InterstitialAdManager.shared
    private let parts = ["Phần 1", "Phần 2", "Phần 3", "Phần 4", "Phần 5", "Phần 6", "Phần 7", "Phần 8"]
    
    let partToType = [
        "Phần 1": "LD",
        "Phần 2": "CA",
        "Phần 3": "US",
        "Phần 4": "WCCR",
        "Phần 5": "PVP",
        "Phần 6": "GSA",
        "Phần 7": "SND",
        "Phần 8": "CL"
    ]
    
    var filteredQuestion: [CTQuestion]{
        questionList.questions.filter{$0.type == partToType[selectedPart.partChosen]}
    }
    
    var body: some View{
        //Show Guide
        if qIndex == -1{
            VStack{//outer Vs
                CTGuide(qIndex: $qIndex)
                    .onAppear(){
                        Crashlytics.crashlytics().log("Study Guide in learn question appear")
                        adManager.showAd()
                    }
            }//end outerV
            .safeAreaInset(edge: .bottom) {
                NavButton(qIndex: $qIndex, qCount: $questionCount, totalQuestionsIndex: filteredQuestion.count - 1)
                    .padding()
            }
        }//end show guide
        else{
            
            ScrollView{
                //1. VStack contains keyword
                VStack{
                    Text(CTPartMessages().partMessages[selectedPart.partChosen] ?? "")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                }//.1
                .padding()
                .frame(maxWidth: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.blue, lineWidth: 1)
                        .fill(.blue.opacity(0.1))
                )
                .background(.white)
                .padding()
                
                
                //2. Vstack contains question
                if !filteredQuestion.isEmpty{
                    
                    VStack{
                        //question section
                        QuestionView(question: filteredQuestion[qIndex].question,
                                     vieQuestion: filteredQuestion[qIndex].questionVie,
                                     qId: filteredQuestion[qIndex].id,
                                     learn: filteredQuestion[qIndex].learn,
                                     synthesizer: synthesizer)
                        
                        //vstack of answer
                        AnswerView(
                            question: filteredQuestion[qIndex],
                            synthesizer: synthesizer
                        )
                        
                    }//.2
                }
            }
            .onAppear(){
                Crashlytics.crashlytics().log("User went to learnQuestions")
                adManager.showAd()
            }
            .onDisappear(){
                synthesizer.stopSpeaking(at: .immediate)
                RatingManager.shared.incrementAction()
            }
            .safeAreaInset(edge: .bottom) {
                NavButton(qIndex: $qIndex, qCount: $questionCount, totalQuestionsIndex: filteredQuestion.count - 1)
                    .padding()
            }
            
            .navigationBarTitleDisplayMode(.inline)
            //toolbar
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing){
                    Text("\(questionCount) / \(filteredQuestion.count)")
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Menu {
                        ForEach(parts.filter { $0 != selectedPart.partChosen }, id: \.self) { part in
                            Button(part) {
                                Crashlytics.crashlytics().log("User see part \(part) in learnQuestions")
                                selectedPart.partChosen = part
                                qIndex = -1
                                questionCount = 0
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedPart.partChosen)
                            Image(systemName: "chevron.down")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 10)
                        }
                    }
                }
            }//toolbar
            
        }
    }
}

#Preview {
    NavigationStack{
        CTLearnQuestions()
            .environmentObject(SelectedPart())
            .environmentObject(UserSetting())
            .environmentObject(QuestionList())
            .environmentObject(GovCapManager())
            .environmentObject(AudioManager())
    }
}

struct NavButton: View {
    @Binding var qIndex: Int
    @Binding var qCount: Int
    @ObservedObject private var adManager = InterstitialAdManager.shared
    let totalQuestionsIndex: Int
    
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
        Crashlytics.crashlytics().log("User see next question in learnQuestions")
        withAnimation{
            if qIndex < totalQuestionsIndex {
                qIndex += 1
                qCount += 1
            }
            else if qIndex == totalQuestionsIndex{
                qIndex = -1
                qCount = 0
            }
        }
    }
    
    private func prevQuestion(){
        Crashlytics.crashlytics().log("User see prev question in learnQuestions")
        withAnimation{
            if qIndex > -1{
                qIndex -= 1
                qCount -= 1
            }
            else if qIndex == -1{
                qIndex = totalQuestionsIndex
                qCount = totalQuestionsIndex + 1
            }
        }
    }
}

struct QuestionView: View {
    var question: String
    var vieQuestion: String
    var qId: Int
    var learn: String
    var synthesizer: AVSpeechSynthesizer
    @EnvironmentObject var audioManager: AudioManager
    @Environment(\.modelContext) private var context
    @Query private var markedQuestions: [MarkedQuestion]
    @ObservedObject private var adManager = InterstitialAdManager.shared
    var body: some View {
        VStack{
            VStack{
                Text("\(qId). \(question)")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                Text(vieQuestion)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                
                Text("Từ quan trọng:")
                    .font(.subheadline)
                    .underline()
                    .padding(.top)
                
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("\(learn)")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 1)
            }
            
            HStack{
                Spacer()
                
                Button(action: {
                    
                    if let existingMark = markedQuestions.first(where: {$0.id == qId}){
                        context.delete(existingMark)
                    }
                    else{
                        let newMark = MarkedQuestion(id: qId)
                        context.insert(newMark)
                    }
                }){
                    Image(systemName: markedQuestions.contains {$0.id == qId} ? "bookmark.fill" : "bookmark")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 20)
                }
                .padding(.trailing)
                
                Button(action: {
                    
                    synthesizer.stopSpeaking(at: .immediate)
                    let utterance = AVSpeechUtterance(string: question)
                    utterance.voice = AVSpeechSynthesisVoice(identifier: audioManager.voiceIdentifier)
                    utterance.rate = audioManager.speechRate
                    
                    synthesizer.speak(utterance)
                }){
                    Image(systemName: "speaker.wave.3")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 20)
                }
            }
            
        }//end question
        .padding()
        .background(.blue.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.blue, lineWidth: 1)
        )
        .background(.white)
        .padding(.horizontal)
    }
}

struct AnswerView: View {
    var question: CTQuestion
    var synthesizer: AVSpeechSynthesizer
    @EnvironmentObject var userSetting: UserSetting
    @EnvironmentObject var govCapManager: GovCapManager
    @EnvironmentObject var audioManager: AudioManager
    @State var showingZipPrompt = false
    @State private var showingAnswerSheet = false
    @ObservedObject private var adManager = InterstitialAdManager.shared
    @Environment(\.modelContext) private var context
    @Query private var answerPrefs: [UserAnswerPref]
    
    var body: some View {
        let pref = preferredAnswer(for: question)
        return VStack{
            if question.id == 20 || question.id == 23 || question.id == 43 || question.id == 44{
                Text("Trả Lời:")
                    .font(.subheadline)
                    .padding(.bottom, 1)
                ServiceQuestions(
                    questionId: question.id,
                    showingZipPrompt: $showingZipPrompt,
                    govAndCap: govCapManager.govAndCap
                )
            }
            
            //other questions except serviceQuestions
            else{
                VStack{
                    Text("Trả Lời:")
                        .font(.subheadline)
                    Text(pref.en)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding(.top, 1)
                    Text(pref.vie)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.bottom)
                }
            }
            
            HStack{
                if question.answers != nil {
                    Button(action: {
                        showingAnswerSheet = true
                    }) {
                        HStack {
                            Image(systemName: "text.badge.checkmark")
                            Text("Chọn Đáp Án Khác")
                        }
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                Spacer()
                Button(action: {
                    
                    synthesizer.stopSpeaking(at: .immediate)
                    
                    // Handle special questions (20, 23, 43, 44)
                    if question.id == 20 || question.id == 23 || question.id == 43 || question.id == 44 {
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
                    } else {
                        // Regular questions
                        let utterance = AVSpeechUtterance(string: pref.en)
                        utterance.voice = AVSpeechSynthesisVoice(identifier: audioManager.voiceIdentifier)
                        utterance.rate = audioManager.speechRate
                        synthesizer.speak(utterance)
                    }
                }){
                    Image(systemName: "speaker.wave.3")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 20)
                }
            }
        }
        .padding()
        .background(.blue.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.blue, lineWidth: 1)
        )
        .background(.white)
        .padding(.horizontal)
        
        .sheet(isPresented: $showingZipPrompt) {
            CTZipInput()
                .environmentObject(userSetting)
        }
        .sheet(isPresented: $showingAnswerSheet) {
            AnswerSelectionSheet(
                question: question,
                onSelect: { selected in
                    setPreferredAnswer(for: question, with: selected)
                    showingAnswerSheet = false
                }
            )
            .presentationDetents([.fraction(0.7)])
            .presentationDragIndicator(.visible)
        }
    }
    
    private func preferredAnswer(for question: CTQuestion) -> (en: String, vie: String) {
        if let pref = answerPrefs.first(where: { $0.questionId == question.id }) {
            return (pref.answerEn, pref.answerVie)
        }
        return (question.answer, question.answerVie)
    }
    
    private func setPreferredAnswer(for question: CTQuestion, with pair: AnswerPair) {
        if let existing = answerPrefs.first(where: { $0.questionId == question.id }) {
            existing.answerEn = pair.en
            existing.answerVie = pair.vie
        } else {
            let newPref = UserAnswerPref(questionId: question.id, answerEn: pair.en, answerVie: pair.vie)
            context.insert(newPref)
        }
    }
}
