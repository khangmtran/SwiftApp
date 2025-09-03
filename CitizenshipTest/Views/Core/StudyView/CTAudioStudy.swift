//
//  CTAudioStudy.swift
//  CitizenshipTest
//
//  Created on 3/24/25.
//

import SwiftUI
import SwiftData
import AVFoundation
import GoogleMobileAds
import FirebaseCrashlytics

struct CTAudioStudy: View {
    @EnvironmentObject var questionList: QuestionList
    @EnvironmentObject var userSetting: UserSetting
    @EnvironmentObject var govCapManager: GovCapManager
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var storeManager: StoreManager
    @EnvironmentObject var adBannerManager: BannerAdManager
    @AppStorage("audioStudyQIndex") private var currentQuestionIndex = 0
    @AppStorage("audioStudyPlayMarkedOnly") private var playMarkedOnly = false
    @State private var isPlaying = false
    @State private var playAnswers = true
    @State private var questions: [CTQuestion] = []
    @State private var synthesizer = AVSpeechSynthesizer()
    @State private var isPlayingAnswer = false
    @State private var timer: Timer?
    @State private var showingZipPrompt = false
    @State private var delegate: SpeechDelegate?
    @State private var autoPlayQuestionCounter: Int = 0
    @State private var showingUpgradeAlert = false
    @State private var showingUpgradePrompt = false
    @State private var showingAnswerSheet: Bool = false
    @Environment(\.modelContext) private var context
    @Query private var markedQuestions: [MarkedQuestion]
    @Query private var answerPrefs: [UserAnswerPref]
    @ObservedObject private var adManager = InterstitialAdManager.shared
    @StateObject private var networkMonitor = NetworkMonitor.shared
    
    // Duration between speaking question and answer (seconds)
    private let pauseDuration: TimeInterval = 3 //3 in prod
    
