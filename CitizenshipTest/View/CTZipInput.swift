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
    private let geocodioService = CTGeocodioService()
    
    var body: some View {
        NavigationView {
            VStack {
                TextField(tempZipCode.isEmpty ? "Enter ZIP Code" : "\(tempZipCode)", text: $tempZipCode)
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
                                userSetting.zipCode = tempZipCode
                                userSetting.legislators = legislators
                                dismiss()
                            }
                        } catch {
                            print("Error: \(error)")
                            errorMsg = true
                        }
                        isTyping = false
                    }
                }){
                    Text("Save")
                        .font(deviceManager.isTablet ? .largeTitle : .title3)
                }
                .disabled(tempZipCode.count != 5 || isTyping)
                
                if errorMsg{
                    Text("ZIP Code khong hop le, xin vui long nhap lai")
                        .font(deviceManager.isTablet ? .largeTitle : .title3)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.red)
                        .padding()
                }
                
                if isTyping {
                    ProgressView()
                }
            }
            .navigationTitle("Enter ZIP Code")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }){
                        Text("Cancel")
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

