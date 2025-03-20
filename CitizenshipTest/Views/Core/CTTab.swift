//
//  CTTabView.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 3/19/25.
//

import SwiftUI

struct CTTab: View {
    @State private var selectedTab = 1
    @EnvironmentObject var deviceManager: DeviceManager
    @EnvironmentObject var userSetting: UserSetting
    @EnvironmentObject var questionList: QuestionList
    @EnvironmentObject var govCapManager: GovCapManager
    @EnvironmentObject var wrongAnswer: WrongAnswer
    @EnvironmentObject var selectedPart: SelectedPart
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Test Tab
            CTPracticeTest()
                .environmentObject(questionList)
                .environmentObject(wrongAnswer)
                .environmentObject(deviceManager)
                .environmentObject(userSetting)
                .environmentObject(govCapManager)
                .tabItem {
                    Image(systemName: "checkmark.circle")
                    Text("Kiểm tra")
                        .font(deviceManager.isTablet ? .title : .body)
                }
                .tag(0)
            
            // Learn Tab
            NavigationStack{
                CTStudyHome()
                    .environmentObject(deviceManager)
                    .environmentObject(userSetting)
                    .environmentObject(questionList)
                    .environmentObject(govCapManager)
                    .environmentObject(wrongAnswer)
                    .environmentObject(selectedPart)
            }
            .id(selectedTab)
            .tabItem {
                Image(systemName: "book.fill")
                Text("Học")
                    .font(deviceManager.isTablet ? .title : .body)
            }
            .tag(1)
            
            
            // Settings Tab
            CTSetting()
                .environmentObject(deviceManager)
                .environmentObject(userSetting)
                .environmentObject(govCapManager)
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Cài đặt")
                        .font(deviceManager.isTablet ? .title : .body)
                }
                .tag(2)
        }
    }
}


#Preview {
    CTTab()
        .environmentObject(DeviceManager())
        .environmentObject(UserSetting())
        .environmentObject(QuestionList())
        .environmentObject(GovCapManager())
        .environmentObject(WrongAnswer())
        .environmentObject(SelectedPart())
}