    var body: some View {
        GeometryReader { geo in
            VStack{
                VStack{
                    // Controls section
                    Toggle("Nghe Đáp Án", isOn: $playAnswers)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                        .padding(.horizontal)
                    
                    // Marked Questions toggle
                    HStack {
                        HStack {
                            Text("Câu Hỏi Đánh Dấu").fixedSize(horizontal: true, vertical: false)
                            if !storeManager.isPurchased("KnT.CitizenshipTest.removeAds") {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.gray)
                                    .imageScale(.small)
                            }
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $playMarkedOnly)
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                            .disabled(!storeManager.isPurchased("KnT.CitizenshipTest.removeAds"))
                            .onChange(of: playMarkedOnly) {
                                if !storeManager.isPurchased("KnT.CitizenshipTest.removeAds") {
                                    playMarkedOnly = false //switch back the toggle
                                    showingUpgradeAlert = true
                                } else {
                                    updateQuestionsArray()
                                    stopAudio()
                                    currentQuestionIndex = 0
                                }
                            }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    .onTapGesture {
                        if !storeManager.isPurchased("KnT.CitizenshipTest.removeAds") {
                            showingUpgradeAlert = true
                        }
                    }
                    
                    // Progress indicator
                    if !questions.isEmpty {
                        VStack {
                            Text("\(currentQuestionIndex + 1) / \(questions.count)")
                            
                            ProgressView(value: Double(currentQuestionIndex + 1), total: Double(questions.count))
                                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        }
                        .padding(10)
                    }
                    
                    // Show message if no marked questions
                    if playMarkedOnly && questions.isEmpty {
                        Spacer()
                        VStack(spacing: 15) {
                            Image(systemName: "bookmark.slash")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 75, height: 75)
                                .foregroundColor(.gray)
                            
                            Text("Bạn chưa đánh dấu câu hỏi nào")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            Text("Hãy đánh dấu câu hỏi để nghe tại đây")
                                .font(.callout)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        Spacer()
                    } else if !questions.isEmpty {
                        ScrollView {
                            // Question/Answer display
                            VStack {
                                VStack {
                                    HStack {
                                        Text("Câu hỏi \(questions[currentQuestionIndex].id)")
                                            .font(.headline)
                                            .foregroundColor(.blue)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        // Add bookmark button
                                        Button(action: {
                                            if let existingMark = markedQuestions.first(where: {$0.id == questions[currentQuestionIndex].id}) {
                                                context.delete(existingMark)
                                            } else {
                                                let newMark = MarkedQuestion(id: questions[currentQuestionIndex].id)
                                                context.insert(newMark)
                                            }
                                        }) {
                                            Image(systemName: markedQuestions.contains(where: {$0.id == questions[currentQuestionIndex].id}) ? "bookmark.fill" : "bookmark")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 20)
                                        }
                                    }
                                    
                                    Text(questions[currentQuestionIndex].question)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .font(.headline)
                                        .multilineTextAlignment(.leading)
                                        .padding(.vertical, 5)
                                    
                                    Text(questions[currentQuestionIndex].questionVie)
                                        .font(.subheadline)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .multilineTextAlignment(.leading)
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color.blue.opacity(0.1)))
                                
                                if playAnswers {
                                    VStack {
                                        HStack{
                                            Text("Đáp án")
                                                .font(.headline)
                                                .foregroundColor(.blue)
                                                //.frame(maxWidth: .infinity, alignment: .leading)
                                            Spacer()
                                            if questions[currentQuestionIndex].answers != nil {
                                                Button(action: {
                                                    showingAnswerSheet = true
                                                }) {
                                                    HStack {
                                                        Image(systemName: "text.badge.checkmark")
                                                        Text("Đáp Án Khác")
                                                    }
                                                }
                                                .buttonStyle(BorderlessButtonStyle())
                                            }
                                        }
                                        if [20, 23, 43, 44].contains(questions[currentQuestionIndex].id) {
                                            ServiceQuestions(
                                                questionId: questions[currentQuestionIndex].id,
                                                showingZipPrompt: $showingZipPrompt,
                                                govAndCap: govCapManager.govAndCap
                                            )
                                            .padding(.vertical, 5)
                                        } else {
                                            // Regular answer display
                                            let pref = preferredAnswer(for: questions[currentQuestionIndex])
                                            Text(pref.en)
                                                .font(.headline)
                                                .fixedSize(horizontal: false, vertical: true)
                                                .multilineTextAlignment(.leading)
                                                .padding(.vertical, 5)
                                            
                                            Text(pref.vie)
                                                .font(.subheadline)
                                                .multilineTextAlignment(.leading)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                    }
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.blue.opacity(0.1)))
                                }
                            }
                            .padding()
                        }
                    }
                }
                .padding()
                    // Playback controls
                    VStack {
                        // Standard playback controls
                        if !questions.isEmpty {
                            HStack(spacing: 20) {
                                Button(action: previousTenQuestions) {
                                    Image(systemName: "backward.end.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 25)
                                }
                                
                                Button(action: previousQuestion) {
                                    Image(systemName: "backward.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 25)
                                }
                                
                                Button(action: togglePlayback) {
                                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 45)
                                }
                                
                                Button(action: nextQuestion) {
                                    Image(systemName: "forward.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 25)
                                }
                                
                                Button(action: nextTenQuestions) {
                                    Image(systemName: "forward.end.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 25)
                                }
                            }
                        }
                        Spacer()
                    }.frame(height: UIDevice.current.userInterfaceIdiom == .pad ? 350 : 100)
                if !storeManager.isPurchased("KnT.CitizenshipTest.removeAds") && networkMonitor.isConnected && adBannerManager.isAdReady == true{
                   CTAdBannerView().frame(width: AdSizeBanner.size.width,
                                          height: AdSizeBanner.size.height)
               }
            }
        }
        .onAppear(){
            Crashlytics.crashlytics().log("User went to AudioStudy")
            adBannerManager.configureAdIfAllowed(storeManager: storeManager)
            adManager.showAd()
            updateQuestionsArray()
        }
        .sheet(isPresented: $showingZipPrompt) {
            CTZipInput()
                .environmentObject(userSetting)
        }
        .sheet(isPresented: $showingAnswerSheet) {
            AnswerSelectionSheet(
                question: questions[currentQuestionIndex],
                onSelect: { selected in
                    setPreferredAnswer(for: questions[currentQuestionIndex], with: selected)
                    showingAnswerSheet = false
                }
            )
            .presentationDetents([.fraction(0.7)])
            .presentationDragIndicator(.visible)
        }
        .alert("Tính năng dành riêng cho phiên bản nâng cấp. Bạn có muốn nâng cấp?", isPresented: $showingUpgradeAlert) {
            Button("Hủy", role: .cancel) {}
            Button("Nâng Cấp") {
                showingUpgradePrompt = true
            }
        }
        .sheet(isPresented: $showingUpgradePrompt) {
            CTRemoveAdsView()
                .environmentObject(storeManager)
        }
        .onDisappear {
            stopAudio()
            RatingManager.shared.incrementAction()
        }
        .onChange(of: markedQuestions.count) { oldValue, newValue in
            // Update questions array when marked questions change
            if playMarkedOnly {
                updateQuestionsArray()
                // If current index is out of bounds, reset to 0
                if currentQuestionIndex >= questions.count && !questions.isEmpty {
                    currentQuestionIndex = 0
                }
            }
        }
    }
    
