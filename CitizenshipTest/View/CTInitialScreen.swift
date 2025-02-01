//
//  CTInitialScreen.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 1/19/25.
//

import SwiftUI

struct CTInitialScreen: View{
    @EnvironmentObject var selectedPart: SelectedPart
    @State private var showNewScreen = false
    var body: some View{
        VStack {
            Image("CTwelcome")
                .resizable()
                .scaledToFit()
            Text("Citizenship Study App")
                .font(.title.bold())
            Text("Ứng Dụng Học Thi Quốc Tịch Mỹ")
                .font(.title2.bold())
            Image("SOLwelcome")
                .resizable()
                .scaledToFit()
                .frame(height: 250)
                .padding(.bottom, 50)
            
            CTBotButton(title: "Bắt Đầu", action: {showNewScreen = true},
                        width: 125, height: 50)
            .fullScreenCover(isPresented: $showNewScreen){
                CTHomeMenu()
                    .environmentObject(selectedPart)
            }
            
        }
        .padding()
    }
}

struct CTInitialScreen_provider: PreviewProvider{
    static var previews: some View{
        CTInitialScreen()
            .environmentObject(SelectedPart())
    }
}
