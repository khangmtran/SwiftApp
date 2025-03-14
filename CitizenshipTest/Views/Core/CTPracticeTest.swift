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
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var showResult: Bool = true
    
    var btnBack : some View { Button(action: {
        self.presentationMode.wrappedValue.dismiss()
    }) {
        HStack {
            Image(systemName: "lessthan")
                .foregroundStyle(.white)
            Text("Back")
                .foregroundStyle(.white)
        }
    }
    }
    
    
    var body: some View {
        VStack{
            if isLoading {
                ProgressView()
            }else if showResult{
                CTResultView(score: score, questions: tenQuestions)
            }
            else {
                GeometryReader { geo in
                    VStack {
                        PracticeQuestionView(tenQuestions: tenQuestions, qIndex: $qIndex)
                            .ignoresSafeArea()
                            .frame(height: geo.size.height / 2.5)
                        PracticeAnswerView(tenQuestions: tenQuestions, qIndex: $qIndex, showResult: $showResult, score: $score)
                    }
                }
            }
        }
        .onAppear {
            tenQuestions = Array(questionList.questions.shuffled().prefix(10))
            isLoading = false
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: btnBack)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar{
            ToolbarItem(placement: .principal){
                if isLoading{
                    ProgressView()
                }
                else{
                    Text("\(qIndex) of \(tenQuestions.count)")
                        .font(deviceManager.isTablet ? .title : .body)
                }
            }
        }
    }
}

struct CTResultView: View {
    let score: Int
    let questions: [CTQuestion]
    @State private var synthesizer = AVSpeechSynthesizer()
    @Environment(\.modelContext) private var context
    @Query private var markedQuestions: [MarkedQuestion]
    @EnvironmentObject var deviceManager: DeviceManager
    @Environment(\.presentationMode) var presentationMode
    
    // Add navigation state to control going back to home
    @State private var navigateToHome = false
    
    var body: some View {
        GeometryReader{geo in
            VStack {
                // Score circle
                ZStack {
                    Circle()
                        .fill(.blue.opacity(0.7))
                        .shadow(radius: 5)
                        .frame(width: geo.size.width/3)
                    
                    VStack {
                        Text("Score")
                            .font(deviceManager.isTablet ? .title : .headline)
                            .foregroundStyle(.white)
                        
                        Text("\(score) / \(questions.count)")
                            .font(deviceManager.isTablet ? .largeTitle : .title)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        
                        if score >= 6 {
                            Text("Passed!")
                                .font(deviceManager.isTablet ? .title : .headline)
                                .foregroundStyle(.white)
                        } else {
                            Text("Try again!")
                                .font(deviceManager.isTablet ? .title : .headline)
                                .foregroundStyle(.white)
                        }
                    }
                }
                .frame(height: geo.size.height/5)
                
                // Question list
                ScrollView {
                    ForEach(questions) { question in
                        HStack{
                            VStack(alignment: .leading) {
                                Text("Q\(question.id): \(question.question)")
                                    .font(deviceManager.isTablet ? .title3 : .body)
                                    .fontWeight(.medium)
                                
                                Text("A: \(question.answer)")
                                    .font(deviceManager.isTablet ? .body : .subheadline)
                                    .fontWeight(.regular)
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
                                .fill(Color.blue.opacity(0.1))
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
            VStack{
                ProgressView(value: Double(qIndex) / 10)
                    .padding()
                    .tint(.white)
                //               Image("")
                //                    .resizable()
                //                    .scaledToFit()
                //                    .frame(height: deviceManager.isTablet ? 50 : 25)
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
                            .foregroundStyle(.white)
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
                            .foregroundStyle(.white)
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
    @State var showZipInput: Bool = false
    @State var selectedAns: String = ""
    @State var isAns: Bool = false
    @State private var shuffledAnswers: [String] = []
    
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
                        }){
                            Text(ans)
                                .padding()
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .background(backgroundColor(for: ans, correctAns: getZipAnswer(tenQuestions[qIndex].id), selectedAns: selectedAns))
                                .padding()
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
                        if selectedAns == tenQuestions[qIndex].answer{score += 1}
                        if qIndex == 0{
                            isAns = false
                            showResult = true
                        }
                    }){
                        Text(ans)
                            .padding()
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .background(backgroundColor(for: ans, correctAns: tenQuestions[qIndex].answer, selectedAns: selectedAns))
                            .padding()
                    }
                    .disabled(isAns)
                }
            }
            
            //show next button when answered
            if isAns{
                Button(action: {
                    qIndex += 1
                    isAns = false
                }){
                    Image(systemName: "greaterthan.circle.fill")
                        .resizable()
                        .scaledToFit()
                }
            }
            
        }
        .sheet(isPresented: $showZipInput) {
            CTZipInput()
                .environmentObject(userSetting)
                .environmentObject(deviceManager)
        }
        .onAppear {
            updateShuffledAnswers()
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

struct ResultView: View {
    var body: some View {
        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Hello, world!@*/Text("Hello, world!")/*@END_MENU_TOKEN@*/
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
