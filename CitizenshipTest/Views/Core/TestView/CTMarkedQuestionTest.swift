//
//  CTMarkedQuestionTest.swift
//  CitizenshipTest
//
//  Created on 3/24/25.
//

import SwiftUI
import AVFoundation
import SwiftData

struct CTMarkedQuestionTest: View {
    @EnvironmentObject var wrongAnswer: WrongAnswer
    @EnvironmentObject var questionList: QuestionList
    @EnvironmentObject var deviceManager: DeviceManager
    @State private var qIndex: Int = 0
    @State private var score: Int = 0
    @State private var markedQuestions: [CTQuestion] = []
    @State private var isLoading: Bool = true
    @State private var showResult: Bool = false
    @State private var noMarkedQuestionsAlert = false
    @State private var incorrQ: [String] = []
    @State private var userAns: [Bool] = []
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var context
    @Query private var markedQuestionIds: [MarkedQuestion]
    @AppStorage("markedQuestionsTestCompleted") private var testCompleted = false
    
    private var progressManager: TestProgressManager {
        TestProgressManager(modelContext: context)
    }
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else if markedQuestions.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "bookmark.slash")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                    
                    Text("Bạn chưa đánh dấu câu hỏi nào")
                        .font(deviceManager.isTablet ? .title : .headline)
                        .foregroundColor(.gray)
                    
                    Text("Hãy đánh dấu câu hỏi để luyện tập tại đây")
                        .font(deviceManager.isTablet ? .body : .callout)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Quay Lại")
                            .font(deviceManager.isTablet ? .title3 : .body)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.top)
                }
                .padding()
            } else if showResult || testCompleted {
                CTMarkedResultView(
                    questions: $markedQuestions,
                    showResult: $showResult,
                    qIndex: $qIndex,
                    score: $score,
                    userAns: $userAns,
                    incorrQ: $incorrQ,
                    testCompleted: $testCompleted
                )
                .onAppear() {
                    testCompleted = true
                }
            } else {
                GeometryReader { geo in
                    VStack {
                        MarkedQuestionView(markedQuestions: markedQuestions, qIndex: $qIndex)
                            .frame(height: geo.size.height / 3)
                        MarkedAnswerView(
                            markedQuestions: markedQuestions,
                            qIndex: $qIndex,
                            showResult: $showResult,
                            score: $score,
                            incorrQ: $incorrQ,
                            userAns: $userAns,
                            saveProgress: saveProgress
                        )
                    }
                }
            }
        }
        .onAppear {
            checkForExistingProgress()
        }
    }
    
    private func checkForExistingProgress() {
        loadMarkedQuestions()
        
        // After loading marked questions, check for existing progress
        do {
            if let progress = try progressManager.getProgress(for: .markedQuestions) {
                // Verify if the saved question IDs match current marked questions
                let savedQuestionIds = progress.questionIds
                let currentMarkedQuestionIds = markedQuestions.map { $0.id }
                
                // Only restore progress if the marked questions are the same
                if Set(savedQuestionIds).isSubset(of: Set(currentMarkedQuestionIds)) &&
                   savedQuestionIds.count == currentMarkedQuestionIds.count {
                    qIndex = progress.currentIndex
                    score = progress.score
                    userAns = progress.userAnswers
                    incorrQ = progress.incorrectAnswers
                } else {
                    // If marked questions have changed, start a new test
                    startNewTest()
                }
            } else {
                startNewTest()
            }
        } catch {
            startNewTest()
        }
    }
    
    private func startNewTest() {
        qIndex = 0
        score = 0
        userAns = []
        incorrQ = []
        testCompleted = false
        
        if !markedQuestions.isEmpty {
            saveProgress()
        }
    }
    
    private func saveProgress() {
        do {
            try progressManager.saveProgress(
                testType: .markedQuestions,
                currentIndex: qIndex,
                score: score,
                questionIds: markedQuestions.map { $0.id },
                userAnswers: userAns,
                incorrectAnswers: incorrQ
            )
        } catch {
            print("Error saving progress: \(error)")
        }
    }
    
    private func loadMarkedQuestions() {
        let markedIds = markedQuestionIds.map { $0.id }
        if markedIds.isEmpty {
            // No marked questions
            isLoading = false
            return
        }
        
        markedQuestions = questionList.questions.filter { question in
            markedIds.contains(question.id)
        }.sorted { $0.id < $1.id } // Sort by question ID for consistency
        
        isLoading = false
    }
}


struct CTMarkedResultView: View {
    @Binding var questions: [CTQuestion]
    @Binding var showResult: Bool
    @Binding var qIndex: Int
    @Binding var score: Int
    @Binding var userAns: [Bool]
    @Binding var incorrQ: [String]
    @Binding var testCompleted: Bool
    @State private var synthesizer = AVSpeechSynthesizer()
    @EnvironmentObject var deviceManager: DeviceManager
    @Environment(\.modelContext) private var context
    @Query private var markedQuestions: [MarkedQuestion]
    
