//
//  CTLearnQuestions.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 1/24/25.
//

import SwiftUI
import AVFoundation
import SwiftData

struct CTLearnQuestions: View {
    @EnvironmentObject var userSetting: UserSetting
    @EnvironmentObject var deviceManager: DeviceManager
    @EnvironmentObject var selectedPart: SelectedPart
    @EnvironmentObject var questionList: QuestionList
    @EnvironmentObject var govCapManager: GovCapManager
    @State private var synthesizer = AVSpeechSynthesizer()
    @State private var qIndex = 0
    @State private var questionCount = 0
    private let parts = ["Phần 1", "Phần 2", "Phần 3", "Phần 4", "Phần 5", "Phần 6", "Phần 7", "Phần 8"]
    
    let partToType = [
        "Phần 1": "LD",
        "Phần 2": "CA",
        "Phần 3": "US",
        "Phần 4": "WCCR",
        "Phần 5": "PVP",
        "Phần 6": "GSA",
        "Phần 7": "SND",
        "Phần 8": "CL"
    ]
    
    var filteredQuestion: [CTQuestion]{
        questionList.questions.filter{$0.type == partToType[selectedPart.partChosen]}
    }
    
    var body: some View{
        //Show Guide
        if qIndex == -1{
            VStack{//outer Vs
                CTGuide(qIndex: $qIndex)
            }//end outerV
            .safeAreaInset(edge: .bottom) {
                NavButton(qIndex: $qIndex, qCount: $questionCount, totalQuestionsIndex: filteredQuestion.count - 1)
                    .padding()
            }
        }//end show guide
        else{
            
            ScrollView{
                //1. VStack contains keyword
                VStack{
                    Text(CTPartMessages().partMessages[selectedPart.partChosen] ?? "")
                        .font(deviceManager.isTablet ? .title : .body)
                        .multilineTextAlignment(.center)
                }//.1
                .padding()
                .frame(maxWidth: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.blue, lineWidth: 1)
                        .fill(.blue.opacity(0.1))
                )
                .background(.white)
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
                        AnswerView(qId: filteredQuestion[qIndex].id,
                                   ans: filteredQuestion[qIndex].answer,
                                   vieAns: filteredQuestion[qIndex].answerVie,
                                   learn: filteredQuestion[qIndex].learn,
                                   synthesizer: synthesizer)
                        
                    }//.2
                }
            }
            .safeAreaInset(edge: .bottom) {
                NavButton(qIndex: $qIndex, qCount: $questionCount, totalQuestionsIndex: filteredQuestion.count - 1)
                    .padding()
            }
            
            .navigationBarTitleDisplayMode(.inline)
            //toolbar
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing){
                    Text("\(questionCount) / \(filteredQuestion.count)")
                        .font(deviceManager.isTablet ? .title : .body)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Menu {
                        ForEach(parts.filter { $0 != selectedPart.partChosen }, id: \.self) { part in
                            Button(part) {
                                selectedPart.partChosen = part
                                qIndex = -1
                                questionCount = 0
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedPart.partChosen)
                                .font(deviceManager.isTablet ? .largeTitle : .title3)
                            Image(systemName: "chevron.down")
                                .resizable()
                                .scaledToFit()
                                .frame(height: deviceManager.isTablet ? 20 : 10)
                        }
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
            .environmentObject(UserSetting())
            .environmentObject(QuestionList())
            .environmentObject(GovCapManager())
    }
}

struct NavButton: View {
    @EnvironmentObject var deviceManager: DeviceManager
    @Binding var qIndex: Int
    @Binding var qCount: Int
    let totalQuestionsIndex: Int
    
    var body: some View {
        HStack(){
            Button(action: prevQuestion){
                Text("Tro Ve")
                    .font(deviceManager.isTablet ? .largeTitle : .title3)
            }
            .padding()
            .foregroundStyle(.white)
            .background(.blue)
            .cornerRadius(10)
            
            
            Spacer()
            
            Button(action: nextQuestion){
                Text("Tiep Theo")
                    .font(deviceManager.isTablet ? .largeTitle : .title3)
            }
            .padding()
            .foregroundStyle(.white)
            .background(.blue)
            .cornerRadius(10)
            
        }//hstack contains prv and nxt arrows
    }
    
