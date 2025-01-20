//
//  CTHomeMenu.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 1/19/25.
//
import SwiftUI

struct CTHomeMenu : View{
    var body: some View{
        NavigationView{
            List{
                NavigationLink(destination: CTGetStarted()){
                    
                }
            }
        }
    }
}

struct CTHomeMenu_Provider: PreviewProvider{
    static var previews: some View{
        CTHomeMenu()
    }
}
