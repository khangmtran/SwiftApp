//
//  CTAudioStudy.swift
//  CitizenshipTest
//
//  Created on 3/24/25.
//

import SwiftUI
import SwiftData
import AVFoundation

struct CTAudioStudy: View {
    @EnvironmentObject var questionList: QuestionList
    @EnvironmentObject var userSetting: UserSetting
    @EnvironmentObject var govCapManager: GovCapManager
    @EnvironmentObject var audioManager: AudioManager
    @AppStorage("audioStudyQIndex") private var currentQuestionIndex = 0
    @State private var isPlaying = false
    @State private var playAnswers = true
    @State private var synthesizer = AVSpeechSynthesizer()
    @State private var isPlayingAnswer = false
    @State private var timer: Timer?
    @State private var showingZipPrompt = false
    @State private var delegate: SpeechDelegate?
    @Environment(\.modelContext) private var context
    @Query private var markedQuestions: [MarkedQuestion]    
    
    // Duration between speaking question and answer (seconds)
    private let pauseDuration: TimeInterval = 3
    
    var body: some View {
        GeometryReader { geo in
            VStack{
                ScrollView {
                    // Controls section
                    Toggle("Nghe Đáp Án", isOn: $playAnswers)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                        .padding()
                    
                    // Progress indicator
                    VStack {
                        Text("\(currentQuestionIndex + 1) / \(questionList.questions.count)")
                        
                        ProgressView(value: Double(currentQuestionIndex + 1), total: Double(questionList.questions.count))
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                            .padding(.horizontal)
                    }
                    .padding()
                    
                    // Question/Answer display
                    VStack {
                        VStack {
                            HStack {
                                Text("Câu hỏi \(questionList.questions[currentQuestionIndex].id)")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                // Add bookmark button
                                Button(action: {
                                    if let existingMark = markedQuestions.first(where: {$0.id == questionList.questions[currentQuestionIndex].id}) {
                                        context.delete(existingMark)
                                    } else {
                                        let newMark = MarkedQuestion(id: questionList.questions[currentQuestionIndex].id)
                                        context.insert(newMark)
                                    }
                                }) {
                                    Image(systemName: markedQuestions.contains(where: {$0.id == questionList.questions[currentQuestionIndex].id}) ? "bookmark.fill" : "bookmark")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 20)
                                }
                            }
                            
                            Text(questionList.questions[currentQuestionIndex].question)
                                .fixedSize(horizontal: false, vertical: true)
                                .font(.headline)
                                .multilineTextAlignment(.leading)
                                .padding(.vertical, 5)
                            
                            Text(questionList.questions[currentQuestionIndex].questionVie)
                                .font(.subheadline)
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.leading)
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.blue.opacity(0.1)))
                        
                        if playAnswers {
                            VStack {
                                Text("Đáp án")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                if [20, 23, 43, 44].contains(questionList.questions[currentQuestionIndex].id) {
                                    ServiceQuestions(
                                        questionId: questionList.questions[currentQuestionIndex].id,
                                        showingZipPrompt: $showingZipPrompt,
                                        govAndCap: govCapManager.govAndCap
                                    )
                                    .padding(.vertical, 5)
                                } else {
                                    // Regular answer display
                                    Text(questionList.questions[currentQuestionIndex].answer)
                                        .font(.headline)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .multilineTextAlignment(.leading)
                                        .padding(.vertical, 5)
                                    
                                    
                                    Text(questionList.questions[currentQuestionIndex].answerVie)
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
                // Playback controls
                VStack {
                    // Standard playback controls
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
                .padding(.vertical)
            }
            .padding()
        }
        .sheet(isPresented: $showingZipPrompt) {
            CTZipInput()
                .environmentObject(userSetting)
        }
        .onDisappear {
            stopAudio()
        }
    }
    
    // Handle audio playback
    private func togglePlayback() {
        if isPlaying {
            stopAudio()
        } else {
            playCurrentQuestion()
        }
    }
    
    private func playCurrentQuestion() {
        UIApplication.shared.isIdleTimerDisabled = true
        isPlaying = true
        isPlayingAnswer = false
        
        synthesizer.stopSpeaking(at: .immediate)
        timer?.invalidate()
        
        let question = questionList.questions[currentQuestionIndex]
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
        isPlayingAnswer = true
        
        let question = questionList.questions[currentQuestionIndex]
        let questionId = question.id
        var answerText = question.answer
        
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
        isPlaying = false
        isPlayingAnswer = false
        
        // Move to next question if not at the end
        if currentQuestionIndex < questionList.questions.count - 1 {
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
    }
    
    private func nextQuestion() {
        if currentQuestionIndex < questionList.questions.count - 1 {
            stopAudio()
            currentQuestionIndex += 1
        }
        else{
            stopAudio()
            currentQuestionIndex = 0
        }
    }
    
    private func previousQuestion() {
        if currentQuestionIndex > 0 {
            stopAudio()
            currentQuestionIndex -= 1
        }
        else{
            stopAudio()
            currentQuestionIndex = questionList.questions.count - 1
        }
    }
    
    private func nextTenQuestions() {
        if currentQuestionIndex <= questionList.questions.count - 11 {
            stopAudio()
            currentQuestionIndex += 10
        }
        else{
            stopAudio()
            let num1 = 10
            let num2 = questionList.questions.count - currentQuestionIndex
            currentQuestionIndex = num1 - num2
        }
    }
    
    private func previousTenQuestions() {
        if currentQuestionIndex >= 10 {
            stopAudio()
            currentQuestionIndex -= 10
        }
        else{
            stopAudio()
            let num1 = 100
            let num2 = 10 - currentQuestionIndex
            currentQuestionIndex = num1 - num2
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

#Preview {
    CTAudioStudy()
        .environmentObject(QuestionList())
        .environmentObject(UserSetting())
        .environmentObject(GovCapManager())
        .environmentObject(AudioManager())
        .modelContainer(for: MarkedQuestion.self)
}
