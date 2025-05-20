//
//  CTRemoveAdsView.swift
//  CitizenshipTest
//
//  Created on 5/8/25.
//

import SwiftUI
import StoreKit

struct CTRemoveAdsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var storeManager: StoreManager
    @State private var isPurchasing = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    private let removeAdsProductID = "K.CitizenshipTest.removeads"
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    Image(systemName: "heart.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                        .padding(.top, 20)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Cảm ơn bạn đã ủng hộ ứng dụng Học Thi Quốc Tịch. Sự đóng góp của bạn sẽ giúp chúng tôi có thể tiếp tục phát triển và cải thiện ứng dụng.")
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Text("Việc mua gói Loại Bỏ Quảng Cáo sẽ giúp bạn:")
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            FeatureRow(text: "Học tập không bị gián đoạn")
                            FeatureRow(text: "Loại bỏ tất cả quảng cáo")
                            FeatureRow(text: "Hỗ trợ phát triển ứng dụng")
                        }
                        .padding(.horizontal)
                    }
                    
                    if let product = storeManager.products.first(where: { $0.id == removeAdsProductID }) {
                        if storeManager.isPurchased(removeAdsProductID) {
                            VStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.green)
                            }
                        } else {
                            Button(action: {
                                purchaseProduct(product)
                            }) {
                                HStack {
                                    Text("Loại Bỏ Quảng Cáo")
                                    
                                    Spacer()
                                    
                                    if isPurchasing {
                                        ProgressView()
                                            .padding(.leading, 5)
                                    } else {
                                        Text(product.displayPrice)
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.horizontal)
                            }
                            .disabled(isPurchasing)
                            
                            VStack{
                                Text("Nếu bạn đã mua và cần khôi phục sản phẩm")
                                    .fontWeight(.semibold)
                                    .multilineTextAlignment(.center)
                                
                                Button(action: {
                                    Task {
                                        isPurchasing = true
                                        await storeManager.updatePurchasedProducts()
                                        if storeManager.isPurchased(removeAdsProductID) {
                                            alertMessage = "Khôi phục thành công!"
                                        } else {
                                            alertMessage = "Không tìm thấy gói đã mua. Vui lòng đảm bảo bạn đang sử dụng đúng tài khoản đã mua."
                                        }
                                        
                                        isPurchasing = false
                                        showAlert = true
                                    }
                                }) {
                                    HStack {
                                        Text("Khôi Phục")
                                        
                                        if isPurchasing {
                                            ProgressView()
                                                .padding(.leading, 5)
                                        }
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
                                .disabled(isPurchasing)
                                .padding(.horizontal)
                            }
                            
                        }
                    } else {
                        VStack {
                            
                            Text("Không thể tải thông tin sản phẩm")
                                .font(.headline)
                                .foregroundColor(.red)
                            
                            //                                if let error = storeManager.loadError {
                            //                                    Text(error)
                            //                                        .font(.caption)
                            //                                        .foregroundColor(.red)
                            //                                        .multilineTextAlignment(.center)
                            //                                        .padding(.horizontal)
                            //                                }
                            
                            
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Nâng Cấp Ứng Dụng")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Đóng") {
                        dismiss()
                    }
                }
            }
            .alert(alertMessage, isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            }
        }
    }
    
    private func purchaseProduct(_ product: Product) {
        isPurchasing = true
        
        Task {
            await storeManager.purchase(product)
            
            if storeManager.isPurchased(product.id) {
                alertMessage = "Cảm ơn bạn đã mua! Tất cả quảng cáo đã được loại bỏ!"
            } else {
                alertMessage = "Giao dịch chưa hoàn tất. Vui lòng thử lại sau."
            }
            
            isPurchasing = false
            showAlert = true
        }
    }
}

struct FeatureRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .padding(.top, 3)
            
            Text(text)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    CTRemoveAdsView()
        .environmentObject(StoreManager())
}
