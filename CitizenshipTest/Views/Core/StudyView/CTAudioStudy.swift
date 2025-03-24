//
//  CTAudioStudy.swift
//  CitizenshipTest
//
//  Created on 3/24/25.
//

import SwiftUI
import AVFoundation
import SwiftData

struct CTAudioStudy: View {
    @EnvironmentObject var questionList: QuestionList
    @EnvironmentObject var deviceManager: DeviceManager
    @EnvironmentObject var userSetting: UserSetting
    @EnvironmentObject var govCapManager: GovCapManager
    @State private var currentQuestionIndex = 0
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
    private let pauseDuration: TimeInterval = 2
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                // Controls section
                Toggle("Nghe Đáp Án", isOn: $playAnswers)
                    .font(deviceManager.isTablet ? .title3 : .body)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    .disabled(isPlaying)
                    .padding()
                
                // Progress indicator
                VStack {
                    Text("\(currentQuestionIndex + 1) / \(questionList.questions.count)")
                        .font(deviceManager.isTablet ? .title : .title3)
                    
                    ProgressView(value: Double(currentQuestionIndex + 1), total: Double(questionList.questions.count))
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .padding(.horizontal)
                }
                .padding()
                
                Spacer()
                
                // Question/Answer display
                VStack(spacing: 20) {
                    VStack {
                        HStack {
                            Text("Câu hỏi \(questionList.questions[currentQuestionIndex].id)")
                                .font(deviceManager.isTablet ? .title3 : .headline)
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
                                    .frame(height: deviceManager.isTablet ? 25 : 18)
                            }
                        }
                        
                        Text(questionList.questions[currentQuestionIndex].question)
                            .font(deviceManager.isTablet ? .title2 : .title3)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.leading)
                            .padding(.vertical, 5)
                        
                        Text(questionList.questions[currentQuestionIndex].questionVie)
                            .font(deviceManager.isTablet ? .title3 : .body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.blue.opacity(0.1)))
                    
                    if playAnswers {
                        VStack {
                            Text("Đáp án")
                                .font(deviceManager.isTablet ? .title3 : .headline)
                                .foregroundColor(.green)
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
                                    .font(deviceManager.isTablet ? .title2 : .title3)
                                    .fontWeight(.medium)
                                    .multilineTextAlignment(.leading)
                                    .padding(.vertical, 5)
                                
                                Text(questionList.questions[currentQuestionIndex].answerVie)
                                    .font(deviceManager.isTablet ? .title3 : .body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.green.opacity(0.1)))
                    }
                }
                .padding()
                .transition(.opacity)
                
                
                Spacer()
                
                // Playback controls
                VStack(spacing: 20) {
                    // Standard playback controls
                    HStack(spacing: deviceManager.isTablet ? 60 : 30) {
                        Button(action: previousTenQuestions) {
                            Image(systemName: "backward.end.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(height: deviceManager.isTablet ? 40 : 25)
                            
                            
                        }
                        .disabled(currentQuestionIndex < 10 || isPlaying)
                        
                        Button(action: previousQuestion) {
                            Image(systemName: "backward.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(height: deviceManager.isTablet ? 40 : 25)
                        }
                        .disabled(currentQuestionIndex == 0 || isPlaying)
                        
                        Button(action: togglePlayback) {
                            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(height: deviceManager.isTablet ? 70 : 45)
                        }
                        
                        Button(action: nextQuestion) {
                            Image(systemName: "forward.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(height: deviceManager.isTablet ? 40 : 25)
                        }
                        .disabled(currentQuestionIndex == questionList.questions.count - 1 || isPlaying)
                        
                        Button(action: nextTenQuestions) {
                            
                            Image(systemName: "forward.end.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(height: deviceManager.isTablet ? 40 : 25)
                            
                        }
                        .disabled(currentQuestionIndex > questionList.questions.count - 11 || isPlaying)
                        
                    }
                }
                .padding(.bottom, 30)
            }
            .padding()
        }
        .sheet(isPresented: $showingZipPrompt) {
            CTZipInput()
                .environmentObject(userSetting)
                .environmentObject(deviceManager)
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
        isPlaying = true
        isPlayingAnswer = false
        
        synthesizer.stopSpeaking(at: .immediate)
        timer?.invalidate()
        
        let question = questionList.questions[currentQuestionIndex]
        let utterance = AVSpeechUtterance(string: question.question)
        utterance.voice = AVSpeechSynthesisVoice()
        utterance.rate = 0.4
        
        delegate = SpeechDelegate(
            onFinished: {
                // Only continue to answer if playAnswers is true
                if playAnswers {
                    // Wait a moment before playing the answer
                    self.timer = Timer.scheduledTimer(withTimeInterval: self.pauseDuration, repeats: false) { _ in
                        self.playCurrentAnswer()
                    }
                } else {
                    // Move to next question automatically if answers are disabled
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        AudioServicesPlaySystemSound(1152)
                    }
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
                    if let representative = representatives.first {
                        answerText = "\(representative.firstName) \(representative.lastName)"
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
        utterance.voice = AVSpeechSynthesisVoice()
        utterance.rate = 0.4
        
        // Create and store a strong reference to the answer delegate
        delegate = SpeechDelegate(
            onFinished: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    AudioServicesPlaySystemSound(1152)
                }
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
    }
    
    private func nextQuestion() {
        if currentQuestionIndex < questionList.questions.count - 1 {
            stopAudio()
            currentQuestionIndex += 1
        }
    }
    
    private func previousQuestion() {
        if currentQuestionIndex > 0 {
            stopAudio()
            currentQuestionIndex -= 1
        }
    }
    
    private func nextTenQuestions() {
        if currentQuestionIndex <= questionList.questions.count - 11 {
            stopAudio()
            currentQuestionIndex += 10
        }
    }
    
    private func previousTenQuestions() {
        if currentQuestionIndex >= 10 {
            stopAudio()
            currentQuestionIndex -= 10
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
        .environmentObject(DeviceManager())
        .environmentObject(UserSetting())
        .environmentObject(GovCapManager())
        .modelContainer(for: MarkedQuestion.self)
}
