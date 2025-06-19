//
//  CTTestHome.swift
//  CitizenshipTest
//
//  Created on 3/20/25.
//

import SwiftUI
import FirebaseCrashlytics

struct CTTestHome: View {
    @EnvironmentObject var userSetting: UserSetting
    @EnvironmentObject var questions: QuestionList
    @EnvironmentObject var govCapManager: GovCapManager
    @EnvironmentObject var wrongAns: WrongAnswer
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var storeManager: StoreManager
    @State private var showingRemoveAdsView = false
    
    var body: some View{
        VStack{
            Text("Học Thi Quốc Tịch 2025")
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)
                .padding(.top)
            
            if !storeManager.isPurchased("KnT.CitizenshipTest.removeAds") {
                Button(action: {
                    showingRemoveAdsView = true
                }) {
                    HStack {
                        Text("Loại Bỏ Quảng Cáo")
                            .fontWeight(.semibold)
                        Image(systemName: "crown.fill")
                            .foregroundColor(.yellow)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 5)
                    .background(Color.blue)
                    .foregroundColor(.white)
                }
            }
            
            List {
                NavigationLink(value: TestRoute.practiceTest) {
                    CTCustomMenuItem(title: "10 Câu Hỏi Ngẫu Nhiên", subtitle: "Bài kiểm tra trắc nghiệm 10 câu hỏi ngẫu nhiên", assetImage: "quiz3")
                }
                .listRowBackground(Color.blue.opacity(0.1))
                
                NavigationLink(value: TestRoute.allQuestionsTest) {
                    CTCustomMenuItem(title: "Tất Cả Câu Hỏi", subtitle: "Kiểm tra 100 câu hỏi theo định dạng trắc nghiệm", assetImage: "quiz2")
                }
                .listRowBackground(Color.blue.opacity(0.1))
                
                NavigationLink(value: TestRoute.markedQuestionsTest) {
                    CTCustomMenuItem(title: "Câu Hỏi Đánh Dấu", subtitle: "Bài kiểm tra bao gồm những câu hỏi được đánh dấu", assetImage: "bookmarktest")
                }
                .listRowBackground(Color.blue.opacity(0.1))
                
                NavigationLink(value: TestRoute.flashCard) {
                    CTCustomMenuItem(title: "Thẻ Bài", subtitle: "Kiểm tra bằng thẻ bài", assetImage: "card")
                }
                .listRowBackground(Color.blue.opacity(0.1))
            }
            //.navigationDestination(for: String.self){value in}
            .scrollContentBackground(.hidden)
            .listRowSpacing(10)
        }
        .onAppear(){
            Crashlytics.crashlytics().log("User went to TestHome")
        }
        .sheet(isPresented: $showingRemoveAdsView) {
            CTRemoveAdsView()
                .environmentObject(storeManager)
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
        .environmentObject(UserSetting())
        .environmentObject(QuestionList())
        .environmentObject(GovCapManager())
        .environmentObject(WrongAnswer())
        .environmentObject(AudioManager())
}
