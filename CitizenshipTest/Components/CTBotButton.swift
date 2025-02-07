//
//  CTButton.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 1/18/25.
//
import SwiftUI

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
