//
//  CTZipInput.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 2/8/25.
//
import SwiftUI
import GoogleMobileAds
import FirebaseCrashlytics

struct CTZipInput: View {
    @EnvironmentObject var userSetting: UserSetting
    @EnvironmentObject var storeManager: StoreManager
    @Environment(\.dismiss) private var dismiss
    @State private var tempZipCode: String = ""
    @State private var isTyping = false
    @State private var errorMsg = false
    @State private var errorText = "ZIP Code không hợp lệ, xin vui lòng nhập lại"
    private let geocodioService = CTGeocodioService()
    @StateObject private var networkMonitor = NetworkMonitor.shared
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                TextField(tempZipCode.isEmpty ? "Nhập ZIP Code" : "\(tempZipCode)", text: $tempZipCode)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .padding()
                
                Button(action: {
                    Crashlytics.crashlytics().log("User look for representative in zipInput")
                    guard userSetting.canSearchZip() else {
                        errorText = "Bạn đã đạt giới hạn 5 lần tìm kiếm mỗi ngày"
                        errorMsg = true
                        return
                    }
                    
                    Task {
                        isTyping = true
                        do {
                            let legislators = try await geocodioService.fetchLegislators(zipCode: tempZipCode)
                            errorMsg = false
                            await MainActor.run {
                                userSetting.incrementZipSearchCount()
                                userSetting.state = legislators.first?.state ?? ""
                                userSetting.zipCode = tempZipCode
                                userSetting.legislators = legislators
                                dismiss()
                            }
                        } catch _ as URLError {
                            errorText = "Lỗi kết nối, xin vui lòng kiểm tra kết nối mạng"
                            errorMsg = true
                        } catch {
                            errorText = "ZIP Code không hợp lệ, xin vui lòng nhập lại"
                            errorMsg = true
                        }
                        isTyping = false
                    }
                }) {
                    Text("Tìm")
                        .font(.title3)
                }
                .disabled(tempZipCode.count != 5 || isTyping)
                
                if errorMsg{
                    Text(errorText)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.red)
                        .padding()
                }
                
                Text("Bạn còn \(5 - userSetting.zipSearchCount) lần tìm kiếm trong hôm nay")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding()
                
                if isTyping {
                    ProgressView()
                }
                Spacer()
                               if !storeManager.isPurchased("KnT.CitizenshipTest.removeAds") && networkMonitor.isConnected {
                                   CTAdBannerView().frame(width: AdSizeBanner.size.width,
                                                          height: AdSizeBanner.size.height)
                               }
            }
            .navigationTitle("Tìm Đại Diện")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }){
                        Text("Huỷ")
                    }
                }
            }
        }
        .onAppear {
            tempZipCode = userSetting.zipCode
            Crashlytics.crashlytics().log("User went to ZipInput")
        }
    }
}

#Preview{
    CTZipInput()
        .environmentObject(UserSetting())
}

