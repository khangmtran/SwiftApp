//
//  CTCustomMenuItem.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 1/19/25.
//

import SwiftUI

struct CTCustomMenuItem: Identifiable, View{
    let id = UUID()
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
            HStack(spacing: 30){
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
                .frame(width: 75)
                VStack{
                    Text(title)
                        .font(.system(size: 25, weight: .bold))
                    Text(subtitle)
                        .font(.system(size: 20))
                }
                
            }
            .frame(height: 100)
        }
}

