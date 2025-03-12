//
//  CTPracticeTest.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 3/12/25.
//

import SwiftUI

struct CTPracticeTest: View {
    @EnvironmentObject var questionList: QuestionList
    @State private var qIndex: Int = 0
    
    var body: some View {
        let tenQuestions = Array(questionList.questions.shuffled().prefix(10))
        GeometryReader{ geo in
            VStack{
                //Question View
                PracticeQuestionView(tenQuestions: tenQuestions, qIndex: $qIndex)
                    .ignoresSafeArea()
                    .frame(height: geo.size.height / 2)
                
                
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
    var body: some View{
        VStack{
            
        }
    }
}

#Preview {
    CTPracticeTest()
        .environmentObject(QuestionList())
}
