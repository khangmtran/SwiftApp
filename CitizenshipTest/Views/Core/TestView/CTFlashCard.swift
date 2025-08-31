//
//  CTFlashCard.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 2/27/25.
//

import SwiftUI
import AVFoundation
import SwiftData
import FirebaseCrashlytics

struct CTFlashCard: View{
    @State private var questions: [CTQuestion] = []
    @State private var isFlipped = false
    @State private var frontDegree = 0.0
    @State private var backDegree = 90.0
    @State private var frontZIndex = 1.0
    @State private var backZIndex = 0.0
    @State private var synthesizer = AVSpeechSynthesizer()
    @State private var isChangingCard = false
    @State private var showingZipPrompt = false
    @State private var showQuestionType: Bool = false
    @State private var noMarkedQuestionsAlert: Bool = false
    @State private var qType = "Thứ Tự Thẻ"
    @State private var showJumpPrompt: Bool = false
    @State private var qIndex = 0
    @EnvironmentObject var userSetting: UserSetting
    @EnvironmentObject var questionList: QuestionList
    @EnvironmentObject var govCapManager: GovCapManager
    @EnvironmentObject var audioManager: AudioManager
    @ObservedObject private var adManager = InterstitialAdManager.shared
    @Environment(\.modelContext) private var context
    
    var body: some View{
        VStack{
            HStack(alignment: .center){
                Text("Thẻ \(qIndex + 1) / \(questions.count)")
                Spacer()
                Button(action: {
                    Crashlytics.crashlytics().log("User find card in flashcard")
                    showJumpPrompt = true
                }) {
                    HStack {
                        Text("Tìm Thẻ")
                    }
                    .foregroundColor(.blue)
                }
                Spacer()
                Button(action:{
                    Crashlytics.crashlytics().log("User look for question types in flash")
                    showQuestionType = true
                }){
                    Text("\(qType)")
                }
            }
            .padding(.horizontal)
            
            ZStack{
                if !questions.isEmpty{
                    CardFront(zIndex:$frontZIndex, degree: $frontDegree, isFlipped: $isFlipped,
                              questions: $questions, qIndex: $qIndex, isChangingCard: $isChangingCard,
                              synthesizer: synthesizer)
                    
                    CardBack(zIndex: $backZIndex, degree: $backDegree, isFlipped: $isFlipped,
                             questions: $questions, qIndex: $qIndex, isChangingCard: $isChangingCard,
                             synthesizer: synthesizer,
                             showingZipPrompt: $showingZipPrompt)
                    .opacity(isChangingCard ? 0 : 1)
                }
                else{
                    ProgressView()
                }
            }
            
        }
        .sheet(isPresented: $showQuestionType) {
            QuestionTypeView(questions: $questions, qIndex: $qIndex, noMarkedQuestionsAlert: $noMarkedQuestionsAlert, qType: $qType)
                .presentationDetents([.fraction(0.3)])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showJumpPrompt) {
            JumpToCardView(qIndex: $qIndex, totalCards: questions.count, jumpToIndex: .constant(""))
                .presentationDetents([.fraction(0.3)])
                .presentationDragIndicator(.visible)
        }
        //no marked questions
        .alert("", isPresented: $noMarkedQuestionsAlert){
            Button("OK", role: .cancel){}
        } message: {
            Text("Hiện tại bạn chưa có câu hỏi đánh dấu")
        }
        
        //card flipped
        .onChange(of: qIndex){ oldValue, newValue in
            isChangingCard = true
            isFlipped = false
            updateCards()
            synthesizer.stopSpeaking(at: .immediate)
        }
        .onAppear(){
            if questions.isEmpty{
                questions = questionList.questions
            }
            Crashlytics.crashlytics().log("User went to flashcard")
            adManager.showAd()
        }
        .safeAreaInset(edge: .bottom) {
            NavButtonsFC(qIndex: $qIndex, questions: questions)
                .padding()
                .background(Color.white)
        }
        .onDisappear(){
            synthesizer.stopSpeaking(at: .immediate)
            RatingManager.shared.incrementAction()
        }
        
    }
    private func updateCards() {
        frontDegree = 0.0
        backDegree = -90.0
        frontZIndex = 1.0
        backZIndex = 0.0
    }
}

