//
//  CTPracticeTest.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 3/12/25.
//

import SwiftUI
import AVFoundation
import SwiftData

struct CTPracticeTest: View {
    @EnvironmentObject var wrongAnswer: WrongAnswer
    @EnvironmentObject var questionList: QuestionList
    @EnvironmentObject var deviceManager: DeviceManager
    @State private var qIndex: Int = 0
    @State private var score: Int = 0
    @State private var tenQuestions: [CTQuestion] = []
    @State private var isLoading: Bool = true
    @State private var showResult: Bool = false
    @State private var incorrQ: [String] = []
    @State private var userAns: [Bool] = []
    
    var body: some View {
        VStack{
            if isLoading {
                ProgressView()
            }else if showResult {
                CTResultView(
                    questions: $tenQuestions,
                    showResult: $showResult,
                    qIndex: $qIndex,
                    score: $score,
                    userAns: $userAns,
                    incorrQ: $incorrQ
                )
            }
            else {
                GeometryReader { geo in
                    VStack {
                        PracticeQuestionView(tenQuestions: tenQuestions, qIndex: $qIndex)
                            .frame(height: geo.size.height / 3)
                        PracticeAnswerView(tenQuestions: tenQuestions, qIndex: $qIndex, showResult: $showResult, score: $score, incorrQ: $incorrQ, userAns: $userAns)
                    }
                }
            }
        }
        .onAppear {
            if tenQuestions.isEmpty {
                tenQuestions = Array(questionList.questions.shuffled().prefix(10))
            }
            isLoading = false
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
    @State private var synthesizer = AVSpeechSynthesizer()
    @EnvironmentObject var deviceManager: DeviceManager
    @EnvironmentObject var questionList: QuestionList
    @Environment(\.modelContext) private var context
    @Query private var markedQuestions: [MarkedQuestion]
    
    var body: some View {
        GeometryReader{geo in
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
                
                if score >= 6 {
                    Text("Chúc mừng bạn đã vượt qua được bài kiểm tra")
                        .font(deviceManager.isTablet ? .title : .headline)
                        .padding()
                } else {
                    Text("Bạn cần làm đúng ít nhất 6 câu để vượt qua bài kiểm tra. Hãy cố gắng thêm nhé!")
                        .multilineTextAlignment(.center)
                        .font(deviceManager.isTablet ? .title : .headline)
                        .padding()
                }
                Button(action: {
                    // Reset the test state
                    questions = Array(questionList.questions.shuffled().prefix(10))
                    qIndex = 0
                    score = 0
                    userAns = []
                    incorrQ = []
                    showResult = false
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


struct PracticeQuestionView: View{
    var tenQuestions: [CTQuestion]
    @Binding var qIndex: Int
    @State private var synthesizer = AVSpeechSynthesizer()
    @EnvironmentObject var deviceManager: DeviceManager
    @Environment(\.modelContext) private var context
    @Query private var markedQuestions: [MarkedQuestion]
    
    var body: some View{
        ZStack{
            RoundedRectangle(cornerRadius: 0)
                .fill(.blue.opacity(0.5))
                .ignoresSafeArea()
            VStack{
                Text("\(qIndex) of \(tenQuestions.count)")
                    .font(deviceManager.isTablet ? .title : .body)
                ProgressView(value: Double(qIndex) / 10)
                    .padding()
                    .tint(.white)
                Text("\(tenQuestions[qIndex].question)")
                    .padding()
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
                            .frame(height: deviceManager.isTablet ? 50 : 25)
                    }
                    .padding(.trailing)
                    
                    // Voice button
                    Button(action: {
                        synthesizer.stopSpeaking(at: .immediate)
                        let utterance = AVSpeechUtterance(string: tenQuestions[qIndex].question)
                        utterance.voice = AVSpeechSynthesisVoice()
                        utterance.rate = 0.3
                        synthesizer.speak(utterance)
                    }){
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

struct PracticeAnswerView: View{
    @EnvironmentObject var wrongAnswer: WrongAnswer
    @EnvironmentObject var userSetting: UserSetting
    @EnvironmentObject var deviceManager: DeviceManager
    @EnvironmentObject var govCapManager: GovCapManager
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
    @State private var answersInitialized = false
    
    var body: some View{
        
        VStack{
            //handle zip questions
            if tenQuestions[qIndex].id == 20 || tenQuestions[qIndex].id == 23 ||
                tenQuestions[qIndex].id == 43 || tenQuestions[qIndex].id == 44 {
                if userSetting.zipCode.isEmpty {
                    Button(action: {
                        showZipInput = true
                    }){
                        Text("Nhap ZIP Code de thay cau tra loi")
                            .padding()
                            .foregroundStyle(.white)
                            .background(.blue)
                            .cornerRadius(10)
                    }
                }
                else{
                    ForEach(shuffledAnswers, id: \.self) { ans in
                        Button(action: {
                            selectedAns = ans
                            isAns = true
                            if selectedAns == tenQuestions[qIndex].answer{
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
                                showResult = true
                            }
                        }){
                            Text(ans)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding()
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .background(backgroundColor(for: ans, correctAns: getZipAnswer(tenQuestions[qIndex].id), selectedAns: selectedAns))
                                .cornerRadius(10)
                                .padding(.horizontal)
                                .padding(.vertical, 10)
                        }
                    }
                }
            }
            //non zip questions
            else{
                ForEach(shuffledAnswers, id: \.self) { ans in
                    Button(action: {
                        selectedAns = ans
                        isAns = true
                        if selectedAns == tenQuestions[qIndex].answer{
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
                            showResult = true
                        }
                    }){
                        Text(ans)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding()
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .background(backgroundColor(for: ans, correctAns: tenQuestions[qIndex].answer, selectedAns: selectedAns))
                            .cornerRadius(10)
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                    }
                    .disabled(isAns)
                }
            }
            
            Spacer()
            
            //show next button when answered
            if isAns{
                Button(action: {
                    qIndex += 1
                    isAns = false
                }){
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
        .onChange(of: qIndex){
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
            shuffledAnswers = [tenQuestions[qIndex].answer, correspondAns.firstIncorrect, correspondAns.secondIncorrect, correspondAns.thirdIncorrect].shuffled()
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
    CTPracticeTest()
        .environmentObject(QuestionList())
        .environmentObject(WrongAnswer())
        .environmentObject(UserSetting())
        .environmentObject(DeviceManager())
        .environmentObject(GovCapManager())
}