    private func nextQuestion(){
        withAnimation{
            if qIndex < totalQuestionsIndex {
                qIndex += 1
                qCount += 1
            }
            else if qIndex == totalQuestionsIndex{
                qIndex = -1
                qCount = 0
            }
        }
    }
    
    private func prevQuestion(){
        withAnimation{
            if qIndex > -1{
                qIndex -= 1
                qCount -= 1
            }
            else if qIndex == -1{
                qIndex = totalQuestionsIndex
                qCount = totalQuestionsIndex + 1
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
    @EnvironmentObject var deviceManager: DeviceManager
    @Environment(\.modelContext) private var context
    @Query private var markedQuestions: [MarkedQuestion]
    
    var body: some View {
        VStack{
            VStack{
                Text("\(qId). \(question)")
                    .font(deviceManager.isTablet ? .largeTitle : .title3)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(vieQuestion)
                    .font(deviceManager.isTablet ? .title : .body)
                    .fontWeight(.thin)
                    .multilineTextAlignment(.center)
                
                Text("Từ quan trọng:")
                    .underline()
                    .padding(.top)
                    
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("\(learn)")
                    .font(deviceManager.isTablet ? .title : .body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 1)
            }
            
            HStack{
                Spacer()
                
                Button(action: {
                    if let existingMark = markedQuestions.first(where: {$0.id == qId}){
                        context.delete(existingMark)
                    }
                    else{
                        let newMark = MarkedQuestion(id: qId)
                        context.insert(newMark)
                    }
                }){
                    Image(systemName: markedQuestions.contains {$0.id == qId} ? "bookmark.fill" : "bookmark")
                        .resizable()
                        .scaledToFit()
                        .frame(height: deviceManager.isTablet ? 50 : 25)
                }
                .padding(.trailing)
                
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
                        .frame(height: deviceManager.isTablet ? 30 : 20)
                }
            }
            
        }//end question
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.blue, lineWidth: 1)
                .fill(.blue.opacity(0.1))
        )
        .background(.white)
        .padding(.horizontal)
    }
}

struct AnswerView: View {
    var qId: Int
    var ans: String
    var vieAns: String
    var learn: String
    var synthesizer: AVSpeechSynthesizer
    @EnvironmentObject var deviceManager: DeviceManager
    @EnvironmentObject var userSetting: UserSetting
    @EnvironmentObject var govCapManager: GovCapManager
    @State var showingZipPrompt = false
    
    var body: some View {
        VStack{
            if qId == 20 || qId == 23 || qId == 43 || qId == 44{
                Text("Trả Lời:")
                    .font(deviceManager.isTablet ? .title : .body)
                    .padding(.bottom, 1)
                ServiceQuestions(
                    questionId: qId,
                    showingZipPrompt: $showingZipPrompt,
                    govAndCap: govCapManager.govAndCap
                )
            }
            
            //other questions except serviceQuestions
            else{
                VStack{
                    Text("Trả Lời:")
                        .font(deviceManager.isTablet ? .title : .body)
                    Text(ans)
                        .font(deviceManager.isTablet ? .largeTitle : .title3)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.top, 1)
                    Text(vieAns)
                        .font(deviceManager.isTablet ? .title : .body)
                        .fontWeight(.thin)
                        .multilineTextAlignment(.center)
                        .padding(.bottom)
                }
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
                        .frame(height: deviceManager.isTablet ? 30 : 20)
                }
            }
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.blue, lineWidth: 1)
                .fill(.blue.opacity(0.1))
        )
        .background(.white)
        .padding(.horizontal)
        
        .sheet(isPresented: $showingZipPrompt) {
            CTZipInput()
                .environmentObject(userSetting)
                .environmentObject(deviceManager)
        }
    }
}