struct JumpToCardView: View {
    @Binding var qIndex: Int
    var totalCards: Int
    @State private var selectedCardNumber: Int
    @Environment(\.dismiss) private var dismiss
    
    init(qIndex: Binding<Int>, totalCards: Int, jumpToIndex: Binding<String>) {
        self._qIndex = qIndex
        self.totalCards = totalCards
        self._selectedCardNumber = State(initialValue: qIndex.wrappedValue + 1)
    }
    
    var body: some View {
        VStack {
            HStack {
                Button("Hủy") {
                    dismiss()
                }
                
                Spacer()
                
                Text("Chọn thẻ")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Đi đến") {
                    qIndex = selectedCardNumber - 1
                    dismiss()
                }
                .foregroundColor(.blue)
            }
            .padding(.top)
            .padding(.horizontal)
            
            Picker("Thẻ số", selection: $selectedCardNumber) {
                ForEach(1...totalCards, id: \.self) { num in
                    Text("\(num)")
                        .font(.title3)
                }
            }
            .pickerStyle(.wheel)
        }
    }
}

struct NavButtonsFC: View{
    @Binding var qIndex: Int
    @ObservedObject private var adManager = InterstitialAdManager.shared
    @Query private var answerPrefs: [UserAnswerPref]
    let questions: [CTQuestion]
    
    var body: some View {
        HStack(){
            Button(action: prevQuestion){
                Text("Trở Về")
            }
            .padding()
            .foregroundStyle(.white)
            .background(.blue)
            .cornerRadius(10)
            
            Spacer()
            
            Button(action: nextQuestion){
                Text("Tiếp Theo")
            }
            .padding()
            .foregroundStyle(.white)
            .background(.blue)
            .cornerRadius(10)
            
        }
        
    }
    
    private func nextQuestion(){
        if qIndex < questions.count - 1 {
            qIndex += 1
        }
        else if qIndex == questions.count - 1{
            qIndex = 0
        }
    }
    
    private func prevQuestion(){
        if qIndex > 0{
            qIndex -= 1
        }
        else if qIndex == 0{
            qIndex = questions.count - 1
        }
    }
    private func preferredAnswer(for question: CTQuestion) -> (en: String, vie: String) {
        if let pref = answerPrefs.first(where: { $0.questionId == question.id }) {
            return (pref.answerEn, pref.answerVie)
        }
        return (question.answer, question.answerVie)
    }
}

struct CardFront: View{
    @Binding var zIndex: Double
    @Binding var degree: Double
    @Binding var isFlipped: Bool
    @Binding var questions: [CTQuestion]
    @Binding var qIndex: Int
    @Binding var isChangingCard: Bool
    let synthesizer: AVSpeechSynthesizer
    @EnvironmentObject var audioManager: AudioManager
    @Environment(\.modelContext) private var context
    @Query private var markedQuestions: [MarkedQuestion]
    @ObservedObject private var adManager = InterstitialAdManager.shared
    
