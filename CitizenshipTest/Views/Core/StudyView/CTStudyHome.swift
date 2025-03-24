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
                        CTCustomMenuItem(title: "100 Câu Hỏi", subtitle: "Xem tất cả câu hỏi và câu trả lời", assetImage: "book")
                    }
                    .listRowBackground(Color.blue.opacity(0.1))

                    NavigationLink(destination: CTLearnQuestions()){
                        CTCustomMenuItem(title: "Học Dễ Nhớ", subtitle: "Học 100 câu hỏi theo từng phần",
                                         assetImage: "book_stack")
                    }
                    .listRowBackground(Color.blue.opacity(0.1))
                    
                    NavigationLink(destination: CTAllMarkedQuestion()){
                        CTCustomMenuItem(title: "Câu Hỏi Đánh Dấu", subtitle: "Xem tất cả câu hỏi được đánh dấu", assetImage: "pen_paper")
                    }
                    .listRowBackground(Color.blue.opacity(0.1))
                    
                    NavigationLink(destination: CTAudioStudy()){
                        CTCustomMenuItem(title: "Nghe Câu Hỏi", subtitle: "Nghe tất cả câu hỏi và câu trả lời", systemImg: "headphones")
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

struct CTCustomMenuItem: View{
    @EnvironmentObject var deviceManager : DeviceManager
    let title: String
    let subtitle: String
    let systemImg: String?
    let assetImage: String?
    
    init(title: String, subtitle: String, systemImg: String? = nil, assetImage: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.systemImg = systemImg
        self.assetImage = assetImage
    }
    
    var body: some View{
        
        HStack{
            VStack{
                if let systemImg = systemImg{
                    Image(systemName: systemImg)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.blue)
                } else if let assetImage = assetImage{
                    Image(assetImage)
                        .resizable()
                        .scaledToFit()
                }
            }
            .frame(width: deviceManager.isTablet ? 150 : 75)
            
            VStack(){
                Text(title)
                    .font(deviceManager.isTablet ? .largeTitle : .title3)
                    .fontWeight(.bold)
                    .fixedSize(horizontal: false, vertical: true)
                Text(subtitle)
                    .font(deviceManager.isTablet ? .title : .body)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }
}