    private var progressManager: TestProgressManager {
        TestProgressManager(modelContext: context)
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                // Score circle
                ZStack {
                    Circle()
                        .fill(.blue)
                    
                    Text("\(score) / \(questions.count)")
                        .font(deviceManager.isTablet ? .largeTitle : .title)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    
                }
                .frame(height: geo.size.height/7)
                
                Button(action: {
                    qIndex = 0
                    score = 0
                    userAns = []
                    incorrQ = []
                    testCompleted = false
                    showResult = false
                    
                    do {
                               try progressManager.clearProgress(for: .markedQuestions)
                           } catch {
                               print("Error clearing progress: \(error)")
                           }
                }) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Thử Lại")
                            .font(deviceManager.isTablet ? .title3 : .body)
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                
                // Question list
                ScrollView {
                    ForEach(Array(questions.enumerated()), id: \.element.id) { index, question in
                        HStack{
                            VStack(alignment: .leading) {
                                Text("Q\(question.id): \(question.question)")
                                    .font(deviceManager.isTablet ? .title3 : .body)
                                    .fontWeight(.medium)
                                
                                Text("Đáp án: \(question.answer)")
                                    .font(deviceManager.isTablet ? .body : .subheadline)
                                    .fontWeight(.regular)
                                if index < userAns.count && !userAns[index]{
                                    Text("Bạn trả lời: \(incorrQ[index])")
                                        .font(deviceManager.isTablet ? .body : .subheadline)
                                        .fontWeight(.regular)
                                        .foregroundStyle(.red)
                                }
                            }
                            
                            Spacer()
                            
                            VStack() {
                                Button(action: {
                                    synthesizer.stopSpeaking(at: .immediate)
                                    let utterance = AVSpeechUtterance(string: question.question)
                                    utterance.voice = AVSpeechSynthesisVoice()
                                    utterance.rate = 0.3
                                    synthesizer.speak(utterance)
                                }) {
                                    Image(systemName: "speaker.wave.3")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: deviceManager.isTablet ? 25 : 18)
                                }
                                
                                Button(action: {
                                    if let existingMark = markedQuestions.first(where: {$0.id == question.id}) {
                                        context.delete(existingMark)
                                    } else {
                                        let newMark = MarkedQuestion(id: question.id)
                                        context.insert(newMark)
                                    }
                                }) {
                                    Image(systemName: markedQuestions.contains(where: {$0.id == question.id}) ? "bookmark.fill" : "bookmark")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: deviceManager.isTablet ? 25 : 18)
                                }
                            }
                            
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(index < userAns.count && userAns[index] == true ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                        )
                        .padding(.horizontal)
                    }
                }
                
            }
        }
    }
}

struct MarkedQuestionView: View {
    var markedQuestions: [CTQuestion]
    @Binding var qIndex: Int
    @State private var synthesizer = AVSpeechSynthesizer()
    @EnvironmentObject var deviceManager: DeviceManager
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0)
                .fill(.blue.opacity(0.5))
                .ignoresSafeArea()
            
            VStack {
                Text("\(qIndex + 1) of \(markedQuestions.count)")
                    .font(deviceManager.isTablet ? .title : .body)
                
                ProgressView(value: Double(qIndex + 1) / Double(markedQuestions.count))
                    .padding()
                    .tint(.white)
                
                Text("\(markedQuestions[qIndex].question)")
                    .font(deviceManager.isTablet ? .title : .body)
                    .padding()
                
                HStack {
                    Spacer()
                    
                    // Voice button
                    Button(action: {
                        synthesizer.stopSpeaking(at: .immediate)
                        let utterance = AVSpeechUtterance(string: markedQuestions[qIndex].question)
                        utterance.voice = AVSpeechSynthesisVoice()
                        utterance.rate = 0.3
                        synthesizer.speak(utterance)
                    }) {
                        Image(systemName: "speaker.wave.3")
                            .resizable()
                            .scaledToFit()
                            .frame(height: deviceManager.isTablet ? 50 : 25)
                    }
                }
                .padding()
            }
        }
    }
}

struct MarkedAnswerView: View {
    @EnvironmentObject var wrongAnswer: WrongAnswer
    @EnvironmentObject var userSetting: UserSetting
    @EnvironmentObject var deviceManager: DeviceManager
    @EnvironmentObject var govCapManager: GovCapManager
    var markedQuestions: [CTQuestion]
    @Binding var qIndex: Int
    @Binding var showResult: Bool
    @Binding var score: Int
    @Binding var incorrQ: [String]
    @Binding var userAns: [Bool]
    @State var showZipInput: Bool = false
    @State var selectedAns: String = ""
    @State var isAns: Bool = false
    @State private var shuffledAnswers: [String] = []
    @State private var answersInitialized = false
    
    var saveProgress: () -> Void
    