    var body: some View{
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .stroke(.blue.opacity(0.5), lineWidth: 5)
                .fill(.blue.opacity(0.1))
            
            VStack{
                Text("Question \(questions[qIndex].id):")
                Text("\(questions[qIndex].question)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.vertical, 1)
                    .padding(.horizontal)
                Text(questions[qIndex].questionVie)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)
                
                
                HStack{
                    Spacer()
                    
                    //mark
                    Button(action: {
                        if let existingMark = markedQuestions.first(where: {$0.id == questions[qIndex].id}){
                            context.delete(existingMark)
                        }
                        else{
                            let newMark = MarkedQuestion(id: questions[qIndex].id)
                            context.insert(newMark)
                        }
                    }){
                        Image(systemName: markedQuestions.contains {$0.id == questions[qIndex].id} ? "bookmark.fill" : "bookmark")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 23)
                    }
                    .padding(.trailing)
                    
                    //voice
                    Button(action: {
                        synthesizer.stopSpeaking(at: .immediate)
                        let utterance = AVSpeechUtterance(string: questions[qIndex].question)
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
                .padding()
                
                Button(action: {
                    isChangingCard = false
                    synthesizer.stopSpeaking(at: .immediate)
                    isFlipped.toggle()
                }) {
                    Text("Lật Thẻ")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
            
        }
        .padding()
        .rotation3DEffect(Angle(degrees: isFlipped ? 90.0 : 0.0), axis: (x:0, y:1, z:0))
        .zIndex(isFlipped ? 0.0 : 1.0)
        .animation(isFlipped ? .linear : .linear.delay(0.4), value: isFlipped)
    }
}

struct CardBack: View{
    @Binding var zIndex: Double
    @Binding var degree: Double
    @Binding var isFlipped: Bool
    @Binding var questions: [CTQuestion]
    @Binding var qIndex: Int
    @Binding var isChangingCard: Bool
    let synthesizer: AVSpeechSynthesizer
    @EnvironmentObject var govCapManager: GovCapManager
    @EnvironmentObject var audioManager: AudioManager
    @Binding var showingZipPrompt: Bool
    @EnvironmentObject var userSetting: UserSetting
    @Environment(\.modelContext) private var context
    @Query private var markedQuestions: [MarkedQuestion]
    @Query private var answerPrefs: [UserAnswerPref]
    @ObservedObject private var adManager = InterstitialAdManager.shared
    
    var body: some View{
        VStack{
            ZStack{
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.blue.opacity(0.5), lineWidth: 5)
                    .fill(.blue.opacity(0.1))
                
                VStack{
                    if questions[qIndex].id == 20 || questions[qIndex].id == 23 || questions[qIndex].id == 43 || questions[qIndex].id == 44{
                        ServiceQuestions(
                            questionId: questions[qIndex].id,
                            showingZipPrompt: $showingZipPrompt,
                            govAndCap: govCapManager.govAndCap
                        )
                    }
                    else{
                        let pref = preferredAnswer(for: questions[qIndex])
                        Text("\(pref.en)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.vertical, 1)
                            .padding(.horizontal)
                        Text("\(pref.vie)")
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal)
                    }
                    
                    HStack{
                        Spacer()
                        
                        //mark
                        Button(action: {
                            if let existingMark = markedQuestions.first(where: {$0.id == questions[qIndex].id}){
                                context.delete(existingMark)
                            }
                            else{
                                let newMark = MarkedQuestion(id: questions[qIndex].id)
                                context.insert(newMark)
                            }
                        }){
                            Image(systemName: markedQuestions.contains {$0.id == questions[qIndex].id} ? "bookmark.fill" : "bookmark")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 23)
                        }
                        .padding(.trailing)
                        
                        //voice
                        Button(action: {
                            synthesizer.stopSpeaking(at: .immediate)
                            let questionId = questions[qIndex].id
                            if questionId == 20 || questionId == 23 || questionId == 43 || questionId == 44 {
                                var textToSpeak = ""
                                
                                if questionId == 20 {
                                    // Senator
                                    let senators = userSetting.legislators.filter { $0.type == "senator" }
                                    if !senators.isEmpty {
                                        let senatorNames = senators.map { "\($0.firstName) \($0.lastName)" }.joined(separator: ", ")
                                        textToSpeak = senatorNames
                                    }
                                } else if questionId == 23 {
                                    // Representative
                                    let representatives = userSetting.legislators.filter { $0.type == "representative" }
                                    if !representatives.isEmpty {
                                        let repNames = representatives.map { "\($0.firstName) \($0.lastName)" }.joined(separator: ", ")
                                        textToSpeak = repNames
                                    }
                                } else if questionId == 43 {
                                    // Governor
                                    let state = userSetting.state
                                    if let govCap = govCapManager.govAndCap.first(where: { $0.state == state }) {
                                        textToSpeak = govCap.gov
                                    }
                                } else if questionId == 44 {
                                    // Capital
                                    let state = userSetting.state
                                    if let govCap = govCapManager.govAndCap.first(where: { $0.state == state }) {
                                        textToSpeak = govCap.capital
                                    }
                                }
                                
                                // If no specific answer is available, use default answer
                                if textToSpeak.isEmpty {
                                    textToSpeak = preferredAnswer(for: questions[qIndex]).en
                                }
                                
                                let utterance = AVSpeechUtterance(string: textToSpeak)
                                utterance.voice = AVSpeechSynthesisVoice(identifier: audioManager.voiceIdentifier)
                                utterance.rate = audioManager.speechRate
                                synthesizer.speak(utterance)
                            } else {
                                // Regular questions
                                let utterance = AVSpeechUtterance(string: preferredAnswer(for: questions[qIndex]).en)
                                utterance.voice = AVSpeechSynthesisVoice(identifier: audioManager.voiceIdentifier)
                                utterance.rate = audioManager.speechRate
                                synthesizer.speak(utterance)
                            }
                        }){
                            Image(systemName: "speaker.wave.3")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 23)
                        }
                    }
                    .padding()
                    
                    Button(action: {
                        isChangingCard = false
                        synthesizer.stopSpeaking(at: .immediate)
                        isFlipped.toggle()
                    }) {
                        Text("Lật Thẻ")
                            .font(.title3)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .padding()
                
            }
            .padding()
            .rotation3DEffect(Angle(degrees: isFlipped ? 0.0 : -90.0), axis: (x:0, y:1, z:0))
            .zIndex(isFlipped ? 1.0 : 0.0)
            .animation(isFlipped ? .linear.delay(0.4) : .linear, value: isFlipped)
        }
        .sheet(isPresented: $showingZipPrompt) {
            CTZipInput()
                .environmentObject(userSetting)
        }
    }
    private func preferredAnswer(for question: CTQuestion) -> (en: String, vie: String) {
        if let pref = answerPrefs.first(where: { $0.questionId == question.id }) {
            return (pref.answerEn, pref.answerVie)
        }
        return (question.answer, question.answerVie)
    }
}

struct QuestionTypeView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var questionList: QuestionList
    @Binding var questions: [CTQuestion]
    @Binding var qIndex: Int
    @Binding var noMarkedQuestionsAlert: Bool
    @Binding var qType: String
    @State private var shouldShowAlertOnDismiss = false
    @Query private var markedQuestions: [MarkedQuestion]
    
    var body: some View {
        VStack {
            HStack{
                Spacer()
                
                Text("Chọn Trình Tự Câu Hỏi")
                    .padding(10)
                
                Spacer()
                
                Button(action:{
                    dismiss()
                }){
                    Image(systemName: "xmark")
                        .foregroundStyle(.gray)
                }
                
            }
            
            VStack(spacing: 20){
                // Handle sequential order
                Button(action: {
                    questions = questionList.questions
                    qIndex = 0
                    qType = "Thứ Tự"
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "list.number")
                        Text("Thứ Tự")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)
                
                // Handle random order
                Button(action: {
                    questions = questionList.questions.shuffled()
                    qIndex = 0
                    qType = "Ngẫu Nhiên"
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "shuffle")
                        Text("Ngẫu Nhiên")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)
                
                // Handle marked questions
                Button(action: {
                    let filteredQuestions = questionList.questions.filter { question in
                        markedQuestions.contains{$0.id == question.id}
                    }
                    
                    if !filteredQuestions.isEmpty {
                        questions = filteredQuestions
                        qIndex = 0
                        qType = "Đánh Dấu"
                    } else {
                        shouldShowAlertOnDismiss = true
                    }
                    dismiss()
                })
                {
                    HStack {
                        Image(systemName: "bookmark")
                        Text("Đánh Dấu")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)
            }
            Spacer()
        }
        .padding()
        .onDisappear {
            if shouldShowAlertOnDismiss {
                noMarkedQuestionsAlert = true
                shouldShowAlertOnDismiss = false
            }
        }
    }
}
