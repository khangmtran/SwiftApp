//
//  CTHomeMenu.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 1/19/25.
//
import SwiftUI

struct CTHomeMenu : View{
    @EnvironmentObject var selectedPart: SelectedPart
    @EnvironmentObject var deviceManager: DeviceManager
    @EnvironmentObject var userSetting: UserSetting
    @EnvironmentObject var questionList: QuestionList
    @EnvironmentObject var govCapManager: GovCapManager
    
    var body: some View{
        NavigationStack{
            VStack{
                Text("Học Thi Quốc Tịch 2025")
                    .font(deviceManager.isTablet ? .largeTitle : .title)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.vertical)
                
                List{
                    NavigationLink(destination: CTPracticeTest()){
                        CTCustomMenuItem(title: "Thi Thử", subtitle: "Bài thi trắc nghiệm 10 câu hỏi ngẫu nhiên", assetImage: "pen_paper")
                    }
                    
                    NavigationLink(destination: CTFlashCard()){
                        CTCustomMenuItem(title: "Thẻ Học", subtitle: "Học cùng thẻ bài để rèn luyện trí nhớ", assetImage: "flash_card")
                    }
                    
                    NavigationLink(destination: CTAllQuestions()){
                        CTCustomMenuItem(title: "100 Câu Hỏi", subtitle: "Xem tất cả câu hỏi và câu trả lời", assetImage: "book")
                    }
                    
                    NavigationLink(destination: CTLearnQuestions()){
                        CTCustomMenuItem(title: "Học Dễ Nhớ", subtitle: "Học 100 câu hỏi theo từng phần",
                                         assetImage: "book_stack")
                    }
                    
                }
                .listRowSpacing(20)
            }
        }
    }
}

struct CTHomeMenu_Provider: PreviewProvider{
    static var previews: some View{
        CTHomeMenu()
            .environmentObject(SelectedPart())
            .environmentObject(DeviceManager())
            .environmentObject(UserSetting())
            .environmentObject(QuestionList())
            .environmentObject(GovCapManager())
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
                } else if let assetImage = assetImage{
                    Image(assetImage)
                        .resizable()
                        .scaledToFit()
                }
            }
            .frame(width: deviceManager.isTablet ? 150 : 75)
            .padding()
            
            
            VStack{
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
