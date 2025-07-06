//  CTPracticeTest.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 3/12/25.

import SwiftUI
import AVFoundation
import SwiftData
import GoogleMobileAds
import FirebaseCrashlytics

struct CTPracticeTest: View {
    @EnvironmentObject var wrongAnswer: WrongAnswer
    @EnvironmentObject var questionList: QuestionList
    @EnvironmentObject var storeManager: StoreManager
    @EnvironmentObject var adBannerManager: BannerAdManager
    @State private var qIndex: Int = 0
    @State private var score: Int = 0
    @State private var tenQuestions: [CTQuestion] = []
    @State private var isLoading: Bool = true
    @State private var showResult: Bool = false
    @State private var incorrQ: [String] = []
    @State private var userAns: [Bool] = []
    @State private var showingProgressDialog: Bool = false
    @State private var hasCheckedForProgress: Bool = false
    @Environment(\.modelContext) private var context
    @AppStorage("practiceTestCompleted") private var testCompleted = false
    @ObservedObject private var adManager = InterstitialAdManager.shared
    @StateObject private var networkMonitor = NetworkMonitor.shared
    
    private var progressManager: TestProgressManager {
        TestProgressManager(modelContext: context)
    }
    
    var body: some View {
        VStack{
            if isLoading {
                ProgressView()
            }else if showResult || testCompleted{
                CTResultView(
                    questions: $tenQuestions,
                    showResult: $showResult,
                    qIndex: $qIndex,
                    score: $score,
                    userAns: $userAns,
                    incorrQ: $incorrQ,
                    testCompleted: $testCompleted
                )
                .onAppear(){
                    Crashlytics.crashlytics().log("User's in practiceTest resultview")
                    testCompleted = true
                    adManager.showAd()
                }
                if !storeManager.isPurchased("KnT.CitizenshipTest.removeAds") && networkMonitor.isConnected && adBannerManager.isAdReady == true{
                    CTAdBannerView().frame(width: AdSizeBanner.size.width,
                                           height: AdSizeBanner.size.height)
                }
            }
            else {
                VStack{
                    GeometryReader { geo in
                        VStack {
                            PracticeQuestionView(tenQuestions: tenQuestions, qIndex: $qIndex)
                                .frame(height: geo.size.height / 3.25)
                            PracticeAnswerView(tenQuestions: tenQuestions, qIndex: $qIndex, showResult: $showResult, score: $score, incorrQ: $incorrQ, userAns: $userAns, saveProgress: saveProgress)
                        }
                    }
                    if !storeManager.isPurchased("KnT.CitizenshipTest.removeAds") && networkMonitor.isConnected && adBannerManager.isAdReady == true{
                        CTAdBannerView().frame(width: AdSizeBanner.size.width,
                                               height: AdSizeBanner.size.height)
                    }
                }
            }
        }
        .onDisappear(){
            RatingManager.shared.incrementAction()
        }
        .onAppear {
            Crashlytics.crashlytics().log("User went to practiceTest(10q)")
            checkForExistingProgress()
            isLoading = false
        }
        .alert("Tiếp tục bài kiểm tra?", isPresented: $showingProgressDialog) {
            Button("Tiếp tục", role: .cancel) {
                isLoading = false
                Crashlytics.crashlytics().log("User decided to continue old test in PracticeTest")
                adManager.showAd()
            }
            Button("Bắt đầu lại", role: .destructive) {
                startNewTest()
                Crashlytics.crashlytics().log("User decided to start new test in PracticeTest")
                adManager.showAd()
            }
        } message: {
            Text("Bạn có một bài kiểm tra chưa hoàn thành. Bạn muốn tiếp tục hay bắt đầu lại?")
        }
    }
    
    private func checkForExistingProgress() {
        do {
            if let progress = try progressManager.getProgress(for: .practice) {
                if progress.currentIndex == 0 {
                    startNewTest()
                    adManager.showAd()
                    isLoading = false
                    return
                }
                tenQuestions = progress.questionIds.compactMap { id in
                    questionList.questions.first { $0.id == id }
                }
                qIndex = progress.currentIndex
                score = progress.score
                userAns = progress.userAnswers
                incorrQ = progress.incorrectAnswers
                if !testCompleted && !hasCheckedForProgress{
                    showingProgressDialog = true
                    hasCheckedForProgress = true
                } else {
                    isLoading = false
                }
            } else {
                startNewTest()
                isLoading = false
            }
        } catch {
            startNewTest()
            isLoading = false
        }
    }
    
