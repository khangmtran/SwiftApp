//
//  CTSetting.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 3/19/25.
//

import SwiftUI

struct CTSetting: View {
    @EnvironmentObject var userSetting: UserSetting
    @EnvironmentObject var deviceManager: DeviceManager
    @EnvironmentObject var govCapManager: GovCapManager
    @State private var showingZipPrompt = false
    
    var body: some View {
        List {
            Section("Đại diện của bạn"){
                HStack {
                    VStack(alignment: .leading) {
                        Text("ZIP Code")
                            .font(deviceManager.isTablet ? .title3 : .body)
                        Text("Mã ZIP")
                            .font(deviceManager.isTablet ? .footnote : .caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Text(userSetting.zipCode)
                        .font(deviceManager.isTablet ? .title3 : .body)
                    
                    Button(action: {
                        showingZipPrompt = true
                    }) {
                        Image(systemName: "pencil")
                            .imageScale(.medium)
                    }
                }
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("State")
                            .font(deviceManager.isTablet ? .title3 : .body)
                        Text("Tiểu Bang")
                            .font(deviceManager.isTablet ? .footnote : .caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Text(userSetting.state)
                        .font(deviceManager.isTablet ? .title3 : .body)
                }
                
                let senators = userSetting.legislators.filter { $0.type == "senator" }
                ForEach(senators) { senator in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Senator")
                                .font(deviceManager.isTablet ? .body : .subheadline)
                            Text("Thượng Nghị Sĩ")
                                .font(deviceManager.isTablet ? .footnote : .caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Text("\(senator.firstName) \(senator.lastName)")
                            .font(deviceManager.isTablet ? .body : .subheadline)
                            .fontWeight(.medium)
                    }
                }
                
                let representatives = userSetting.legislators.filter { $0.type == "representative" }
                ForEach(representatives) { rep in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Representative")
                                .font(deviceManager.isTablet ? .body : .subheadline)
                            Text("Hạ Nghị Sĩ")
                                .font(deviceManager.isTablet ? .footnote : .caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Text("\(rep.firstName) \(rep.lastName)")
                            .font(deviceManager.isTablet ? .body : .subheadline)
                            .fontWeight(.medium)
                    }
                }
                
                let stateInfo = govCapManager.govAndCap.filter { $0.state == userSetting.state }
                ForEach(stateInfo) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Governor")
                                .font(deviceManager.isTablet ? .body : .subheadline)
                            Text("Thống Đốc")
                                .font(deviceManager.isTablet ? .footnote : .caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Text(item.gov)
                            .font(deviceManager.isTablet ? .body : .subheadline)
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Capital City")
                                .font(deviceManager.isTablet ? .body : .subheadline)
                            Text("Thủ Phủ")
                                .font(deviceManager.isTablet ? .footnote : .caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Text(item.capital)
                            .font(deviceManager.isTablet ? .body : .subheadline)
                            .fontWeight(.medium)
                    }
                }
        
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingZipPrompt) {
                CTZipInput()
                    .environmentObject(userSetting)
                    .environmentObject(deviceManager)
            }
        }
    }
}

#Preview {
    CTSetting()
        .environmentObject(UserSetting())
        .environmentObject(DeviceManager())
        .environmentObject(GovCapManager())
}
