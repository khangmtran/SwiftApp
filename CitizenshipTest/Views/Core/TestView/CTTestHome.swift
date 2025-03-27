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
                        CTCustomMenuItem(title: "10 Câu Hỏi Ngẫu Nhiên", subtitle: "Bài kiểm tra trắc nghiệm 10 câu hỏi ngẫu nhiên", assetImage: "quiz3")
                    }
                    .listRowBackground(Color.blue.opacity(0.1))
                    
                    NavigationLink(destination: CTAllQuestionTest()) {
                        CTCustomMenuItem(title: "Tất Cả Câu Hỏi", subtitle: "Kiểm tra 100 câu hỏi theo định dạng trắc nghiệm", assetImage: "quiz2")
                    }
                    .listRowBackground(Color.blue.opacity(0.1))
                    
                    NavigationLink(destination: CTMarkedQuestionTest()){
                        CTCustomMenuItem(title: "Câu Hỏi Đánh Dấu", subtitle: "Bài kiểm tra bao gồm những câu hỏi được đánh dấu", assetImage: "bookmarktest")
                    }
                    .listRowBackground(Color.blue.opacity(0.1))
                    
                    NavigationLink(destination: CTFlashCard()){
                        CTCustomMenuItem(title: "Thẻ Bài", subtitle: "Kiểm tra bằng thẻ bài", assetImage: "card")
                    }
                    .listRowBackground(Color.blue.opacity(0.1))
                    
                    Section(header: Text("Development Tools")) {
                        Button(action: {
                            resetUserSettings()
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                Text("Xóa Cài Đặt (Reset ZIP Code)")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                }
                .scrollContentBackground(.hidden)
                .listRowSpacing(20)
            }
        }
    }
    private func resetUserSettings() {
        userSetting.zipCode = ""
        userSetting.state = ""
        userSetting.legislators = []
        
        // Clear UserDefaults values
        UserDefaults.standard.removeObject(forKey: "userZip")
        UserDefaults.standard.removeObject(forKey: "userState")
        UserDefaults.standard.removeObject(forKey: "userLegislators")
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
