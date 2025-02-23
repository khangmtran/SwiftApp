//
//  CTLearnQuestions.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 1/24/25.
//

import SwiftUI
import AVFoundation

struct CTLearnQuestions: View {
    @EnvironmentObject var dvice : DeviceManager
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
            VStack{//outer Vs
                CTGuide(qIndex: $qIndex)
            }//end outerV
            .onAppear(){
                questions = CTDataLoader().loadQuestions()
            }
            .safeAreaInset(edge: .bottom) {
                NavButton(qIndex: $qIndex, qCount: filteredQuestion.count - 1)
                    .padding()
                    .background(Color.white)
            }
        }//end show guide
        else{
            
            ScrollView{
                
                //1. VStack contains keyword
                VStack{
                    Text(CTPartMessages().partMessages[selectedPart.partChosen] ?? "")
                        .font(dvice.isTablet ? .title : .body)
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
                        
                    }//.2
                }
            }
            
            .onAppear(){
                questions = CTDataLoader().loadQuestions()
            }
            .safeAreaInset(edge: .bottom) {
                NavButton(qIndex: $qIndex, qCount: filteredQuestion.count - 1)
                    .padding()
                    .background(Color.white)
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
                                .font(dvice.isTablet ? .largeTitle : .title3)
                            Image(systemName: "chevron.down")
                                .resizable()
                                .scaledToFit()
                                .frame(height: dvice.isTablet ? 20 : 10)
                        }
                        .padding(10)
                        .border(.gray, width: dvice.isTablet ? 2 : 1)
                    }
                }
            }//toolbar
            
        }
    }
}

#Preview {
    NavigationStack{
        CTLearnQuestions()
            .environmentObject(SelectedPart())
            .environmentObject(DeviceManager())
    }
}

struct NavButton: View {
    @EnvironmentObject var dvice: DeviceManager
    @Binding var qIndex: Int
    let qCount: Int
    
    var body: some View {
        HStack(){
            Button(action: prevQuestion){
                Text("Tro Ve")
                    .font(dvice.isTablet ? .largeTitle : .title3)
            }
            .padding()
            .foregroundStyle(.white)
            .background(.blue)
            .cornerRadius(10)
            .disabled(qIndex == -1)
            
            Spacer()
            
            Button(action: nextQuestion){
                Text("Tiep Theo")
                    .font(dvice.isTablet ? .largeTitle : .title3)
            }
            .padding()
            .foregroundStyle(.white)
            .background(.blue)
            .cornerRadius(10)
            .disabled(qIndex == qCount)
        }//hstack contains prv and nxt arrows
        
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
    @EnvironmentObject var dvice: DeviceManager
    
    var body: some View {
        VStack{
            VStack{
                Text("\(qId). \(question)")
                    .font(dvice.isTablet ? .largeTitle : .title3)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(vieQuestion)
                    .font(dvice.isTablet ? .title : .body)
                    .fontWeight(.thin)
                    .multilineTextAlignment(.center)
                
                (Text("Từ trọng tâm:")
                    .underline() +
                 Text(" \(learn) - là những từ bạn cần nhớ để nhận diện câu hỏi này"))
                .font(dvice.isTablet ? .title : .body)
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
                        .resizable()
                        .scaledToFit()
                        .frame(height: dvice.isTablet ? 30 : 20)
                }
            }
            
        }//end question
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
    @EnvironmentObject var dvice: DeviceManager
    
    var body: some View {
        VStack(){
            
            VStack{
                Text("Trả Lời:")
                    .font(dvice.isTablet ? .title : .body)
                Text(ans)
                    .font(dvice.isTablet ? .largeTitle : .title3)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.top, 1)
                Text(vieAns)
                    .font(dvice.isTablet ? .title : .body)
                    .fontWeight(.thin)
                    .multilineTextAlignment(.center)
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
                        .resizable()
                        .scaledToFit()
                        .frame(height: dvice.isTablet ? 30 : 20)
                }
            }
        }//vstack of answer
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.blue, lineWidth: 1)
        )
        .padding(.horizontal)
    }
}
