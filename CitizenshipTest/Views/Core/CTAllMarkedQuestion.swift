//
//  CTAllMarkedQuestion.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 3/19/25.
//

import SwiftUI
import AVFoundation
import SwiftData

struct CTAllMarkedQuestion: View {
    @State private var synthesizer = AVSpeechSynthesizer()
    @State private var showingZipPrompt = false
    @State private var page = 0
    @EnvironmentObject var deviceManager: DeviceManager
    @EnvironmentObject var userSetting: UserSetting
    @EnvironmentObject var questionList: QuestionList
    @EnvironmentObject var govCapManager: GovCapManager
    @Environment(\.modelContext) private var context
    @Query private var markedQuestions: [MarkedQuestion]
    
    // Get only marked questions from the question list
    private var filteredQuestions: [CTQuestion] {
        return questionList.questions.filter { question in
            markedQuestions.contains { $0.id == question.id }
        }.sorted(by: { $0.id < $1.id }) // Sort by ID for consistency
    }
    
    // Paginate the filtered questions
    private var paginatedQuestions: [CTQuestion] {
        if filteredQuestions.isEmpty {
            return []
        }
        
        let startIndex = page * 10
        let endIndex = min(startIndex + 9, filteredQuestions.count - 1)
        
        if startIndex >= filteredQuestions.count {
            return []
        }
        
        return Array(filteredQuestions[startIndex...endIndex])
    }
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            VStack {
                if filteredQuestions.isEmpty {
                    VStack {
                        Spacer()
                        Text("Chưa có câu hỏi đánh dấu")
                            .font(deviceManager.isTablet ? .title : .body)
                            .foregroundColor(.gray)
                        Text("Hãy đánh dấu những câu hỏi bạn muốn ôn tập")
                            .font(deviceManager.isTablet ? .title3 : .callout)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Image(systemName: "bookmark.slash")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                            .padding()
                        Spacer()
                    }
                } else {
                    List(paginatedQuestions) { question in
                        Section(header: Text("Câu hỏi \(question.id)")
                            .id(question.id)
                            .font(deviceManager.isTablet ? .title3 : .footnote)) {
                                // Question stack
                                HStack {
                                    // VStack contains ENG and VIE questions
                                    VStack(alignment: .leading) {
                                        Text(question.question)
                                            .font(deviceManager.isTablet ? .largeTitle : .title3)
                                            .fontWeight(.bold)
                                        
                                        Text(question.questionVie)
                                            .font(deviceManager.isTablet ? .title : .body)
                                    }
                                    
                                    Spacer()
                                    
                                    // VStack contains voice and bookmark buttons
                                    VStack {
                                        // Voice button
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
                                                .frame(height: deviceManager.isTablet ? 50 : 25)
                                        }
                                        .padding(.bottom)
                                        
                                        // Bookmark button
                                        Button(action: {
                                            if let existingMark = markedQuestions.first(where: {$0.id == question.id}) {
                                                context.delete(existingMark)
                                            } else {
                                                let newMark = MarkedQuestion(id: question.id)
                                                context.insert(newMark)
                                            }
                                        }) {
                                            Image(systemName: "bookmark.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: deviceManager.isTablet ? 50 : 25)
                                        }
                                    }
                                }
                                .padding(.vertical)
                                
                                // Answer stack
                                HStack {
                                    if question.id == 20 || question.id == 23 || question.id == 43 || question.id == 44 {
                                        // Question 20
                                        if question.id == 20 {
                                            VStack(alignment: .leading) {
                                                Text("Trả lời: Chon 1 trong nhung Senator duoi day:")
                                                    .font(deviceManager.isTablet ? .largeTitle : .title3)
                                                    .fontWeight(.bold)
                                                let senators = userSetting.legislators.filter {$0.type == "senator"}
                                                ForEach(senators) { sen in
                                                    Text("\(sen.firstName) \(sen.lastName)")
                                                        .font(deviceManager.isTablet ? .largeTitle : .title3)
                                                        .fontWeight(.bold)
                                                        .frame(maxWidth: .infinity, alignment: .center)
                                                }
                                                Button(action: {
                                                    showingZipPrompt = true
                                                }) {
                                                    Text("Nhap ZIP Code de tim Senators cua ban")
                                                        .font(deviceManager.isTablet ? .largeTitle : .title3)
                                                }
                                            }
                                        }
                                        
                                        // Question 23
                                        else if question.id == 23 {
                                            VStack(alignment: .leading) {
                                                Text("Trả lời:")
                                                    .font(deviceManager.isTablet ? .largeTitle : .title3)
                                                    .fontWeight(.bold)
                                                let represenatatives = userSetting.legislators.filter {$0.type == "representative"}
                                                ForEach(represenatatives) { rep in
                                                    Text("\(rep.firstName) \(rep.lastName)")
                                                        .font(deviceManager.isTablet ? .largeTitle : .title3)
                                                        .fontWeight(.bold)
                                                }
                                                Button(action: {
                                                    showingZipPrompt = true
                                                }) {
                                                    Text("Nhap ZIP Code de tim Representative cua ban")
                                                        .font(deviceManager.isTablet ? .largeTitle : .title3)
                                                }
                                            }
                                        }
                                        
                                        // Question 43
                                        else if question.id == 43 {
                                            VStack(alignment: .leading) {
                                                Text("Trả lời:")
                                                    .font(deviceManager.isTablet ? .largeTitle : .title3)
                                                    .fontWeight(.bold)
                                                let state = userSetting.state
                                                ForEach(govCapManager.govAndCap) { gnc in
                                                    if gnc.state == state {
                                                        Text("\(gnc.gov)")
                                                            .font(deviceManager.isTablet ? .largeTitle : .title3)
                                                            .fontWeight(.bold)
                                                    }
                                                }
                                                Button(action: {
                                                    showingZipPrompt = true
                                                }) {
                                                    Text("Nhap ZIP Code de tim Governor cua ban")
                                                        .font(deviceManager.isTablet ? .largeTitle : .title3)
                                                }
                                            }
                                        }
                                        
                                        // Question 44
                                        else if question.id == 44 {
                                            VStack(alignment: .leading) {
                                                Text("Trả lời:")
                                                    .font(deviceManager.isTablet ? .largeTitle : .title3)
                                                    .fontWeight(.bold)
                                                let state = userSetting.state
                                                ForEach(govCapManager.govAndCap) { gnc in
                                                    if gnc.state == state {
                                                        Text("\(gnc.capital)")
                                                            .font(deviceManager.isTablet ? .largeTitle : .title3)
                                                            .fontWeight(.bold)
                                                    }
                                                }
                                                Button(action: {
                                                    showingZipPrompt = true
                                                }) {
                                                    Text("Nhap ZIP Code de tim Capital cua ban")
                                                        .font(deviceManager.isTablet ? .largeTitle : .title3)
                                                }
                                            }
                                        }
                                    }
                                    
                                    // All questions except q20, q23, q43, and q44
                                    else {
                                        // Eng and Vie answer
                                        VStack(alignment: .leading) {
                                            Text("Trả lời: \(question.answer)")
                                                .font(deviceManager.isTablet ? .largeTitle : .title3)
                                                .fontWeight(.bold)
                                            
                                            Text(question.answerVie)
                                                .font(deviceManager.isTablet ? .title : .body)
                                        }
                                        
                                        Spacer()
                                        
                                        // Voice button
                                        VStack(alignment: .leading) {
                                            Button(action: {
                                                synthesizer.stopSpeaking(at: .immediate)
                                                let utterance = AVSpeechUtterance(string: question.answer)
                                                utterance.voice = AVSpeechSynthesisVoice()
                                                utterance.rate = 0.3
                                                synthesizer.speak(utterance)
                                            }) {
                                                Image(systemName: "speaker.wave.3")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(height: deviceManager.isTablet ? 50 : 25)
                                            }
                                        }
                                    }
                                }
                                .padding(.vertical)
                            }
                            .listRowBackground(Color.blue.opacity(0.1))
                    }
                    .scrollContentBackground(.hidden)
                    
                    if !filteredQuestions.isEmpty {
                        NavButtonMarkedQ(page: $page, totalPages: max(0, (filteredQuestions.count - 1) / 10))
                            .padding()
                            .background(Color.white)
                    }
                }
            }
            .sheet(isPresented: $showingZipPrompt) {
                CTZipInput()
                    .environmentObject(userSetting)
                    .environmentObject(deviceManager)
            }
            .navigationTitle("Câu Hỏi Đánh Dấu")
            .onChange(of: page) { oldValue, newValue in
                withAnimation {
                    let firstQId = paginatedQuestions.first?.id
                    if let firstQId = firstQId {
                        scrollProxy.scrollTo(firstQId, anchor: .center)
                    }
                }
            }
        }
    }
}

struct NavButtonMarkedQ: View {
    @EnvironmentObject var deviceManager: DeviceManager
    @Binding var page: Int
    let totalPages: Int
    
    var body: some View {
        HStack {
            Button(action: prevPage) {
                Text("Tro Ve")
                    .font(deviceManager.isTablet ? .largeTitle : .title3)
            }
            .padding()
            .foregroundStyle(.white)
            .background(.blue)
            .cornerRadius(10)
            
            Spacer()
            
            Button(action: nextPage) {
                Text("Tiep Theo")
                    .font(deviceManager.isTablet ? .largeTitle : .title3)
            }
            .padding()
            .foregroundStyle(.white)
            .background(.blue)
            .cornerRadius(10)
        }
    }
    
    private func nextPage() {
        if page < totalPages {
            page += 1
        } else if page == totalPages {
            page = 0
        }
    }
    
    private func prevPage() {
        if page > 0 {
            page -= 1
        } else if page == 0 {
            page = totalPages
        }
    }
}

#Preview {
    CTAllMarkedQuestion()
        .environmentObject(DeviceManager())
        .environmentObject(UserSetting())
        .environmentObject(QuestionList())
        .environmentObject(GovCapManager())
}
