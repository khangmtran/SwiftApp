//
//  CTLearnQuestions.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 1/24/25.
//

import SwiftUI

struct CTLearnQuestions: View {
    @EnvironmentObject var selectedPart : SelectedPart
    @State private var questions: [CTQuestion] = []
    @State private var qIndex = -1
    private let parts = ["Phần 1", "Phần 2", "Phần 3", "Phần 4", "Phần 5", "Phần 6", "Phần 7", "Phần 8"]
    
    let partToType = [
        "Phần 1": "CA",
        "Phần 2": "PVP",
        "Phần 3": "US",
        "Phần 4": "LGS",
        "Phần 5": "DA",
        "Phần 6": "WCCR",
        "Phần 7": "BN",
        "Phần 8": "HS"
    ]
    
    var filteredQuestion: [CTQuestion]{
        questions.filter{$0.type == partToType[selectedPart.partChosen]}
    }
    
    var body: some View{
        //Show Guide
        if qIndex == -1{
            VStack(spacing: 20){//outer Vs
                CTGuide(qIndex: $qIndex)
                //hstack contains prev and next arrows
                NavButton(qIndex: $qIndex, qCount: filteredQuestion.count - 1)
            }//end outerV
            .onAppear(){
                questions = CTDataLoader().loadQuestions()
            }
        }//end show guide
        else{
            //Big Vstack
            ZStack{
                VStack{
                    //1. VStack contains keyword
                    VStack(alignment: .leading){
                        Text("Từ khóa cho phần 1:")
                        Text("Constituion - Hiến Pháp")
                        Text("Amendment - Tu Chánh Án")
                        Text("Lưu ý: Những câu có dấu * ở cuối câu là những câu hỏi thường gặp trong bài thi")
                    }//.1
                    .padding()
                    .frame(width: 270)
                    .border(.gray, width: 3)
                    .padding(.trailing, 110)
                    .padding()
                    
                    
                    //2. Vstack contains question
                    if !filteredQuestion.isEmpty{
                        GeometryReader{ geometry in
                            VStack{
                                //question section
                                QuestionView(question: filteredQuestion[qIndex].question,
                                              vieQuestion: filteredQuestion[qIndex].questionVie,
                                              height: geometry.size.height * 0.35)
                                
                                //hstack contains prev and next arrows
                                NavButton(qIndex: $qIndex, qCount: filteredQuestion.count - 1)
                                
                                //vstack of answer
                                AnswerView(ans: filteredQuestion[qIndex].answer,
                                           vieAns: filteredQuestion[qIndex].answerVie,
                                           height: geometry.size.height * 0.35)
                                
                            }//.2
                            //.border(.gray, width: 3)
                            .frame(maxHeight: .infinity)
                        }
                    }
                    
                }//Big Vstack
            }
            .onAppear(){
                questions = CTDataLoader().loadQuestions()
            }
            .navigationBarTitleDisplayMode(.inline)
            
            //toolbar
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Menu {
                        ForEach(parts.filter { $0 != selectedPart.partChosen }, id: \.self) { part in
                            Button(part) {
                                selectedPart.partChosen = part
                                qIndex = -1
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedPart.partChosen)
                            Image(systemName: "chevron.down")
                        }
                        .frame(width: 100, height: 35)
                        .border(.gray, width: 3)
                    }
                }
            }//toolbar

        }
    }
}

#Preview {
    NavigationView{
        CTLearnQuestions()
            .environmentObject(SelectedPart())
    }
}

struct NavButton: View {
    
    @Binding var qIndex: Int
    let qCount: Int
    
    var body: some View {
        HStack{
            Button(action: prevQuestion){
                Image(systemName: "lessthan")
                    .resizable()
                    .scaledToFit()
            }
            .disabled(qIndex == -1)
            
            Spacer()
            
            Button(action: nextQuestion){
                Image(systemName: "greaterthan")
                    .resizable()
                    .scaledToFit()
            }
            .disabled(qIndex == qCount)
        }//hstack contains prv and nxt arrows
        .frame(height: 30)
        .padding()
    }
    
    private func nextQuestion(){
        withAnimation{
            if qIndex < qCount {
                qIndex += 1
            }
        }
    }
    
    private func prevQuestion(){
        withAnimation{
            if qIndex > -1{
                qIndex -= 1
            }
        }
    }
}

struct QuestionView: View {
    var question: String
    var vieQuestion: String
    let height: CGFloat
    
    var body: some View {
        VStack(spacing: 10){
            Text("Câu Hỏi:")
            Text(question)
                .font(.system(size: 25, weight: .bold))
                .multilineTextAlignment(.center)
            Text(vieQuestion)
                .font(.system(size: 20, weight: .light))
                .multilineTextAlignment(.center)
        }//end question
        .frame(height: height)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 2)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.blue, lineWidth: 2)
        )
        .padding()
    }
}

struct AnswerView: View {
    var ans: String
    var vieAns: String
    let height: CGFloat
    
    var body: some View {
        VStack(spacing: 10){
            Text("Trả Lời:")
            Text(ans)
                .font(.system(size: 25, weight: .bold))
                .multilineTextAlignment(.center)
            Text(vieAns)
                .font(.system(size: 20, weight: .light))
                .multilineTextAlignment(.center)
        }//vstack of answer
        .frame(height: height)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 2)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.blue, lineWidth: 2)
        )
        .padding()
    }
}
