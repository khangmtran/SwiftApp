//
//  CTHomeMenu.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 1/19/25.
//
import SwiftUI

struct CTHomeMenu : View{
    var body: some View{
        VStack{
            Text("Học Thi Quốc Tịch 2025")
                .font(.title)
            NavigationView{
                List{
                    NavigationLink(destination: CTGetStarted()){
                        CTCustomMenuItem(title: "Thi Thử", subtitle: "Bài thi trắc nghiệm 10 câu hỏi ngẫu nhiên", assetImage: "pen_paper")
                    }
                    NavigationLink(destination: CTGetStarted()){
                        CTCustomMenuItem(title: "Thẻ Học", subtitle: "Học cùng thẻ bài để rèn luyện trí nhớ", assetImage: "flash_card")
                    }
                    NavigationLink(destination: CTGetStarted()){
                        CTCustomMenuItem(title: "100 Câu Hỏi", subtitle: "Xem tất cả câu hỏi và câu trả lời", assetImage: "book")
                    }
                }.listRowSpacing(30)
            }
        }
        
    }
}

struct CTHomeMenu_Provider: PreviewProvider{
    static var previews: some View{
        CTHomeMenu()
    }
}
