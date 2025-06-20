//
//  CTAllQuestions.swift
//  CitizenshipTest
//
//  Modified on 4/23/25.
//

import SwiftUI
import AVFoundation
import SwiftData
import GoogleMobileAds
import FirebaseCrashlytics

struct CTAllQuestions: View {
    @State private var synthesizer = AVSpeechSynthesizer()
    @State private var showingZipPrompt = false
    @EnvironmentObject var userSetting: UserSetting
    @EnvironmentObject var questionList: QuestionList
    @EnvironmentObject var govCapManager: GovCapManager
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var storeManager: StoreManager
    @Environment(\.modelContext) private var context
    @Query private var markedQuestions: [MarkedQuestion]
    @ObservedObject private var adManager = InterstitialAdManager.shared
    @StateObject private var networkMonitor = NetworkMonitor.shared
    
    var body: some View {
        VStack{
            List {
                ForEach(questionList.questions) { question in
                    Section(header: Text("Câu hỏi \(question.id)")
                        .font(.footnote)){
                            // Question stack
                            HStack {
                                // VStack contains ENG and VIE questions
                                VStack(alignment: .leading) {
                                    Text(question.question)
                                        .font(.headline)
                                    
                                    Text(question.questionVie)
                                        .font(.subheadline)
                                }
                                .padding(.trailing, 5)
                                
                                Spacer()
                                
                                // VStack contains voice and bookmark buttons
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
                            
                            // Answer stack
                            HStack {
                                if question.id == 20 || question.id == 23 || question.id == 43 || question.id == 44 {
                                    VStack {
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
                                    
                                    VStack(alignment: .leading) {
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
                                
                                // All questions except q20, q23, q43, q44
                                else {
                                    // Eng and Vie answer
                                    VStack(alignment: .leading) {
                                        Text("Trả lời: \(question.answer)")
                                            .font(.headline)
                                        Text(question.answerVie)
                                            .font(.subheadline)
                                    }
                                    .padding(.trailing, 5)
                                    
                                    Spacer()
                                    
                                    // Voice button
                                    VStack(alignment: .leading) {
                                        Button(action: {
                                            synthesizer.stopSpeaking(at: .immediate)
                                            let utterance = AVSpeechUtterance(string: question.answer)
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
           if !storeManager.isPurchased("KnT.CitizenshipTest.removeAds") && networkMonitor.isConnected{
               CTAdBannerView().frame(width: AdSizeBanner.size.width,
                                      height: AdSizeBanner.size.height)
           }
        }
        .scrollContentBackground(.hidden)
        .sheet(isPresented: $showingZipPrompt) {
            CTZipInput()
                .environmentObject(userSetting)
        }
        .navigationTitle("100 Câu Hỏi")
        .onAppear(){
            Crashlytics.crashlytics().log("User went to AllQuestions")
            adManager.showAd()
        }
        .onDisappear(){
            synthesizer.stopSpeaking(at: .immediate)
            RatingManager.shared.incrementAction()
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