    private func startNewTest() {
        tenQuestions = Array(questionList.questions.shuffled().prefix(10))
        qIndex = 0
        score = 0
        userAns = []
        incorrQ = []
        saveProgress()
    }
    
    private func saveProgress() {
        do {
            try progressManager.saveProgress(
                testType: .practice,
                currentIndex: qIndex,
                score: score,
                questionIds: tenQuestions.map { $0.id },
                userAnswers: userAns,
                incorrectAnswers: incorrQ
            )
        } catch {
#if DEBUG
            print("Error saving progress: \(error)")
#endif
        }
    }
}

struct CTResultView: View {
    @Binding var questions: [CTQuestion]
    @Binding var showResult: Bool
    @Binding var qIndex: Int
    @Binding var score: Int
    @Binding var userAns: [Bool]
    @Binding var incorrQ: [String]
    @Binding var testCompleted: Bool
    @State private var synthesizer = AVSpeechSynthesizer()
    @EnvironmentObject var questionList: QuestionList
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var userSetting: UserSetting
    @EnvironmentObject var govCapManager: GovCapManager
    @EnvironmentObject var adBannerManager: BannerAdManager
    @Environment(\.modelContext) private var context
    @Query private var markedQuestions: [MarkedQuestion]
    @Query private var answerPrefs: [UserAnswerPref]
    @ObservedObject private var adManager = InterstitialAdManager.shared
    
    private var progressManager: TestProgressManager {
        TestProgressManager(modelContext: context)
    }
    
