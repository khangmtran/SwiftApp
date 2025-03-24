//
//  CTTestHome.swift
//  CitizenshipTest
//
//  Created on 3/20/25.
//

import SwiftUI

struct CTTestHome: View {
    @EnvironmentObject var deviceManager: DeviceManager
    @EnvironmentObject var userSetting: UserSetting
    @EnvironmentObject var questions: QuestionList
    @EnvironmentObject var govCapManager: GovCapManager
    @EnvironmentObject var wrongAns: WrongAnswer
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Học Thi Quốc Tịch 2025")
                    .font(deviceManager.isTablet ? .largeTitle : .title)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.vertical)
                
                List {
                    NavigationLink(destination: CTPracticeTest()) {
                        CTCustomMenuItem(title: "Thi Thử 10 Câu", subtitle: "Bài thi trắc nghiệm 10 câu hỏi ngẫu nhiên", assetImage: "pen_paper")
                    }
                    .listRowBackground(Color.blue.opacity(0.1))
                    
                    NavigationLink(destination: CTAllQuestionTest()) {
                        CTCustomMenuItem(title: "Thi Thử 100 Câu", subtitle: "Toàn bộ 100 câu hỏi theo định dạng trắc nghiệm", assetImage: "book")
                    }
                    .listRowBackground(Color.blue.opacity(0.1))
                    
                    NavigationLink(destination: CTFlashCard()){
                        CTCustomMenuItem(title: "Thẻ Bài", subtitle: "Kiểm tra bằng thẻ bài", assetImage: "flash_card")
                    }
                    .listRowBackground(Color.blue.opacity(0.1))
                    
                    NavigationLink(destination: CTMarkedQuestionTest()){
                        CTCustomMenuItem(title: "Thẻ Bài", subtitle: "Kiểm tra bằng thẻ bài", assetImage: "flash_card")
                    }
                    .listRowBackground(Color.blue.opacity(0.1))
                    
                }
                .scrollContentBackground(.hidden)
                .listRowSpacing(20)
            }
        }
    }
}

// Placeholder views for future implementation
struct CTFullPracticeTest: View {
    var body: some View {
        Text("Thi thử toàn bộ 100 câu hỏi")
            .font(.title)
            .padding()
    }
}

struct CTTestHistory: View {
    var body: some View {
        Text("Lịch sử các bài thi gần đây")
            .font(.title)
            .padding()
    }
}

struct CTTestStrategies: View {
    var body: some View {
        Text("Chiến lược và mẹo làm bài thi")
            .font(.title)
            .padding()
    }
}

#Preview {
    CTTestHome()
        .environmentObject(DeviceManager())
        .environmentObject(UserSetting())
        .environmentObject(QuestionList())
        .environmentObject(GovCapManager())
        .environmentObject(WrongAnswer())
}
