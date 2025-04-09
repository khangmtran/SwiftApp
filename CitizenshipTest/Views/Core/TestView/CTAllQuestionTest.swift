//
//  CTAllQuestionTest.swift
//  CitizenshipTest
//
//  Created on 3/20/25.
//

import SwiftUI
import AVFoundation
import SwiftData

struct CTAllQuestionTest: View {
    @EnvironmentObject var wrongAnswer: WrongAnswer
    @EnvironmentObject var questionList: QuestionList
    @EnvironmentObject var audioManager: AudioManager
    @State private var qIndex: Int = 0
    @State private var score: Int = 0
    @State private var isLoading: Bool = true
    @State private var showResult: Bool = false
    @State private var incorrQ: [String] = []
    @State private var userAns: [Bool] = []
    @State private var showingProgressDialog: Bool = false
    @Environment(\.modelContext) private var context
    @AppStorage("allQuestionsTestCompleted") private var testCompleted = false
    
    private var progressManager: TestProgressManager {
        TestProgressManager(modelContext: context)
    }
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else if showResult || testCompleted {
                CTAllTestResultView(
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
                        AllTestQuestionView(qIndex: qIndex)
                            .frame(height: geo.size.height / 2.5)
                        AllTestAnswerView(
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
        .alert("Tiếp tục bài kiểm tra?", isPresented: $showingProgressDialog) {
            Button("Bắt đầu lại", role: .destructive) {
                startNewTest()
            }
            Button("Tiếp tục", role: .cancel) {
                isLoading = false
            }
        } message: {
            Text("Bạn có một bài kiểm tra chưa hoàn thành. Bạn muốn tiếp tục hay bắt đầu lại?")
        }
    }
    
    private func checkForExistingProgress() {
        do {
            if let progress = try progressManager.getProgress(for: .allQuestions) {
                if progress.currentIndex == 0 {
                    startNewTest()
                    return
                }
                qIndex = progress.currentIndex
                score = progress.score
                userAns = progress.userAnswers
                incorrQ = progress.incorrectAnswers
                if !testCompleted {
                    showingProgressDialog = true
                    isLoading = false
                } else {
                    isLoading = false
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
        saveProgress()
        isLoading = false
    }
    
    private func saveProgress() {
        do {
            try progressManager.saveProgress(
                testType: .allQuestions,
                currentIndex: qIndex,
                score: score,
                questionIds: questionList.questions.map { $0.id },
                userAnswers: userAns,
                incorrectAnswers: incorrQ
            )
        } catch {
            print("Error saving progress: \(error)")
        }
    }
}

struct AllTestQuestionView: View {
    var qIndex: Int
    @State private var synthesizer = AVSpeechSynthesizer()
    @EnvironmentObject var questionList: QuestionList
    @EnvironmentObject var audioManager: AudioManager
    @Environment(\.modelContext) private var context
    @Query private var markedQuestions: [MarkedQuestion]
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0)
                .fill(.blue.opacity(0.5))
                .ignoresSafeArea()
            VStack {
                Text("\(qIndex + 1) of \(questionList.questions.count)")
                ProgressView(value: Double(qIndex + 1) / Double(questionList.questions.count))
                    .padding(.horizontal)
                    .tint(.white)
                
                let currentQuestion = questionList.questions[qIndex]
                
                GeometryReader { geo in
                    ScrollView(showsIndicators: true) {
                        VStack {
                            Spacer()
                            Text("\(currentQuestion.question)")
                                .font(.title3)
                                .fontWeight(.medium)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal)
                            
                            Spacer()
                        }
                        .frame(minHeight: geo.size.height)
                        .frame(maxWidth: .infinity)
                    }
                }
                
                HStack {
                    Spacer()
                    
                    // Bookmark button
                    Button(action: {
                        if let existingMark = markedQuestions.first(where: {$0.id == currentQuestion.id}) {
                            context.delete(existingMark)
                        } else {
                            let newMark = MarkedQuestion(id: currentQuestion.id)
                            context.insert(newMark)
                        }
                    }) {
                        Image(systemName: markedQuestions.contains {$0.id == currentQuestion.id} ? "bookmark.fill" : "bookmark")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 23)
                    }
                    .padding(.trailing)
                    
                    // Voice button
                    Button(action: {
                        synthesizer.stopSpeaking(at: .immediate)
                        let utterance = AVSpeechUtterance(string: currentQuestion.question)
                        utterance.voice = AVSpeechSynthesisVoice(identifier: audioManager.voiceIdentifier)
                        utterance.rate = audioManager.speechRate
                        synthesizer.speak(utterance)
                    }) {
                        Image(systemName: "speaker.wave.3")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 23)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .onDisappear(){
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
}

struct AllTestAnswerView: View {
    @EnvironmentObject var wrongAnswer: WrongAnswer
    @EnvironmentObject var userSetting: UserSetting
    @EnvironmentObject var govCapManager: GovCapManager
    @EnvironmentObject var questionList: QuestionList
    @EnvironmentObject var audioManager: AudioManager
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
            ScrollView{
                let currentQuestion = questionList.questions[qIndex]
                
                // Handle ZIP code-dependent questions
                if currentQuestion.id == 20 || currentQuestion.id == 23 ||
                    currentQuestion.id == 43 || currentQuestion.id == 44 {
                    if userSetting.zipCode.isEmpty {
                        Button(action: {
                            showZipInput = true
                        }) {
                            Text("Nhập ZIP Code để thấy câu trả lời")
                                .padding()
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .background(.blue)
                                .cornerRadius(10)
                        }
                        .padding()
                        
                        Button(action: {
                            selectedAns = "Bỏ qua"
                            userAns.append(false)
                            incorrQ.append(selectedAns)
                            
                            if qIndex == questionList.questions.count - 1 {
                                saveProgress()
                                showResult = true
                            }
                            else{
                                qIndex += 1
                                saveProgress()
                            }
                            
                        }) {
                            Text("Bỏ qua câu hỏi này")
                                .padding()
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .background(.red.opacity(0.8))
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        
                        
                    } else {
                        ForEach(shuffledAnswers, id: \.self) { ans in
                            answerButton(ans: ans, correctAns: getZipAnswer(currentQuestion.id))
                        }
                    }
                }
                // Regular questions
                else {
                    ForEach(shuffledAnswers, id: \.self) { ans in
                        answerButton(ans: ans, correctAns: currentQuestion.answer)
                    }
                }
            }
            Spacer()
            
            // Show next button when answered
            if isAns {
                Button(action: {
                    if qIndex < questionList.questions.count - 1 {
                        qIndex += 1
                        isAns = false
                        updateShuffledAnswers()
                        saveProgress()
                    } else {
                        saveProgress()
                        showResult = true
                    }
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
        }
        .onAppear {
            if !answersInitialized {
                updateShuffledAnswers()
                answersInitialized = true
            }
        }
        .onChange(of: userSetting.zipCode) {
            updateShuffledAnswers()
        }
        .onChange(of: qIndex) {
            updateShuffledAnswers()
        }
        
    }
    
    private func answerButton(ans: String, correctAns: String) -> some View {
        Button(action: {
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
            
            if qIndex == questionList.questions.count - 1 {
                saveProgress()
                showResult = true
            }
        }) {
            Text(ans)
                .fixedSize(horizontal: false, vertical: true)
                .padding()
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .background(backgroundColor(for: ans, correctAns: correctAns, selectedAns: selectedAns))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.vertical, 10)
        }
        .disabled(isAns)
    }
    
    private func updateShuffledAnswers() {
        let currentQuestion = questionList.questions[qIndex]
        
        let correspondAns = wrongAnswer.wrongAns.first { $0.id == currentQuestion.id }!
        
        if currentQuestion.id == 20 || currentQuestion.id == 23 ||
            currentQuestion.id == 43 || currentQuestion.id == 44 {
            if !userSetting.zipCode.isEmpty {
                let correctAnswer = getZipAnswer(currentQuestion.id)
                shuffledAnswers = [correctAnswer, correspondAns.firstIncorrect, correspondAns.secondIncorrect, correspondAns.thirdIncorrect].shuffled()
            }
        } else {
            shuffledAnswers = [currentQuestion.answer, correspondAns.firstIncorrect, correspondAns.secondIncorrect, correspondAns.thirdIncorrect].shuffled()
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

struct CTAllTestResultView: View {
    @Binding var showResult: Bool
    @Binding var qIndex: Int
    @Binding var score: Int
    @Binding var userAns: [Bool]
    @Binding var incorrQ: [String]
    @Binding var testCompleted: Bool
    @State private var synthesizer = AVSpeechSynthesizer()
    @State private var showIncorrectOnly = false
    @EnvironmentObject var questionList: QuestionList
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var userSetting: UserSetting
    @EnvironmentObject var govCapManager: GovCapManager
    @Environment(\.modelContext) private var context
    @Query private var markedQuestions: [MarkedQuestion]
    
    private var progressManager: TestProgressManager {
        TestProgressManager(modelContext: context)
    }
    
    // Filtered questions based on showIncorrectOnly toggle
    private var filteredResults: [(index: Int, question: CTQuestion, correct: Bool, wrongAnswer: String)] {
        var results: [(index: Int, question: CTQuestion, correct: Bool, wrongAnswer: String)] = []
        
        for i in 0..<userAns.count {
            if i < questionList.questions.count {
                let isCorrect = userAns[i]
                let wrongAns = incorrQ[i]
                let question = questionList.questions[i]
                
                if !showIncorrectOnly || (showIncorrectOnly && !isCorrect) {
                    results.append((index: i, question: question, correct: isCorrect, wrongAnswer: wrongAns))
                }
            }
        }
        
        return results
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                // Score circle
                ZStack {
                    Circle()
                        .fill(.blue)
                    
                    Text("\(score) / 100")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    
                }
                .frame(height: geo.size.height/7)
                
                // Filter toggle
                Toggle("Chỉ hiển thị câu trả lời sai", isOn: $showIncorrectOnly)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                
                // Restart button
                Button(action: {
                    // Reset test state
                    qIndex = 0
                    score = 0
                    userAns = []
                    incorrQ = []
                    testCompleted = false
                    showResult = false
                    
                    do {
                        try progressManager.clearProgress(for: .allQuestions)
                    } catch {
                        print("Error clearing progress: \(error)")
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Thử Lại")
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                
                // Question list
                ScrollView {
                    VStack {
                        ForEach(filteredResults, id: \.index) { result in
                            HStack{
                                VStack(alignment: .leading) {
                                    Text("Q\(result.question.id): \(result.question.question)")
                                        .fontWeight(.medium)
                                        .multilineTextAlignment(.leading)
                                    
                                    if result.question.id == 20 || result.question.id == 23 ||
                                        result.question.id == 43 || result.question.id == 44 {
                                        Text("Đáp án: \(getZipAnswerForResult(result.question.id))")
                                            .font(.subheadline)
                                            .fontWeight(.regular)
                                    } else {
                                        Text("Đáp án: \(result.question.answer)")
                                            .font(.subheadline)
                                            .fontWeight(.regular)
                                    }
                                    
                                    if !result.correct {
                                        Text("Bạn trả lời: \(result.wrongAnswer)")
                                            .font(.subheadline)
                                            .foregroundColor(.red)
                                    }
                                }
                                
                                Spacer()
                                
                                VStack{
                                    Button(action: {
                                        synthesizer.stopSpeaking(at: .immediate)
                                        let utterance = AVSpeechUtterance(string: result.question.question)
                                        utterance.voice = AVSpeechSynthesisVoice(identifier: audioManager.voiceIdentifier)
                                        utterance.rate = audioManager.speechRate
                                        synthesizer.speak(utterance)
                                    }) {
                                        Image(systemName: "speaker.wave.3")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 18)
                                    }
                                    .padding(.bottom)
                                    
                                    Button(action: {
                                        if let existingMark = markedQuestions.first(where: {$0.id == result.question.id}) {
                                            context.delete(existingMark)
                                        } else {
                                            let newMark = MarkedQuestion(id: result.question.id)
                                            context.insert(newMark)
                                        }
                                    }) {
                                        Image(systemName: markedQuestions.contains(where: {$0.id == result.question.id}) ? "bookmark.fill" : "bookmark")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 18)
                                    }
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(result.correct ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                            )
                            .padding(.horizontal)
                        }
                    }
                }
            }
        }
        .onDisappear(){
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
    private func getZipAnswerForResult(_ questionId: Int) -> String {
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
    CTAllQuestionTest()
        .environmentObject(QuestionList())
        .environmentObject(WrongAnswer())
        .environmentObject(UserSetting())
        .environmentObject(GovCapManager())
}
