//
//  CTTab.swift
//  CitizenshipTest
//
//  Modified on 3/20/25.
//

import SwiftUI

extension View {
    func supportAccessibilityTextSizes() -> some View {
        self.dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }
}

// Define route types for each tab
enum TestRoute: Hashable {
    case practiceTest
    case allQuestionsTest
    case markedQuestionsTest
    case flashCard
}

enum StudyRoute: Hashable {
    case allQuestions
    case learnQuestions
    case allMarkedQuestions
    case audioStudy
}

enum SettingsRoute: Hashable {
    case zipInput
}

struct CTTab: View {
    @State private var selectedTab: Tab = .study
    @State private var testStack: NavigationPath = .init()
    @State private var studyStack: NavigationPath = .init()
    @State private var settingStack: NavigationPath = .init()
    @EnvironmentObject var deviceManager: DeviceManager
    @EnvironmentObject var userSetting: UserSetting
    @EnvironmentObject var questionList: QuestionList
    @EnvironmentObject var govCapManager: GovCapManager
    @EnvironmentObject var wrongAnswer: WrongAnswer
    @EnvironmentObject var selectedPart: SelectedPart
    @EnvironmentObject var synthesizer: AudioManager
    
    var tabSelection: Binding<Tab>{
        return .init {
            return selectedTab
        } set: { newValue in
            if newValue == selectedTab{
                switch newValue{
                case .test: testStack = .init()
                case .study: studyStack = .init()
                case .setting: settingStack = .init()
                }
            }
            selectedTab = newValue
        }
    }
    
    var body: some View {
        TabView(selection: tabSelection) {
            // Test Tab
            NavigationStack(path: $testStack) {
                CTTestHome()
                    .environmentObject(questionList)
                    .environmentObject(wrongAnswer)
                    .environmentObject(deviceManager)
                    .environmentObject(userSetting)
                    .environmentObject(govCapManager)
                // Navigation destinations for Test tab
                    .navigationDestination(for: TestRoute.self) { route in
                        switch route {
                        case .practiceTest:
                            CTPracticeTest()
                                .environmentObject(questionList)
                                .environmentObject(wrongAnswer)
                                .environmentObject(deviceManager)
                                .environmentObject(userSetting)
                                .environmentObject(govCapManager)
                        case .allQuestionsTest:
                            CTAllQuestionTest()
                                .environmentObject(questionList)
                                .environmentObject(wrongAnswer)
                                .environmentObject(deviceManager)
                                .environmentObject(userSetting)
                                .environmentObject(govCapManager)
                        case .markedQuestionsTest:
                            CTMarkedQuestionTest()
                                .environmentObject(questionList)
                                .environmentObject(wrongAnswer)
                                .environmentObject(deviceManager)
                                .environmentObject(userSetting)
                                .environmentObject(govCapManager)
                        case .flashCard:
                            CTFlashCard()
                                .environmentObject(deviceManager)
                                .environmentObject(userSetting)
                                .environmentObject(questionList)
                                .environmentObject(govCapManager)
                        }
                    }
            }
            .tabItem {
                Image(systemName: "checkmark.circle")
                Text("Kiểm tra")
                    .font(deviceManager.isTablet ? .title : .body)
            }
            .tag(Tab.test)
            
            // Learn Tab
            NavigationStack(path: $studyStack) {
                CTStudyHome()
                    .environmentObject(deviceManager)
                    .environmentObject(userSetting)
                    .environmentObject(questionList)
                    .environmentObject(govCapManager)
                    .environmentObject(wrongAnswer)
                    .environmentObject(selectedPart)
                // Navigation destinations for Study tab
                    .navigationDestination(for: StudyRoute.self) { route in
                        switch route {
                        case .allQuestions:
                            CTAllQuestions()
                                .environmentObject(deviceManager)
                                .environmentObject(userSetting)
                                .environmentObject(questionList)
                                .environmentObject(govCapManager)
                        case .learnQuestions:
                            CTLearnQuestions()
                                .environmentObject(userSetting)
                                .environmentObject(deviceManager)
                                .environmentObject(selectedPart)
                                .environmentObject(questionList)
                                .environmentObject(govCapManager)
                        case .allMarkedQuestions:
                            CTAllMarkedQuestion()
                                .environmentObject(deviceManager)
                                .environmentObject(userSetting)
                                .environmentObject(questionList)
                                .environmentObject(govCapManager)
                        case .audioStudy:
                            CTAudioStudy()
                                .environmentObject(questionList)
                                .environmentObject(deviceManager)
                                .environmentObject(userSetting)
                                .environmentObject(govCapManager)
                        }
                    }
            }
            .tabItem {
                Image(systemName: "book.fill")
                Text("Học")
                    .font(deviceManager.isTablet ? .title : .body)
            }
            .tag(Tab.study)
            
            // Settings Tab
            NavigationStack(path: $settingStack){
                CTSetting()
                    .environmentObject(deviceManager)
                    .environmentObject(userSetting)
                    .environmentObject(govCapManager)
                    .environmentObject(synthesizer)
                // Navigation destinations for Settings tab
                    .navigationDestination(for: SettingsRoute.self) { route in
                        switch route {
                        case .zipInput:
                            CTZipInput()
                                .environmentObject(userSetting)
                                .environmentObject(deviceManager)
                        }
                    }
            }
            .tabItem {
                Image(systemName: "gearshape.fill")
                Text("Cài đặt")
                    .font(deviceManager.isTablet ? .title : .body)
            }
            .tag(Tab.setting)
        }
        .supportAccessibilityTextSizes()
    }
}

enum Tab: Int{
    case test = 0
    case study = 1
    case setting = 2
}

#Preview {
    CTTab()
        .environmentObject(DeviceManager())
        .environmentObject(UserSetting())
        .environmentObject(QuestionList())
        .environmentObject(GovCapManager())
        .environmentObject(WrongAnswer())
        .environmentObject(SelectedPart())
        .environmentObject(AudioManager())
}
