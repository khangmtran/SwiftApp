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
    @EnvironmentObject var userSetting: UserSetting
    @EnvironmentObject var questionList: QuestionList
    @EnvironmentObject var govCapManager: GovCapManager
    @EnvironmentObject var wrongAnswer: WrongAnswer
    @EnvironmentObject var selectedPart: SelectedPart
    @EnvironmentObject var audioManager: AudioManager
    
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
                    .environmentObject(userSetting)
                    .environmentObject(govCapManager)
                    .environmentObject(audioManager)
                // Navigation destinations for Test tab
                    .navigationDestination(for: TestRoute.self) { route in
                        switch route {
                        case .practiceTest:
                            CTPracticeTest()
                                .environmentObject(questionList)
                                .environmentObject(wrongAnswer)
                                .environmentObject(userSetting)
                                .environmentObject(govCapManager)
                                .environmentObject(audioManager)
                        case .allQuestionsTest:
                            CTAllQuestionTest()
                                .environmentObject(questionList)
                                .environmentObject(wrongAnswer)
                                .environmentObject(userSetting)
                                .environmentObject(govCapManager)
                                .environmentObject(audioManager)
                        case .markedQuestionsTest:
                            CTMarkedQuestionTest()
                                .environmentObject(questionList)
                                .environmentObject(wrongAnswer)
                                .environmentObject(userSetting)
                                .environmentObject(govCapManager)
                                .environmentObject(audioManager)
                        case .flashCard:
                            CTFlashCard()
                                .environmentObject(userSetting)
                                .environmentObject(questionList)
                                .environmentObject(govCapManager)
                                .environmentObject(audioManager)
                        }
                    }
            }
            .tabItem {
                Image(systemName: "checkmark.circle")
                Text("Kiểm tra")
            }
            .tag(Tab.test)
            
            // Learn Tab
            NavigationStack(path: $studyStack) {
                CTStudyHome()
                    .environmentObject(userSetting)
                    .environmentObject(questionList)
                    .environmentObject(govCapManager)
                    .environmentObject(wrongAnswer)
                    .environmentObject(selectedPart)
                    .environmentObject(audioManager)
                // Navigation destinations for Study tab
                    .navigationDestination(for: StudyRoute.self) { route in
                        switch route {
                        case .allQuestions:
                            CTAllQuestions()
                                .environmentObject(userSetting)
                                .environmentObject(questionList)
                                .environmentObject(govCapManager)
                                .environmentObject(audioManager)
                        case .learnQuestions:
                            CTLearnQuestions()
                                .environmentObject(userSetting)
                                .environmentObject(selectedPart)
                                .environmentObject(questionList)
                                .environmentObject(govCapManager)
                                .environmentObject(audioManager)
                        case .allMarkedQuestions:
                            CTAllMarkedQuestion()
                                .environmentObject(userSetting)
                                .environmentObject(questionList)
                                .environmentObject(govCapManager)
                                .environmentObject(audioManager)
                        case .audioStudy:
                            CTAudioStudy()
                                .environmentObject(questionList)
                                .environmentObject(userSetting)
                                .environmentObject(govCapManager)
                                .environmentObject(audioManager)
                        }
                    }
            }
            .tabItem {
                Image(systemName: "book.fill")
                Text("Học")
            }
            .tag(Tab.study)
            
            // Settings Tab
            NavigationStack(path: $settingStack){
                CTSetting()
                    .environmentObject(userSetting)
                    .environmentObject(govCapManager)
                    .environmentObject(audioManager)
                // Navigation destinations for Settings tab
                    .navigationDestination(for: SettingsRoute.self) { route in
                        switch route {
                        case .zipInput:
                            CTZipInput()
                                .environmentObject(userSetting)
                        }
                    }
            }
            .tabItem {
                Image(systemName: "gearshape.fill")
                Text("Cài đặt")
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
        .environmentObject(UserSetting())
        .environmentObject(QuestionList())
        .environmentObject(GovCapManager())
        .environmentObject(WrongAnswer())
        .environmentObject(SelectedPart())
        .environmentObject(AudioManager())
}
