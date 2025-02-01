//
//  CTHomeMenu.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 1/19/25.
//
import SwiftUI

struct CTHomeMenu : View{
    @EnvironmentObject var selectedPart: SelectedPart
    var body: some View{
        NavigationView{
            VStack{
                Text("Học Thi Quốc Tịch 2025")
                   .font(.title)
                List{
                    NavigationLink(destination: CTGetStarted()){
                        CTCustomMenuItem(title: "Thi Thử", subtitle: "Bài thi trắc nghiệm 10 câu hỏi ngẫu nhiên", assetImage: "pen_paper")
                    }
                    NavigationLink(destination: CTGetStarted()){
                        CTCustomMenuItem(title: "Thẻ Học", subtitle: "Học cùng thẻ bài để rèn luyện trí nhớ", assetImage: "flash_card")
                    }
                    NavigationLink(destination: CTAllQuestions()){
                        CTCustomMenuItem(title: "100 Câu Hỏi", subtitle: "Xem tất cả câu hỏi và câu trả lời", assetImage: "book")
                    }
                    NavigationLink(destination: CTLearnQuestions()){
                        CTCustomMenuItem(title: "Học Dễ Nhớ", subtitle: "Học 100 câu hỏi theo từng phần",
                                         assetImage: "book_stack")
                    }
                }.listRowSpacing(30)
            }
        }
    }
}

struct CTHomeMenu_Provider: PreviewProvider{
    static var previews: some View{
        CTHomeMenu()
            .environmentObject(SelectedPart())
    }
}
