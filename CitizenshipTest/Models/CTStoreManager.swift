//
//  CTStoreManager.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 5/8/25.
//

import SwiftUI
import StoreKit

@MainActor
class StoreManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var purchasedProductIDs = Set<String>()

    private let productIDs = ["com.khangapp.unlockpremium"]

    init() {
        Task {
            await fetchProducts()
            await updatePurchasedProducts()
        }
    }

    func fetchProducts() async {
        do {
            products = try await Product.products(for: productIDs)
        } catch {
            print("Failed to fetch products: \(error)")
        }
    }

    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    purchasedProductIDs.insert(transaction.productID)
                    await transaction.finish()
                }
            case .userCancelled, .pending:
                break
            default:
                break
            }
        } catch {
            print("Purchase failed: \(error)")
        }
    }

    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                purchasedProductIDs.insert(transaction.productID)
            }
        }
    }

    func isPurchased(_ productID: String) -> Bool {
        purchasedProductIDs.contains(productID)
    }
}