    // Update questions array based on current mode
    private func updateQuestionsArray() {
        if playMarkedOnly && storeManager.isPurchased("KnT.CitizenshipTest.removeAds") {
                // Filter marked questions directly here
                questions = questionList.questions.filter { question in
                    markedQuestions.contains { $0.id == question.id }
                }.sorted(by: { $0.id < $1.id })
            } else {
                questions = questionList.questions
            }
        
        // Ensure currentQuestionIndex is within bounds
        if currentQuestionIndex >= questions.count {
            currentQuestionIndex = 0
        }
    }
    
    // Handle audio playback
    private func togglePlayback() {
        guard !questions.isEmpty else { return }
        
        if isPlaying {
            stopAudio()
        } else {
            playCurrentQuestion()
            Crashlytics.crashlytics().log("User plays audio in AudioStudy")
        }
    }
    
    private func playCurrentQuestion() {
        guard !questions.isEmpty else { return }
        
        UIApplication.shared.isIdleTimerDisabled = true
        isPlaying = true
        isPlayingAnswer = false
        
        synthesizer.stopSpeaking(at: .immediate)
        timer?.invalidate()
        
        let question = questions[currentQuestionIndex]
        let utterance = AVSpeechUtterance(string: question.question)
        utterance.voice = AVSpeechSynthesisVoice(identifier: audioManager.voiceIdentifier)
        utterance.rate = audioManager.speechRate
        
        delegate = SpeechDelegate(
            onFinished: {
                // Only continue to answer if playAnswers is true
                if playAnswers {
                    // Wait a moment before playing the answer
                    self.timer = Timer.scheduledTimer(withTimeInterval: self.pauseDuration, repeats: false) { _ in
                        self.playCurrentAnswer()
                    }
                } else {
                    self.timer = Timer.scheduledTimer(withTimeInterval: self.pauseDuration, repeats: false) { _ in
                        self.finishAudioSequence()
                    }
                }
            }
        )
        
        // Set the delegate
        synthesizer.delegate = delegate
        
        synthesizer.speak(utterance)
    }
    
