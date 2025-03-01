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
    @EnvironmentObject var userSetting: UserSetting
    @EnvironmentObject var starredQuestions: StarredQuestions
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
                        .environmentObject(deviceManager)
                        .environmentObject(userSetting)
                        .environmentObject(starredQuestions)
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
            .environmentObject(UserSetting())
            .environmentObject(StarredQuestions())
    }
}

struct CTBotButton: View{
    let title: String?
    let icon: String?
    let backgroundColor: Color
    let foregroundColor: Color
    let cornerRadius: CGFloat
    let action: (() -> Void)?
    let width: CGFloat?
    let height: CGFloat?
    
    
    init(title: String? = nil, icon: String? = nil,
         action: (() -> Void)? = nil, width: CGFloat? = nil, height: CGFloat? = nil){
        self.title = title
        self.icon = icon
        self.backgroundColor = .blue
        self.foregroundColor = .white
        self.cornerRadius = 10
        self.action = action
        self.width = width
        self.height = height
    }
    
    var body: some View {
        if let action = action {
            Button(action: action) {
                buttonContent
            }
            .padding()
            .frame(width: width, height: height)
            .foregroundColor(foregroundColor)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
        } else {
            buttonContent
                .padding()
                .frame(width: width, height: height)
                .foregroundColor(foregroundColor)
                .background(backgroundColor)
                .cornerRadius(cornerRadius)
        }
    }
    
    private var buttonContent: some View {
        HStack {
            if let icon = icon {
                Image(systemName: icon)
            }
            if let title = title {
                Text(title)
                
            }
        }
    }
}

