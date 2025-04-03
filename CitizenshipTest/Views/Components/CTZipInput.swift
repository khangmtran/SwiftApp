//
//  CTZipInput.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 2/8/25.
//
import SwiftUI

struct CTZipInput: View {
    @EnvironmentObject var userSetting: UserSetting
    @EnvironmentObject var deviceManager: DeviceManager
    @Environment(\.dismiss) private var dismiss
    @State private var tempZipCode: String = ""
    @State private var isTyping = false
    @State private var errorMsg = false
    @State private var errorText = "ZIP Code không hợp lệ, xin vui lòng nhập lại"
    private let geocodioService = CTGeocodioService()
    
    var body: some View {
        NavigationView {
            VStack {
                TextField(tempZipCode.isEmpty ? "Nhập ZIP Code" : "\(tempZipCode)", text: $tempZipCode)
                    .font(deviceManager.isTablet ? .largeTitle : .title3)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .padding()
                
                Button(action: {
                    Task {
                        isTyping = true
                        do {
                            let legislators = try await geocodioService.fetchLegislators(zipCode: tempZipCode)
                            errorMsg = false
                            await MainActor.run{
                                userSetting.state = legislators.first?.state ?? ""
                                userSetting.zipCode = tempZipCode
                                userSetting.legislators = legislators
                                dismiss()
                            }
                        } catch _ as URLError {
                            errorText = "Lỗi kết nối, xin vui lòng kiểm tra kết nối mạng"
                            errorMsg = true
                        } catch {
                            print("Error: \(error)")
                            errorText = "ZIP Code không hợp lệ, xin vui lòng nhập lại"
                            errorMsg = true
                        }
                        isTyping = false
                    }
                }){
                    Text("Tìm")
                        .font(deviceManager.isTablet ? .largeTitle : .title3)
                }
                .disabled(tempZipCode.count != 5 || isTyping)
                
                if errorMsg{
                    Text(errorText)
                        .font(deviceManager.isTablet ? .largeTitle : .title3)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.red)
                        .padding()
                }
                
                if isTyping {
                    ProgressView()
                }
            }
            .navigationTitle("Tìm Đại Diện")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }){
                        Text("Huỷ")
                        .font(deviceManager.isTablet ? .title : .body)
                    }
                }
            }
        }
        .onAppear {
            tempZipCode = userSetting.zipCode
        }
    }
}

#Preview{
    CTZipInput()
        .environmentObject(UserSetting())
        .environmentObject(DeviceManager())
}

