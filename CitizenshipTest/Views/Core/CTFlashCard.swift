//
//  CTFlashCard.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 2/27/25.
//

import SwiftUI
import AVFoundation

struct CTFlashCard: View{
    @State private var questions: [CTQuestion] = []
    @State private var qIndex: Int = 0
    @State private var isFlipped = false
    @State private var frontDegree = 0.0
    @State private var backDegree = 90.0
    @State private var frontZIndex = 1.0
    @State private var backZIndex = 0.0
    @EnvironmentObject var deviceManager: DeviceManager
    @State private var synthesizer = AVSpeechSynthesizer()
    @State private var isChangingCard = false
    @EnvironmentObject var userSetting: UserSetting
    @State private var showingZipPrompt = false
    @State private var govAndCap: [CTGovAndCapital] = []
    
    var body: some View{
        ZStack{
            if !questions.isEmpty{
                CardFront(zIndex:$frontZIndex, degree: $frontDegree, isFlipped: $isFlipped,
                          questions: questions, qIndex: $qIndex, synthesizer: synthesizer)
                
                CardBack(zIndex: $backZIndex, degree: $backDegree, isFlipped: $isFlipped,
                         questions: questions, qIndex: $qIndex, synthesizer: synthesizer, showingZipPrompt: $showingZipPrompt,
                         govAndCap: govAndCap)
                .opacity(isChangingCard ? 0 : 1)
            }
            else{
                ProgressView()
            }
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
            questions = CTDataLoader().loadQuestions()
            govAndCap = CTDataLoader().loadGovAndCapital()
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
    let questions: [CTQuestion]
    @Binding var qIndex: Int
    let synthesizer: AVSpeechSynthesizer
    @EnvironmentObject var deviceManager: DeviceManager
    
    var body: some View{
        ZStack{
            
            RoundedRectangle(cornerRadius: 20)
                .stroke(.green.opacity(0.5), lineWidth: 10)
                .fill(.green.opacity(0.1))
                .padding()
            
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
        .rotation3DEffect(Angle(degrees: degree), axis: (x:0, y:1, z:0))
        .animation(isFlipped ? .linear : .linear.delay(0.4), value: isFlipped)
        .zIndex(zIndex)
    }
}

struct CardBack: View{
    @Binding var zIndex: Double
    @Binding var degree: Double
    @Binding var isFlipped: Bool
    let questions: [CTQuestion]
    @Binding var qIndex: Int
    let synthesizer: AVSpeechSynthesizer
    @EnvironmentObject var deviceManager: DeviceManager
    @Binding var showingZipPrompt: Bool
    let govAndCap: [CTGovAndCapital]
    @EnvironmentObject var userSetting: UserSetting
    
    var body: some View{
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .stroke(.blue.opacity(0.5), lineWidth: 10)
                .fill(.blue.opacity(0.1))
                .padding()
            
            VStack{
                if questions[qIndex].id == 20 || questions[qIndex].id == 23 || questions[qIndex].id == 43 || questions[qIndex].id == 44{
                    ServiceQuestions(
                        questionId: questions[qIndex].id,
                        showingZipPrompt: $showingZipPrompt,
                        govAndCap: govAndCap
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
        .rotation3DEffect(Angle(degrees: degree), axis: (x:0, y:1, z:0))
        .animation(isFlipped ? .linear.delay(0.4) : .linear, value: isFlipped)
        .zIndex(zIndex)
        .sheet(isPresented: $showingZipPrompt) {
            CTZipInput()
                .environmentObject(userSetting)
                .environmentObject(deviceManager)
        }
    }
}

#Preview{
    CTFlashCard()
        .environmentObject(DeviceManager())
        .environmentObject(UserSetting())
}
