//
//  CTFlashCard.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 2/27/25.
//

import SwiftUI
import AVFoundation
import SwiftData

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
    @EnvironmentObject var deviceManager: DeviceManager
    @EnvironmentObject var questionList: QuestionList
    @EnvironmentObject var govCapManager: GovCapManager
    @AppStorage("flashCardIndex") private var savedIndex: Int = 0
    
    
    var body: some View{
        VStack{
            HStack(alignment: .center){
                Text("Thẻ \(qIndex + 1) / \(questions.count)")
                    .font(deviceManager.isTablet ? .title3 : .body)
                Spacer()
                Button(action: {
                    showJumpPrompt = true
                }) {
                    HStack {
                        Text("Tìm Thẻ")
                            .font(deviceManager.isTablet ? .title3 : .body)
                    }
                    .foregroundColor(.blue)
                }
                Spacer()
                Button(action:{
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
            questions = questionList.questions
            if !questions.isEmpty{
                if savedIndex >= 0 && savedIndex < questions.count {
                    qIndex = savedIndex
                } else {
                    qIndex = 0
                    savedIndex = 0
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            NavButtonsFC(qIndex: $qIndex, questions: questions)
                .padding()
                .background(Color.white)
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
    @EnvironmentObject var deviceManager: DeviceManager
    
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
                .font(deviceManager.isTablet ? .title3 : .body)
                
                Spacer()
                
                Text("Chọn thẻ")
                    .font(deviceManager.isTablet ? .title2 : .headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Đi đến") {
                    qIndex = selectedCardNumber - 1
                    dismiss()
                }
                .font(deviceManager.isTablet ? .title3 : .body)
                .foregroundColor(.blue)
            }
            .padding(.top)
            .padding(.horizontal)
            
            Picker("Thẻ số", selection: $selectedCardNumber) {
                ForEach(1...totalCards, id: \.self) { num in
                    Text("\(num)")
                        .font(deviceManager.isTablet ? .title : .title3)
                }
            }
            .pickerStyle(.wheel)
        }
    }
}

struct NavButtonsFC: View{
    @Binding var qIndex: Int
    let questions: [CTQuestion]
    @EnvironmentObject var deviceManager: DeviceManager
    @AppStorage("flashCardIndex") private var savedIndex: Int = 0

    var body: some View {
        HStack(){
            Button(action: prevQuestion){
                Text("Trở Về")
                    .font(deviceManager.isTablet ? .title3 : .body)
            }
            .padding()
            .foregroundStyle(.white)
            .background(.blue)
            .cornerRadius(10)
            
            Spacer()
            
            Button(action: nextQuestion){
                Text("Tiếp Theo")
                    .font(deviceManager.isTablet ? .title3 : .body)
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
            savedIndex += 1
        }
        else if qIndex == questions.count - 1{
            qIndex = 0
            savedIndex = 0
        }
    }
    
    private func prevQuestion(){
        if qIndex > 0{
            qIndex -= 1
            savedIndex -= 1
        }
        else if qIndex == 0{
            qIndex = questions.count - 1
            savedIndex = questions.count - 1
        }
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
    @EnvironmentObject var deviceManager: DeviceManager
    @Environment(\.modelContext) private var context
    @Query private var markedQuestions: [MarkedQuestion]
    
    var body: some View{
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .stroke(.blue.opacity(0.5), lineWidth: 5)
                .fill(.blue.opacity(0.1))
            
            VStack{
                Text("Question \(questions[qIndex].id):")
                    .font(deviceManager.isTablet ? .title3 : .body)
                Text("\(questions[qIndex].question)")
                    .font(deviceManager.isTablet ? .title2 : .title3)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.vertical, 1)
                    .padding(.horizontal)
                Text(questions[qIndex].questionVie)
                    .font(deviceManager.isTablet ? .title3 : .body)
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
                            .frame(height: deviceManager.isTablet ? 50 : 23)
                    }
                    .padding(.trailing)
                    
                    //voice
                    Button(action: {
                        synthesizer.stopSpeaking(at: .immediate)
                        let utterance = AVSpeechUtterance(string: questions[qIndex].question)
                        utterance.voice = AVSpeechSynthesisVoice()
                        utterance.rate = 0.3
                        synthesizer.speak(utterance)
                    }){
                        Image(systemName: "speaker.wave.3")
                            .resizable()
                            .scaledToFit()
                            .frame(height: deviceManager.isTablet ? 50 : 23)
                    }
                }
                .padding()
                
                Button(action: {
                    isChangingCard = false
                    isFlipped.toggle()
                }) {
                    Text("Lật Thẻ")
                        .font(deviceManager.isTablet ? .title3 : .body)
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
    @EnvironmentObject var deviceManager: DeviceManager
    @EnvironmentObject var govCapManager: GovCapManager
    @Binding var showingZipPrompt: Bool
    @EnvironmentObject var userSetting: UserSetting
    @Environment(\.modelContext) private var context
    @Query private var markedQuestions: [MarkedQuestion]
    
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
                        Text("\(questions[qIndex].answer)")
                            .font(deviceManager.isTablet ? .title2 : .title3)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.vertical, 1)
                            .padding(.horizontal)
                        Text("\(questions[qIndex].answerVie)")
                            .font(deviceManager.isTablet ? .title3 : .body)
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
                                .frame(height: deviceManager.isTablet ? 50 : 23)
                        }
                        .padding(.trailing)
                        
                        //voice
                        Button(action: {
                            synthesizer.stopSpeaking(at: .immediate)
                            let utterance = AVSpeechUtterance(string: questions[qIndex].answer)
                            utterance.voice = AVSpeechSynthesisVoice()
                            utterance.rate = 0.3
                            synthesizer.speak(utterance)
                        }){
                            Image(systemName: "speaker.wave.3")
                                .resizable()
                                .scaledToFit()
                                .frame(height: deviceManager.isTablet ? 50 : 23)
                        }
                    }
                    .padding()
                    
                    Button(action: {
                        isChangingCard = false
                        isFlipped.toggle()
                    }) {
                        Text("Lật Thẻ")
                            .font(deviceManager.isTablet ? .title2 : .title3)
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
                .environmentObject(deviceManager)
        }
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
    @AppStorage("flashCardIndex") private var savedIndex: Int = 0

    var body: some View {
        VStack {
            Button(action:{
                dismiss()
            }){
                Image(systemName: "xmark")
                    .foregroundStyle(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            
            Text("Chọn Trình Tự Câu Hỏi")
                .padding(10)
            
            VStack(spacing: 20){
                // Handle sequential order
                Button(action: {
                    questions = questionList.questions
                    qIndex = 0
                    savedIndex = 0
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
                    savedIndex = 0
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
                        savedIndex = 0
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

#Preview{
    CTFlashCard()
        .environmentObject(DeviceManager())
        .environmentObject(UserSetting())
        .environmentObject(QuestionList())
        .environmentObject(GovCapManager())
}
