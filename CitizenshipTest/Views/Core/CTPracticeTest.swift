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
    
    var body: some View {
        //let tenQuestions = Array(questionList.questions.shuffled().prefix(10))
        let tenQuestions = questionList.questions.filter {$0.id == 23}
        GeometryReader{ geo in
            VStack{
                //Question View
                PracticeQuestionView(tenQuestions: tenQuestions, qIndex: $qIndex)
                    .ignoresSafeArea()
                    .frame(height: geo.size.height / 2)
                PracticeAnswerView(tenQuestions: tenQuestions, qIndex: $qIndex)
                
                
            }
        }
    }
}

struct PracticeQuestionView: View{
    var tenQuestions: [CTQuestion]
    @Binding var qIndex: Int
    
    var body: some View{
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .fill(.blue.opacity(0.5))
            Text("\(tenQuestions[qIndex].question)")
                .padding()
        }
    }
}

struct PracticeAnswerView: View{
    @EnvironmentObject var wrongAnswer: WrongAnswer

    var tenQuestions: [CTQuestion]
    @Binding var qIndex: Int
    @State var showZipInput: Bool = false
    
    
    var body: some View{
        
        let correspondAns = wrongAnswer.wrongAns.first { $0.id == tenQuestions[qIndex].id }!
        let shuffledAns = [tenQuestions[qIndex].answer, correspondAns.firstIncorrect, correspondAns.secondIncorrect, correspondAns.thirdIncorrect].shuffled()
        
        if tenQuestions[qIndex].answer == ""{
            VStack{
                Button(action: {
                    showZipInput = true
                }){
                    Text("Nhap ZIP Code de thay cau tra loi")
                }
            }
            .sheet(isPresented: $showZipInput){
                CTZipInput()
                    .environmentObject(UserSetting())
                    .environmentObject(DeviceManager())
            }
        }
            
        
        if tenQuestions[qIndex].answer != ""{
            VStack{
                ForEach(shuffledAns, id: \.self) { ans in
                    Button(action: {
                        print("?")
                    }){
                        Text(ans)
                            .padding()
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .background(.blue.opacity(0.1))
                            .padding(.vertical)
                    }
                }
            }
        }
        
    }
}

#Preview {
    CTPracticeTest()
        .environmentObject(QuestionList())
        .environmentObject(WrongAnswer())
}
