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
            NavigationStack {
                CTPracticeTest()
                    .environmentObject(questionList)
                    .environmentObject(wrongAnswer)
                    .environmentObject(deviceManager)
                    .environmentObject(userSetting)
                    .environmentObject(govCapManager)
            }
            .tabItem {
                Image(systemName: "checkmark.circle")
                Text("Kiểm tra")
                    .font(deviceManager.isTablet ? .title : .body)
            }
            .tag(0)
            
            // Learn Tab
            NavigationStack {
                CTHomeMenu()
                    .environmentObject(deviceManager)
                    .environmentObject(userSetting)
                    .environmentObject(questionList)
                    .environmentObject(govCapManager)
                    .environmentObject(wrongAnswer)
                    .environmentObject(selectedPart)
            }
            .tabItem {
                Image(systemName: "book.fill")
                Text("Học")
                    .font(deviceManager.isTablet ? .title : .body)
            }
            .tag(1)
            
            // Settings Tab
            NavigationStack {
                CTSetting()
                    .environmentObject(deviceManager)
                    .environmentObject(userSetting)
                    .environmentObject(govCapManager)
            }
            .tabItem {
                Image(systemName: "gearshape.fill")
                Text("Cài đặt")
                    .font(deviceManager.isTablet ? .title : .body)
            }
            .tag(2)
        }
        .onAppear {
            // Use a larger font for tab items if on iPad
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            
            if deviceManager.isTablet {
                // Larger font for iPad
                let fontSize: CGFloat = 18
                let fontAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize, weight: .semibold)]
                appearance.stackedLayoutAppearance.normal.titleTextAttributes = fontAttributes
                appearance.stackedLayoutAppearance.selected.titleTextAttributes = fontAttributes
            }
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}


#Preview {
    CTTabView()
        .environmentObject(DeviceManager())
        .environmentObject(UserSetting())
        .environmentObject(QuestionList())
        .environmentObject(GovCapManager())
        .environmentObject(WrongAnswer())
        .environmentObject(SelectedPart())
}
