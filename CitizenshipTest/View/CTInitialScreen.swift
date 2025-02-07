//
//  CTInitialScreen.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 1/19/25.
//

import SwiftUI

struct CTInitialScreen: View{
    @EnvironmentObject var selectedPart: SelectedPart
    @EnvironmentObject var deviceManager: DeviceManager
    @State private var showNewScreen = false
    var body: some View{
        VStack{
                Image("CTwelcome")
                    .resizable()
                    .scaledToFit()
            
                Text("Citizenship Study App")
                .multilineTextAlignment(.center)
                .bold()
                .fixedSize(horizontal: false, vertical: true)
            
                Text("Ứng Dụng Học Thi Quốc Tịch Mỹ")
                .multilineTextAlignment(.center)
                .bold()
                .fixedSize(horizontal: false, vertical: true)
            
                Image("SOLwelcome")
                    .resizable()
                    .scaledToFit()
                CTBotButton(title: "Bắt Đầu", action: {showNewScreen = true})
                .padding()
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
            .environmentObject(DeviceManager())
    }
}