    private func playCurrentAnswer() {
        guard !questions.isEmpty else { return }
        
        isPlayingAnswer = true
        
        let question = questions[currentQuestionIndex]
        let questionId = question.id
        var answerText = preferredAnswer(for: question).en

        // Handle specific questions that require user ZIP code
        if questionId == 20 || questionId == 23 || questionId == 43 || questionId == 44 {
            if !userSetting.zipCode.isEmpty {
                // Get the appropriate answer based on the question ID
                if questionId == 20 {
                    // Senator
                    let senators = userSetting.legislators.filter { $0.type == "senator" }
                    if !senators.isEmpty {
                        answerText = senators.map { "\($0.firstName) \($0.lastName)" }.joined(separator: ", ")
                    }
                } else if questionId == 23 {
                    // Representative
                    let representatives = userSetting.legislators.filter { $0.type == "representative" }
                    if !representatives.isEmpty {
                        answerText = representatives.map { "\($0.firstName) \($0.lastName)" }.joined(separator: ", ")
                    }
                } else if questionId == 43 {
                    // Governor
                    let state = userSetting.state
                    if let govCap = govCapManager.govAndCap.first(where: { $0.state == state }) {
                        answerText = govCap.gov
                    }
                } else if questionId == 44 {
                    // Capital
                    let state = userSetting.state
                    if let govCap = govCapManager.govAndCap.first(where: { $0.state == state }) {
                        answerText = govCap.capital
                    }
                }
            }
        }
        
        let utterance = AVSpeechUtterance(string: answerText)
        utterance.voice = AVSpeechSynthesisVoice(identifier: audioManager.voiceIdentifier)
        utterance.rate = audioManager.speechRate
        
        // Create and store a strong reference to the answer delegate
        delegate = SpeechDelegate(
            onFinished: {
                self.timer = Timer.scheduledTimer(withTimeInterval: self.pauseDuration, repeats: false) { _ in
                    self.finishAudioSequence()
                }
            }
        )
        
        // Set the delegate
        synthesizer.delegate = delegate
        
        synthesizer.speak(utterance)
    }
    
    private func finishAudioSequence() {
        guard !questions.isEmpty else { return }
        
        isPlaying = false
        isPlayingAnswer = false
        
        // Move to next question if not at the end
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            
            // Automatically start playing the next question
            playCurrentQuestion()
        }
    }
    
    private func stopAudio() {
        isPlaying = false
        isPlayingAnswer = false
        timer?.invalidate()
        synthesizer.stopSpeaking(at: .immediate)
        // Clear the delegate to prevent potential memory leaks
        synthesizer.delegate = nil
        delegate = nil
        UIApplication.shared.isIdleTimerDisabled = false
        Crashlytics.crashlytics().log("User stop listening in AudioStudy")
    }
    
    private func nextQuestion() {
        guard !questions.isEmpty else { return }
        
        if currentQuestionIndex < questions.count - 1 {
            stopAudio()
            currentQuestionIndex += 1
        }
        else{
            stopAudio()
            currentQuestionIndex = 0
        }
    }
    
    private func previousQuestion() {
        guard !questions.isEmpty else { return }
        
        if currentQuestionIndex > 0 {
            stopAudio()
            currentQuestionIndex -= 1
        }
        else{
            stopAudio()
            currentQuestionIndex = questions.count - 1
        }
    }
    
    private func nextTenQuestions() {
        guard !questions.isEmpty else { return }
        
        stopAudio()
        
        let newIndex = currentQuestionIndex + 10
        if newIndex < questions.count {
            currentQuestionIndex = newIndex
        } else {
            // If exceeding bounds, reset to beginning
            currentQuestionIndex = 0
        }
        
    }
    
    private func previousTenQuestions() {
        guard !questions.isEmpty else { return }
        
        stopAudio()
        
        let newIndex = currentQuestionIndex - 10
        if newIndex >= 0 {
            currentQuestionIndex = newIndex
        } else {
            // If going below 0, go to the last question
            currentQuestionIndex = questions.count - 1
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

// Speech synthesis delegate to handle callbacks
class SpeechDelegate: NSObject, AVSpeechSynthesizerDelegate {
    let onFinished: () -> Void
    
    init(onFinished: @escaping () -> Void) {
        self.onFinished = onFinished
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        onFinished()
    }
}
