//
//  CTGetStarted.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 1/18/25.
//

import SwiftUI

struct CTGetStarted: View {
    @State private var selectedState: USState? = nil
    
    var body: some View{
        VStack(spacing: 50){
            Spacer().frame(height: 1)
            Text("Cảm ơn bạn đã chọn ứng dụng Học Thi Quốc Tịch Mỹ")
                .font(.system(size: 25).bold())
                .padding(.horizontal, 30)
                .multilineTextAlignment(.center)
            
            Text("Trước khi bắt đầu, xin mời bạn chọn tiểu bang nơi bạn đang sinh sống " +
            "để ứng dụng chọn ra câu hỏi phù hợp")
            .multilineTextAlignment(.center)
            .font(.system(size: 20))
            .padding(.horizontal, 10)
            
            Text("Chọn Tiểu Bang")
                .font(.title.bold())
            
            ScrollView{
                VStack{
                    ForEach(USAllStates.allStates){ state in
                        Text("\(state.name) (\(state.abbreviation))")
                            .font(.system(size: 20))
                            .padding(.bottom, 1)
                            .background(selectedState?.id == state.id ? Color.gray : nil)
                            .onTapGesture {
                                selectedState = state
                            }
                    }
                }
            }
            .frame(height: 115)
            
            CTBotButton(title: "Tiếp Tục", action: {print("get started")},
                        width: 125, height: 50)
            
            Spacer()
        }
    }
}

struct CTGetStarted_preview: PreviewProvider{
    static var previews: some View{
        CTGetStarted()
    }
}
