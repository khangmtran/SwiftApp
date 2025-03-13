//
//  CTPracticeTest.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 3/12/25.
//

import SwiftUI

struct CTPracticeTest: View {
    @EnvironmentObject var wrongAnswer: WrongAnswer
    @EnvironmentObject var questionList: QuestionList
    @State private var qIndex: Int = 0
    @State private var score: Int = 0
    
    var body: some View {
        let tenQuestions = Array(questionList.questions.shuffled().prefix(10))
        GeometryReader{ geo in
            VStack{
                PracticeQuestionView(tenQuestions: tenQuestions, qIndex: $qIndex)
                    .ignoresSafeArea()
                    .frame(height: geo.size.height / 2.5)
                PracticeAnswerView(tenQuestions: tenQuestions, qIndex: $qIndex)
                
            }
        }
    }
}

struct PracticeButton: View{
    var body: some View{
        HStack{
            
        }
    }
}

struct PracticeQuestionView: View{
    var tenQuestions: [CTQuestion]
    @Binding var qIndex: Int
    
    var body: some View{
        ZStack{
            RoundedRectangle(cornerRadius: 0)
                .fill(.blue.opacity(0.5))
            Text("\(tenQuestions[qIndex].question)")
                .padding()
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

#Preview {
    CTPracticeTest()
        .environmentObject(QuestionList())
        .environmentObject(WrongAnswer())
        .environmentObject(UserSetting())
        .environmentObject(DeviceManager())
        .environmentObject(GovCapManager())
}
