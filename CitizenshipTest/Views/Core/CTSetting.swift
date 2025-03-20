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
            Section(header: Text("Thông tin cá nhân")) {
                HStack {
                    Text("ZIP Code")
                        .font(deviceManager.isTablet ? .title3 : .body)
                    Spacer()
                    Text(userSetting.zipCode.isEmpty ? "Chưa thiết lập" : userSetting.zipCode)
                        .font(deviceManager.isTablet ? .title3 : .body)
                        .foregroundColor(userSetting.zipCode.isEmpty ? .gray : .primary)
                    
                    Button(action: {
                        showingZipPrompt = true
                    }) {
                        Image(systemName: "pencil")
                            .imageScale(.medium)
                    }
                }
                
                if !userSetting.state.isEmpty {
                    HStack {
                        Text("Tiểu bang")
                            .font(deviceManager.isTablet ? .title3 : .body)
                        Spacer()
                        Text(userSetting.state)
                            .font(deviceManager.isTablet ? .title3 : .body)
                    }
                }
                
                if !userSetting.legislators.isEmpty {
                    Section(header: Text("Thượng nghị sĩ")) {
                        ForEach(userSetting.legislators.filter { $0.type == "senator" }) { senator in
                            Text("\(senator.firstName) \(senator.lastName)")
                                .font(deviceManager.isTablet ? .title3 : .body)
                        }
                    }
                    
                    Section(header: Text("Hạ nghị sĩ")) {
                        ForEach(userSetting.legislators.filter { $0.type == "representative" }) { rep in
                            Text("\(rep.firstName) \(rep.lastName)")
                                .font(deviceManager.isTablet ? .title3 : .body)
                        }
                    }
                    
                    if !userSetting.state.isEmpty {
                        let govAndCap = govCapManager.govAndCap.filter { $0.state == userSetting.state }
                        if !govAndCap.isEmpty {
                            Section(header: Text("Thống đốc")) {
                                ForEach(govAndCap) { item in
                                    Text(item.gov)
                                        .font(deviceManager.isTablet ? .title3 : .body)
                                }
                            }
                            
                            Section(header: Text("Thủ phủ")) {
                                ForEach(govAndCap) { item in
                                    Text(item.capital)
                                        .font(deviceManager.isTablet ? .title3 : .body)
                                }
                            }
                        }
                    }
                }
            }
            
            Section(header: Text("Về ứng dụng")) {
                HStack {
                    Text("Phiên bản")
                        .font(deviceManager.isTablet ? .title3 : .body)
                    Spacer()
                    Text("1.0.0")
                        .font(deviceManager.isTablet ? .title3 : .body)
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text("Thiết bị")
                        .font(deviceManager.isTablet ? .title3 : .body)
                    Spacer()
                    Text(deviceManager.isTablet ? "iPad" : "iPhone")
                        .font(deviceManager.isTablet ? .title3 : .body)
                        .foregroundColor(.gray)
                }
            }
        }
        .navigationTitle("Cài đặt")
        .sheet(isPresented: $showingZipPrompt) {
            CTZipInput()
                .environmentObject(userSetting)
                .environmentObject(deviceManager)
        }
    }
}

#Preview {
    CTSetting()
        .environmentObject(UserSetting())
        .environmentObject(DeviceManager())
        .environmentObject(GovCapManager())
}