    var body: some View {
        VStack {
            // Handle zip questions
            if markedQuestions[qIndex].id == 20 || markedQuestions[qIndex].id == 23 ||
                markedQuestions[qIndex].id == 43 || markedQuestions[qIndex].id == 44 {
                if userSetting.zipCode.isEmpty {
                    Button(action: {
                        showZipInput = true
                    }) {
                        Text("Nhập ZIP Code để thấy câu trả lời")
                            .padding()
                            .foregroundStyle(.white)
                            .background(.blue)
                            .cornerRadius(10)
                    }
                } else {
                    ForEach(shuffledAnswers, id: \.self) { ans in
                        Button(action: {
                            handleAnswer(ans: ans, correctAns: getZipAnswer(markedQuestions[qIndex].id))
                        }) {
                            Text(ans)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding()
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .background(backgroundColor(for: ans, correctAns: getZipAnswer(markedQuestions[qIndex].id), selectedAns: selectedAns))
                                .cornerRadius(10)
                                .padding(.horizontal)
                                .padding(.vertical, 10)
                        }
                        .disabled(isAns)
                    }
                }
            } else {
                // Non-zip questions
                ForEach(shuffledAnswers, id: \.self) { ans in
                    Button(action: {
                        handleAnswer(ans: ans, correctAns: markedQuestions[qIndex].answer)
                    }) {
                        Text(ans)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding()
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .background(backgroundColor(for: ans, correctAns: markedQuestions[qIndex].answer, selectedAns: selectedAns))
                            .cornerRadius(10)
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                    }
                    .disabled(isAns)
                }
            }
            
            Spacer()
            
            // Show next button when answered
            if isAns {
                Button(action: {
                    advanceToNextQuestion()
                }) {
                    Image(systemName: "greaterthan.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 50)
                        .padding(.bottom)
                }
            }
        }
        .sheet(isPresented: $showZipInput) {
            CTZipInput()
                .environmentObject(userSetting)
                .environmentObject(deviceManager)
        }
        .onAppear {
            if !answersInitialized {
                updateShuffledAnswers()
                answersInitialized = true
            }
        }
        .onChange(of: userSetting.zipCode) { oldValue, newValue in
            updateShuffledAnswers()
        }
        .onChange(of: qIndex) { oldValue, newValue in
            updateShuffledAnswers()
        }
    }
    
    private func handleAnswer(ans: String, correctAns: String) {
        selectedAns = ans
        isAns = true
        
        if selectedAns == correctAns {
            score += 1
            userAns.append(true)
            incorrQ.append("")
        } else {
            userAns.append(false)
            incorrQ.append(selectedAns)
        }
                
        if qIndex == markedQuestions.count - 1 {
            saveProgress()
            showResult = true
        }
    }
    
    private func advanceToNextQuestion() {
        if qIndex < markedQuestions.count - 1 {
            qIndex += 1
            isAns = false
            saveProgress()
        } else {
            saveProgress()
            showResult = true
        }
    }
    
    private func updateShuffledAnswers() {
        let correspondAns = wrongAnswer.wrongAns.first { $0.id == markedQuestions[qIndex].id }!
        
        if markedQuestions[qIndex].id == 20 || markedQuestions[qIndex].id == 23 ||
            markedQuestions[qIndex].id == 43 || markedQuestions[qIndex].id == 44 {
            if !userSetting.zipCode.isEmpty {
                let correctAnswer = getZipAnswer(markedQuestions[qIndex].id)
                shuffledAnswers = [correctAnswer, correspondAns.firstIncorrect, correspondAns.secondIncorrect, correspondAns.thirdIncorrect].shuffled()
            }
        } else {
            shuffledAnswers = [markedQuestions[qIndex].answer, correspondAns.firstIncorrect, correspondAns.secondIncorrect, correspondAns.thirdIncorrect].shuffled()
        }
    }
    
    private func backgroundColor(for ans: String, correctAns: String, selectedAns: String) -> Color {
        if !isAns {
            return .blue.opacity(0.1)
        } else {
            if ans == correctAns {
                return .green.opacity(0.5)
            } else if ans == selectedAns && ans != correctAns {
                return .red.opacity(0.5)
            } else {
                return .blue.opacity(0.1)
            }
        }
    }
    
    private func getZipAnswer(_ questionId: Int) -> String {
        switch questionId {
        case 20:
            let senators = userSetting.legislators.filter { $0.type == "senator" }
            if let senator = senators.first {
                return "\(senator.firstName) \(senator.lastName)"
            }
        case 23:
            let representatives = userSetting.legislators.filter { $0.type == "representative" }
            if let rep = representatives.first {
                return "\(rep.firstName) \(rep.lastName)"
            }
        case 43:
            let state = userSetting.state
            if let govCap = govCapManager.govAndCap.first(where: { $0.state == state }) {
                return govCap.gov
            }
        case 44:
            let state = userSetting.state
            if let govCap = govCapManager.govAndCap.first(where: { $0.state == state }) {
                return govCap.capital
            }
        default:
            return ""
        }
        return ""
    }
}

#Preview {
    CTMarkedQuestionTest()
        .environmentObject(QuestionList())
        .environmentObject(WrongAnswer())
        .environmentObject(DeviceManager())
        .environmentObject(UserSetting())
        .environmentObject(GovCapManager())
        .modelContainer(for: MarkedQuestion.self)
}
