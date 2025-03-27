//
//  CTMenuItem.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 3/26/25.
//

import SwiftUI

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
                        .foregroundStyle(Color.primary.opacity(0.7))
                } else if let assetImage = assetImage{
                    Image(assetImage)
                        .resizable()
                        .scaledToFit()
                }
            }
            .frame(width: deviceManager.isTablet ? 150 : 75)
            
            VStack(){
                Text(title)
                    .font(deviceManager.isTablet ? .title3 : .body)
                    .fontWeight(.bold)
                    .fixedSize(horizontal: false, vertical: true)
                Text(subtitle)
                    .font(deviceManager.isTablet ? .body : .subheadline)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }
}
