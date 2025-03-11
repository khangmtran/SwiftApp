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
    @State private var qIndex: Int = 0
    @State private var isFlipped = false
    @State private var frontDegree = 0.0
    @State private var backDegree = 90.0
    @State private var frontZIndex = 1.0
    @State private var backZIndex = 0.0
    @State private var synthesizer = AVSpeechSynthesizer()
    @State private var isChangingCard = false
    @State private var showingZipPrompt = false
    @State private var showQuestionType: Bool = false
    @EnvironmentObject var userSetting: UserSetting
    @EnvironmentObject var deviceManager: DeviceManager
    @EnvironmentObject var questionList: QuestionList
    @EnvironmentObject var govCapManager: GovCapManager
    
    var body: some View{
        VStack{
            HStack{
                Text("Card \(qIndex + 1) / \(questions.count)")
                Spacer()
                Button(action:{
                    showQuestionType = true
                }){
                    Text("Question Type")
                }
            }
            .padding(.horizontal)
            
            ZStack{
                if !questions.isEmpty{
                    CardFront(zIndex:$frontZIndex, degree: $frontDegree, isFlipped: $isFlipped,
                              questions: $questions, qIndex: $qIndex, synthesizer: synthesizer)
                    
                    CardBack(zIndex: $backZIndex, degree: $backDegree, isFlipped: $isFlipped,
                             questions: $questions, qIndex: $qIndex, synthesizer: synthesizer,
                             showingZipPrompt: $showingZipPrompt)
                    .opacity(isChangingCard ? 0 : 1)
                }
                else{
                    ProgressView()
                }
            }
        }
        .sheet(isPresented: $showQuestionType) {
            QuestionTypeView(questions: $questions, qIndex: $qIndex)
                .presentationDetents([.fraction(0.3)])
                .presentationDragIndicator(.visible)
        }
        .onTapGesture {
            isChangingCard = false
            isFlipped.toggle()
            updateCardDegrees()
            updateZIndices()
        }
        .onChange(of: qIndex){ oldValue, newValue in
            isChangingCard = true
            isFlipped = false
            updateCardDegrees()
            frontZIndex = 1.0
            backZIndex = 0.0
            synthesizer.stopSpeaking(at: .immediate)
        }
        .onAppear(){
            questions = questionList.questions
        }
        .safeAreaInset(edge: .bottom) {
            NavButtonsFC(qIndex: $qIndex, questions: questions)
                .padding()
                .background(Color.white)
        }
    }
    private func updateCardDegrees() {
        if isFlipped {
            frontDegree = 90.0
            backDegree = 0.0
        } else {
            frontDegree = 0.0
            backDegree = -90.0
        }
    }
    private func updateZIndices() {
        if isFlipped {
            frontZIndex = 0.0
            backZIndex = 1.0
        } else {
            frontZIndex = 1.0
            backZIndex = 0.0
        }
    }
}

struct NavButtonsFC: View{
    @Binding var qIndex: Int
    let questions: [CTQuestion]
    @EnvironmentObject var deviceManager: DeviceManager
    
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
            
        }
        
    }
    
    private func nextQuestion(){
        if qIndex < questions.count - 1 {
            qIndex += 1
        }
        else if qIndex == questions.count - 1{
            qIndex = 0
        }
    }
    
    private func prevQuestion(){
        if qIndex > 0{
            qIndex -= 1
        }
        else if qIndex == 0{
            qIndex = questions.count - 1
        }
    }
}

struct CardFront: View{
    @Binding var zIndex: Double
    @Binding var degree: Double
    @Binding var isFlipped: Bool
    @Binding var questions: [CTQuestion]
    @Binding var qIndex: Int
    let synthesizer: AVSpeechSynthesizer
    @EnvironmentObject var deviceManager: DeviceManager
    @Environment(\.modelContext) private var context
    @Query private var markedQuestions: [MarkedQuestion]
    
    var body: some View{
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .stroke(.green.opacity(0.5), lineWidth: 10)
                .fill(.green.opacity(0.1))
            
            VStack{
                Text("Question \(questions[qIndex].id):")
                    .font(deviceManager.isTablet ? .largeTitle : .title3)
                Text("\(questions[qIndex].question)")
                    .font(deviceManager.isTablet ? .largeTitle : .title3)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.vertical, 1)
                    .padding(.horizontal)
                Text(questions[qIndex].questionVie)
                    .font(deviceManager.isTablet ? .title : .body)
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
                            .foregroundColor(.yellow)
                            .frame(height: deviceManager.isTablet ? 40 : 20)
                    }
                    
                    
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
                            .frame(height: deviceManager.isTablet ? 40 : 20)
                    }
                }
                .padding()
            }
            .padding()
            
        }
        .padding()
        .rotation3DEffect(Angle(degrees: degree), axis: (x:0, y:1, z:0))
        .animation(isFlipped ? .linear : .linear.delay(0.4), value: isFlipped)
        .zIndex(zIndex)
        
    }
}

struct CardBack: View{
    @Binding var zIndex: Double
    @Binding var degree: Double
    @Binding var isFlipped: Bool
    @Binding var questions: [CTQuestion]
    @Binding var qIndex: Int
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
                    .stroke(.blue.opacity(0.5), lineWidth: 10)
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
                            .font(deviceManager.isTablet ? .largeTitle : .title3)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.vertical, 1)
                            .padding(.horizontal)
                        Text("\(questions[qIndex].answerVie)")
                            .font(deviceManager.isTablet ? .title : .body)
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
                                .foregroundColor(.yellow)
                                .frame(height: deviceManager.isTablet ? 40 : 20)
                        }
                        
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
                                .frame(height: deviceManager.isTablet ? 40 : 20)
                        }
                    }
                    .padding()
                }
                .padding()
                
            }
            .padding()
            .rotation3DEffect(Angle(degrees: degree), axis: (x:0, y:1, z:0))
            .animation(isFlipped ? .linear.delay(0.4) : .linear, value: isFlipped)
            .zIndex(zIndex)
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
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Select Question Order")
            //.font(.headline)
                .padding(.top)
            
            Button(action: {
                // Handle sequential order
                questions = questionList.questions
                qIndex = 0
                dismiss()
            }) {
                HStack {
                    Image(systemName: "list.number")
                    Text("Sequential Order")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal)
            
            Button(action: {
                // Handle random order
                questions = questionList.questions.shuffled()
                qIndex = 0
                dismiss()
            }) {
                HStack {
                    Image(systemName: "shuffle")
                    Text("Random Order")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal)
            
            Button(action: {
                //                // Handle marked questions
                //                let markedQuestionsList = markedQuestions.getMarkedQuestionsList(allQuestions: initialQuestionList)
                //                if !markedQuestionsList.isEmpty {
                //                    questions = markedQuestionsList
                //                    qIndex = 0
                //                }
                dismiss()
            }) {
                HStack {
                    Image(systemName: "mark.fill")
                    Text("Marked Questions")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
}

#Preview{
    CTFlashCard()
        .environmentObject(DeviceManager())
        .environmentObject(UserSetting())
        .environmentObject(QuestionList())
        .environmentObject(GovCapManager())
}
