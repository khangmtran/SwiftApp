//
//  CTWritingTest.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 6/23/25.
//

import SwiftUI
import AVFoundation
import GoogleMobileAds
import FirebaseCrashlytics

struct CTWritingTest: View {
    @State private var inputText: String = ""
    @State private var synthesizer = AVSpeechSynthesizer()
    @State private var userGotRightAnswer = false
    @State private var hasCheckedAnswer = false
    @EnvironmentObject var writingQuestionList: WritingQuestions
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var userSetting: UserSetting
    @EnvironmentObject var storeManager: StoreManager
    @EnvironmentObject var adBannerManager: BannerAdManager
    @AppStorage("writingTestIndex") private var currentIndex = 0
    @ObservedObject private var adManager = InterstitialAdManager.shared
    @StateObject private var networkMonitor = NetworkMonitor.shared
    
    private var questionList: [CTWritingQuestion] {
        writingQuestionList.writingQuestions
    }
    
    private var textEditorBackgroundColor: Color {
        guard hasCheckedAnswer else { return Color(.systemGray6) }
        return userGotRightAnswer ? Color.green.opacity(0.2) : Color.red.opacity(0.2)
    }
    
    private var textEditorBorderColor: Color {
        guard hasCheckedAnswer else { return Color(.systemGray4) }
        return userGotRightAnswer ? Color.green : Color.red
    }
    
    var body: some View {
        if !questionList.isEmpty{
            VStack{
                ScrollView{
                    Text("Câu \(currentIndex + 1) / \(questionList.count)")
                    ProgressView(value: Double(currentIndex + 1), total: Double(questionList.count))
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .padding(.horizontal).padding(.vertical, 8)
                    Text("Nghe và viết lại những từ bạn nghe được")
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal).padding(.vertical, 8)
                    Button(action: {
                        playCurrentQuestion()
                    }){
                        Image(systemName: "speaker.wave.3.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 30)
                            .foregroundColor(.blue)
                            .padding()
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.blue.opacity(0.1))
                            .stroke(Color.blue, lineWidth: 2)
                    )
                    .padding(.horizontal).padding(.vertical,8)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(textEditorBackgroundColor)
                            .stroke(textEditorBorderColor, lineWidth: 2)
                            .frame(height: 80)
                        
                        TextEditor(text: $inputText)
                            .multilineTextAlignment(.center)
                            .disableAutocorrection(true)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .frame(maxHeight: 80)
                            .padding(.horizontal, 50)
                            .padding(.vertical, 20)
                        
                        if inputText.isEmpty {
                            Text("Nhập từ nghe được")
                                .foregroundColor(Color(.placeholderText))
                                .allowsHitTesting(false)
                        }
                        
                        if !inputText.isEmpty{
                            Button(action:{
                                inputText = ""
                            }){
                                Image(systemName: "xmark")
                                    .foregroundStyle(.gray)
                                    .padding(10)
                                    .contentShape(Circle())
                            }.frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    
                    HStack(spacing: 30) {
                        Button(action: previousQuestion) {
                            Image(systemName: "lessthan.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 40)
                        }
                        
                        Button(action: checkAnswer) {
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 60)
                        }.disabled(inputText.isEmpty)
                        
                        Button(action: nextQuestion) {
                            Image(systemName: "greaterthan.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 40)
                        }
                    }.padding(.vertical, 8)
                    if hasCheckedAnswer && userGotRightAnswer == false {
                        Text(questionList[currentIndex].question)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .frame(height: 80)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.green.opacity(0.2))
                                    .stroke(Color.green, lineWidth: 2)
                            )
                            .padding(.horizontal)
                    }
                }
                VStack{
                    if !storeManager.isPurchased("KnT.CitizenshipTest.removeAds") && networkMonitor.isConnected && adBannerManager.isAdReady == true{
                        CTAdBannerView().frame(width: AdSizeBanner.size.width,
                                               height: AdSizeBanner.size.height)
                    }
                }
            }
            .navigationTitle("Thi Viết")
            .onAppear(){
                Crashlytics.crashlytics().log("User went to AllMarkedQuestions")
                adManager.showAd()
            }
            .onDisappear(){
                synthesizer.stopSpeaking(at: .immediate)
                RatingManager.shared.incrementAction()
            }
        }
        else{
            ProgressView()
        }
    }
    
    private func previousQuestion(){
        guard !questionList.isEmpty else { return }
        
        if currentIndex > 0 {
            synthesizer.stopSpeaking(at: .immediate)
            currentIndex -= 1
        }
        else{
            synthesizer.stopSpeaking(at: .immediate)
            currentIndex = questionList.count - 1
        }
        hasCheckedAnswer = false
        inputText = ""
        hideKeyboard()
        adManager.showAd()
    }
    
    private func checkAnswer(){
        let checkString = inputText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        hasCheckedAnswer = true
        if checkString == questionList[currentIndex].question.lowercased().trimmingCharacters(in: .whitespacesAndNewlines){
            userGotRightAnswer = true
        }else{
            userGotRightAnswer = false
        }
        hideKeyboard()
        adManager.showAd()
    }
    
    private func nextQuestion(){
        guard !questionList.isEmpty else { return }
        
        if currentIndex >= questionList.count - 1 {
            synthesizer.stopSpeaking(at: .immediate)
            currentIndex = 0
        }
        else{
            synthesizer.stopSpeaking(at: .immediate)
            currentIndex += 1
        }
        hasCheckedAnswer = false
        inputText = ""
        hideKeyboard()
        adManager.showAd()
    }
    
    private func playCurrentQuestion() {
        Crashlytics.crashlytics().log("User played audio in WritingTest")
        guard !questionList.isEmpty else { return }
        synthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: questionList[currentIndex].question)
        utterance.voice = AVSpeechSynthesisVoice(identifier: audioManager.voiceIdentifier)
        utterance.rate = audioManager.speechRate
        synthesizer.speak(utterance)
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