    var body: some View {
        GeometryReader{geo in
            VStack {
                // Score circle
                ZStack {
                    Circle()
                        .fill(.blue)
                    
                    Text("\(score) / 10")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    
                }
                .frame(height: geo.size.height/7)
                
                if score >= 6 {
                    Text("Chúc mừng bạn đã vượt qua được bài kiểm tra")
                        .multilineTextAlignment(.center)
                        .font(.headline)
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                } else {
                    Text("Bạn cần làm đúng ít nhất 6 câu để vượt qua bài kiểm tra. Hãy cố gắng thêm nhé!")
                        .multilineTextAlignment(.center)
                        .font(.headline)
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                }
                Button(action: {
                    // Reset the test state
                    questions = Array(questionList.questions.shuffled().prefix(10))
                    qIndex = 0
                    score = 0
                    userAns = []
                    incorrQ = []
                    testCompleted = false
                    showResult = false
                    
                    try? progressManager.saveProgress(
                        testType: .practice,
                        currentIndex: qIndex,
                        score: score,
                        questionIds: questions.map { $0.id },
                        userAnswers: userAns,
                        incorrectAnswers: incorrQ
                    )
                    adManager.showAd()
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
                    ForEach(Array(questions.enumerated()), id: \.element.id) { index, question in
                        HStack{
                            VStack(alignment: .leading) {
                                Text("Q\(question.id): \(question.question)")
                                    .fontWeight(.medium)
                                if question.id == 20 || question.id == 23 ||
                                    question.id == 43 || question.id == 44 {
                                    Text("Đáp án: \(getZipAnswerForResult(question.id))")
                                        .font(.subheadline)
                                        .fontWeight(.regular)
                                } else {
                                    let pref = preferredAnswer(for: question)
                                    Text("Đáp án: \(pref.en)")
                                        .font(.subheadline)
                                        .fontWeight(.regular)
                                }
                                if index < userAns.count && !userAns[index]{
                                    Text("Bạn trả lời: \(incorrQ[index])")
                                        .font(.subheadline)
                                        .fontWeight(.regular)
                                        .foregroundStyle(.red)
                                }
                            }
                            
                            Spacer()
                            
                            VStack() {
                                Button(action: {
                                    synthesizer.stopSpeaking(at: .immediate)
                                    let utterance = AVSpeechUtterance(string: question.question)
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
                                        .frame(height: 18)
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
        .onDisappear(){
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
    private func getZipAnswerForResult(_ questionId: Int) -> String {
        switch questionId {
        case 20:
            let senators = userSetting.legislators.filter { $0.type == "senator" }
            if !senators.isEmpty {
                return senators.map { "\($0.firstName) \($0.lastName)" }.joined(separator: "\n")
            }
        case 23:
            let representatives = userSetting.legislators.filter { $0.type == "representative" }
            if !representatives.isEmpty {
                return representatives.map { "\($0.firstName) \($0.lastName)" }.joined(separator: "\n")
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
    private func preferredAnswer(for question: CTQuestion) -> (en: String, vie: String) {
        if let pref = answerPrefs.first(where: { $0.questionId == question.id }) {
            return (pref.answerEn, pref.answerVie)
        }
        return (question.answer, question.answerVie)
    }
}


struct PracticeQuestionView: View{
    var tenQuestions: [CTQuestion]
    @Binding var qIndex: Int
    @State private var synthesizer = AVSpeechSynthesizer()
    @EnvironmentObject var audioManager: AudioManager
    @Environment(\.modelContext) private var context
    @Query private var markedQuestions: [MarkedQuestion]
    
    var body: some View{
        ZStack{
            RoundedRectangle(cornerRadius: 0)
                .fill(.blue.opacity(0.5))
                .ignoresSafeArea()
            VStack{
                ProgressView(value: Double(qIndex + 1) / 10)
                    .padding(.horizontal)
                    .tint(.white)
                    .padding(.top, 5)
                
                GeometryReader { geo in
                    ScrollView(showsIndicators: true) {
                        VStack {
                            Spacer()
                            Text("\(tenQuestions[qIndex].question)")
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
                
                HStack{
                    Spacer()
                    
                    //mark button
                    Button(action: {
                        if let existingMark = markedQuestions.first(where: {$0.id == tenQuestions[qIndex].id}){
                            context.delete(existingMark)
                        } else {
                            let newMark = MarkedQuestion(id: tenQuestions[qIndex].id)
                            context.insert(newMark)
                        }
                    }){
                        Image(systemName: markedQuestions.contains {$0.id == tenQuestions[qIndex].id} ? "bookmark.fill" : "bookmark")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 23)
                    }
                    .padding(.trailing)
                    
                    // Voice button
                    Button(action: {
                        synthesizer.stopSpeaking(at: .immediate)
                        let utterance = AVSpeechUtterance(string: tenQuestions[qIndex].question)
                        utterance.voice = AVSpeechSynthesisVoice(identifier: audioManager.voiceIdentifier)
                        utterance.rate = audioManager.speechRate
                        synthesizer.speak(utterance)
                    }){
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
        .toolbar{
            ToolbarItem(placement: .principal){
                Text("\(qIndex + 1) / \(tenQuestions.count)")
            }
        }
        .onDisappear(){
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
}

struct PracticeAnswerView: View{
    @EnvironmentObject var wrongAnswer: WrongAnswer
    @EnvironmentObject var userSetting: UserSetting
    @EnvironmentObject var govCapManager: GovCapManager
    @Query private var answerPrefs: [UserAnswerPref]
    var tenQuestions: [CTQuestion]
    @Binding var qIndex: Int
    @Binding var showResult: Bool
    @Binding var score: Int
    @Binding var incorrQ: [String]
    @Binding var userAns: [Bool]
    @State var showZipInput: Bool = false
    @State var selectedAns: String = ""
    @State var isAns: Bool = false
    @State private var shuffledAnswers: [String] = []
    @State private var answersInitialized: Bool = false
    @ObservedObject private var adManager = InterstitialAdManager.shared
    
    var saveProgress: () -> Void
    
    var body: some View{
        
        VStack{
            ScrollView{
                //handle zip questions
                if tenQuestions[qIndex].id == 20 || tenQuestions[qIndex].id == 23 ||
                    tenQuestions[qIndex].id == 43 || tenQuestions[qIndex].id == 44 {
                    if userSetting.zipCode.isEmpty {
                        Button(action: {
                            showZipInput = true
                        }){
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
                            
                            if qIndex == 9 {
                                isAns = false
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
                        
                    }
                    
                    else{
                        ForEach(shuffledAnswers, id: \.self) { ans in
                            Button(action: {
                                selectedAns = ans
                                isAns = true
                                if selectedAns == getZipAnswer(tenQuestions[qIndex].id){
                                    score += 1
                                    userAns.append(true)
                                    incorrQ.append("")
                                }
                                else{
                                    userAns.append(false)
                                    incorrQ.append(selectedAns)
                                }
                                if qIndex == 9{
                                    isAns = false
                                    saveProgress()
                                    showResult = true
                                }
                            }){
                                Text(ans)
                                    .padding()
                                    .foregroundStyle(.black)
                                    .frame(maxWidth: .infinity)
                                    .background(backgroundColor(for: ans, correctAns: getZipAnswer(tenQuestions[qIndex].id), selectedAns: selectedAns))
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                                    .padding(.vertical, 5)
                            }
                            .disabled(isAns)
                        }
                    }
                }
                //non zip questions
                else{
                    ForEach(shuffledAnswers, id: \.self) { ans in
                        Button(action: {
                            selectedAns = ans
                            isAns = true
                            if selectedAns == preferredAnswer(for: tenQuestions[qIndex]){
                                score += 1
                                userAns.append(true)
                                incorrQ.append("")
                            }
                            else{
                                userAns.append(false)
                                incorrQ.append(selectedAns)
                            }
                            if qIndex == 9{
                                isAns = false
                                saveProgress()
                                adManager.showAd()
                                showResult = true
                            }
                        }){
                            Text(ans)
                                .padding()
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .background(backgroundColor(for: ans, correctAns: preferredAnswer(for: tenQuestions[qIndex]), selectedAns: selectedAns))
                                .cornerRadius(10)
                                .padding(.horizontal)
                                .padding(.vertical, 5)
                        }
                        .disabled(isAns)
                    }
                }
            }
            VStack{
                //show next button when answered
                if isAns{
                    Button(action: {
                        qIndex += 1
                        isAns = false
                        saveProgress()
                    }){
                        Image(systemName: "greaterthan.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 50)
                        //.padding(.bottom)
                    }
                }
                Spacer()
            }.frame(height: UIDevice.current.userInterfaceIdiom == .pad ? 350 : 125)
            
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
        .onChange(of: userSetting.zipCode) { oldValue, newValue in
            updateShuffledAnswers()
        }
        .onChange(of: qIndex){
            isAns = false
            updateShuffledAnswers()
        }
        
    }
    
    private func updateShuffledAnswers() {
        let correspondAns = wrongAnswer.wrongAns.first { $0.id == tenQuestions[qIndex].id }!
        
        if tenQuestions[qIndex].id == 20 || tenQuestions[qIndex].id == 23 ||
            tenQuestions[qIndex].id == 43 || tenQuestions[qIndex].id == 44 {
            if !userSetting.zipCode.isEmpty {
                let correctAnswer = getZipAnswer(tenQuestions[qIndex].id)
                shuffledAnswers = [correctAnswer, correspondAns.firstIncorrect, correspondAns.secondIncorrect, correspondAns.thirdIncorrect].shuffled()
            }
        } else {
            let correct = preferredAnswer(for: tenQuestions[qIndex])
            shuffledAnswers = [correct, correspondAns.firstIncorrect, correspondAns.secondIncorrect, correspondAns.thirdIncorrect].shuffled()
        }
    }
    
    private func backgroundColor(for ans: String, correctAns: String, selectedAns: String) -> Color {
        if !isAns {
            return .blue.opacity(0.1)
        } else {
            if ans == correctAns {
                return .green.opacity(0.5)
            } else if ans == selectedAns && ans != correctAns{
                return .red.opacity(0.5)
            }
            else {
                return .blue.opacity(0.1)
            }
        }
    }
    
    private func preferredAnswer(for question: CTQuestion) -> String {
        if let pref = answerPrefs.first(where: { $0.questionId == question.id }) {
            return pref.answerEn
        }
        return question.answer
    }
    
    private func getZipAnswer(_ questionId: Int) -> String {
        switch questionId {
        case 20:
            let senators = userSetting.legislators.filter { $0.type == "senator" }
            if !senators.isEmpty {
                return senators.map { "\($0.firstName) \($0.lastName)" }.joined(separator: "\n")
            }
        case 23:
            let representatives = userSetting.legislators.filter { $0.type == "representative" }
            if !representatives.isEmpty {
                return representatives.map { "\($0.firstName) \($0.lastName)" }.joined(separator: "\n")
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

