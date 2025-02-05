//
//  CTLearnQuestions.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 1/24/25.
//

import SwiftUI
import AVFoundation

struct CTLearnQuestions: View {
    @State private var synthesizer = AVSpeechSynthesizer()
    @EnvironmentObject var selectedPart : SelectedPart
    @State private var questions: [CTQuestion] = []
    @State private var qIndex = -1
    private let parts = ["Phần 1", "Phần 2", "Phần 3", "Phần 4", "Phần 5", "Phần 6", "Phần 7", "Phần 8", "Phần 9"]
    
    let partToType = [
        "Phần 1": "CA",
        "Phần 2": "PVP",
        "Phần 3": "US",
        "Phần 4": "LGS",
        "Phần 5": "DA",
        "Phần 6": "WCCR",
        "Phần 7": "BN",
        "Phần 8": "HS",
        "Phần 9": "CL"
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
            VStack{
                //1. VStack contains keyword
                VStack{
                    Text(CTPartMessages().partMessages[selectedPart.partChosen] ?? "")
                        .multilineTextAlignment(.center)
                }//.1
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.blue, lineWidth: 1)
                )
                .padding()
                
                
                //2. Vstack contains question
                if !filteredQuestion.isEmpty{
            
                        VStack{
                            //question section
                            QuestionView(question: filteredQuestion[qIndex].question,
                                         vieQuestion: filteredQuestion[qIndex].questionVie,
                                         qId: filteredQuestion[qIndex].id,
                                         learn: filteredQuestion[qIndex].learn,
                                         synthesizer: synthesizer)
                            
                            //vstack of answer
                            AnswerView(ans: filteredQuestion[qIndex].answer,
                                       vieAns: filteredQuestion[qIndex].answerVie,
                                       learn: filteredQuestion[qIndex].learn,
                                       synthesizer: synthesizer)
                            
                            Spacer()
                            
                            //hstack contains prev and next arrows
                            NavButton(qIndex: $qIndex, qCount: filteredQuestion.count - 1)
                        }//.2
               
                }
                Spacer()
            }//Big Vstack
            
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
        HStack(spacing: 100){
            Button(action: prevQuestion){
                Image(systemName: "lessthan")
                    .resizable()
                    .scaledToFit()
            }
            .disabled(qIndex == -1)
            
            //Spacer()
            
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
    var qId: Int
    var learn: String
    var synthesizer: AVSpeechSynthesizer

    
    var body: some View {
        VStack(spacing: 5){
            
            VStack{
                Text("\(qId). \(question)")
                    .font(.system(size: 20, weight: .bold))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                Text(vieQuestion)
                    .font(.system(size: 20, weight: .thin))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                (Text("Từ trọng tâm:")
                    .underline() +
                 Text(" \(learn) - là những từ bạn cần nhớ để nhận diện câu hỏi này"))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical)
            }
            
            HStack{
                Spacer()
                Button(action: {
                    synthesizer.stopSpeaking(at: .immediate)
                    let utterance = AVSpeechUtterance(string: question)
                    utterance.voice = AVSpeechSynthesisVoice()
                    utterance.rate = 0.3
                    synthesizer.speak(utterance)
                }){
                    Image(systemName: "speaker.wave.3")
                }
            }
            
        }//end question
        .frame(maxWidth: .infinity)
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.blue, lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

struct AnswerView: View {
    var ans: String
    var vieAns: String
    var learn: String
    var synthesizer: AVSpeechSynthesizer
    
    var body: some View {
        VStack(){
            
            VStack{
                Text("Trả Lời:")
                Text(ans)
                    .font(.system(size: 20, weight: .bold))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 1)
                Text(vieAns)
                    .font(.system(size: 20, weight: .thin))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom)
            }
            
            HStack{
                Spacer()
                Button(action: {
                    synthesizer.stopSpeaking(at: .immediate)
                    let utterance = AVSpeechUtterance(string: ans)
                    utterance.voice = AVSpeechSynthesisVoice()
                    utterance.rate = 0.3
                    synthesizer.speak(utterance)
                }){
                    Image(systemName: "speaker.wave.3")
                }
            }
        }//vstack of answer
        .frame(maxWidth: .infinity)
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.blue, lineWidth: 1)
        )
        .padding(.horizontal)
    }
}
