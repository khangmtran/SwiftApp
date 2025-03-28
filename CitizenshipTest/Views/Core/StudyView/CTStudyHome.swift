//
//  CTHomeMenu.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 1/19/25.
//
import SwiftUI

struct CTStudyHome : View{
    @EnvironmentObject var deviceManager: DeviceManager
    @EnvironmentObject var userSetting: UserSetting
    @EnvironmentObject var questions: QuestionList
    @EnvironmentObject var govCapManager: GovCapManager
    @EnvironmentObject var wrongAns: WrongAnswer
    @EnvironmentObject var selectedPard: SelectedPart
    
    var body: some View{
        NavigationStack{
            VStack{
                Text("Học Thi Quốc Tịch 2025")
                    .font(deviceManager.isTablet ? .largeTitle : .title)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.vertical)
                
                List{
                    NavigationLink(destination: CTAllQuestions()){
                        CTCustomMenuItem(title: "100 Câu Hỏi", subtitle: "Xem tất cả câu hỏi và câu trả lời", assetImage: "openbook")
                    }
                    .listRowBackground(Color.blue.opacity(0.1))

                    NavigationLink(destination: CTLearnQuestions()){
                        CTCustomMenuItem(title: "Học Theo Nhóm", subtitle: "Học 100 câu hỏi theo từng nhóm từ khoá",
                                         assetImage: "bookstack4")
                    }
                    .listRowBackground(Color.blue.opacity(0.1))
                    
                    NavigationLink(destination: CTAllMarkedQuestion()){
                        CTCustomMenuItem(title: "Câu Hỏi Đánh Dấu", subtitle: "Xem tất cả câu hỏi được đánh dấu", assetImage: "bookmark1")
                    }
                    .listRowBackground(Color.blue.opacity(0.1))
                    
                    NavigationLink(destination: CTAudioStudy()){
                        CTCustomMenuItem(title: "Nghe Câu Hỏi", subtitle: "Nghe tất cả câu hỏi và câu trả lời", assetImage: "headphone3")
                    }
                    .listRowBackground(Color.blue.opacity(0.1))

                }
                .scrollContentBackground(.hidden)
                .listRowSpacing(20)
            }
        }
    }
}

struct CTHomeMenu_Provider: PreviewProvider{
    static var previews: some View{
        CTStudyHome()
            .environmentObject(DeviceManager())
            .environmentObject(UserSetting())
            .environmentObject(QuestionList())
            .environmentObject(GovCapManager())
            .environmentObject(WrongAnswer())
            .environmentObject(SelectedPart())
    }
}
