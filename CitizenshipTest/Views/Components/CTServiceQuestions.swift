//
//  CTServiceQuestions.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 2/27/25.
//
import SwiftUI

struct ServiceQuestions: View {
    let questionId: Int
    @Binding var showingZipPrompt: Bool
    let govAndCap: [CTGovAndCapital]
    @EnvironmentObject var userSetting: UserSetting
    @EnvironmentObject var deviceManager: DeviceManager
    
    var body: some View {
        switch questionId {
        case 20:
            senatorView
        case 23:
            representativeView
        case 43:
            governorView
        case 44:
            capitalView
        default:
            Text("")
        }
    }
    
    private var senatorView: some View {
        VStack{
            let senators = userSetting.legislators.filter {$0.type == "senator"}
            ForEach(senators) { sen in
                Text("\(sen.firstName) \(sen.lastName)")
                    .font(deviceManager.isTablet ? .largeTitle : .title3)
                    .fontWeight(.bold)
            }
            Button(action: {
                showingZipPrompt = true
            }){
                Text("Nhập ZIP Code để tìm Senator của bạn")
                    .font(deviceManager.isTablet ? .largeTitle : .title3)
            }
            .buttonStyle(BorderlessButtonStyle())
            .padding(.vertical)
        }
    }
    
    private var representativeView: some View {
        VStack {
            let representatives = userSetting.legislators.filter {$0.type == "representative"}
            ForEach(representatives) { rep in
                Text("\(rep.firstName) \(rep.lastName)")
                    .font(deviceManager.isTablet ? .largeTitle : .title3)
                    .fontWeight(.bold)
            }
            Button(action: {
                showingZipPrompt = true
            }){
                Text("Nhập ZIP Code để tìm Representative của bạn")
                    .font(deviceManager.isTablet ? .largeTitle : .title3)
            }
            .buttonStyle(BorderlessButtonStyle())
            .padding(.vertical)
        }
    }
    
    private var governorView: some View {
        VStack {
            let state = userSetting.state
            ForEach(govAndCap) { gnc in
                if gnc.state == state{
                    Text("\(gnc.gov)")
                        .font(deviceManager.isTablet ? .largeTitle : .title3)
                        .fontWeight(.bold)
                }
            }
            Button(action: {
                showingZipPrompt = true
            }){
                Text("Nhập ZIP Code để tìm Governor của bạn")
                    .font(deviceManager.isTablet ? .largeTitle : .title3)
            }
            .buttonStyle(BorderlessButtonStyle())
            .padding(.vertical)
        }
    }
    
    private var capitalView: some View {
        VStack {
            let state = userSetting.state
            ForEach(govAndCap) { gnc in
                if gnc.state == state{
                    Text("\(gnc.capital)")
                        .font(deviceManager.isTablet ? .largeTitle : .title3)
                        .fontWeight(.bold)
                }
            }
            Button(action: {
                showingZipPrompt = true
            }){
                Text("Nhập ZIP Code để tìm Capital của bạn")
                    .font(deviceManager.isTablet ? .largeTitle : .title3)
            }
            .buttonStyle(BorderlessButtonStyle())
            .padding(.vertical)
        }
    }
}
