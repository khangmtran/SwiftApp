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
    @Published var loadError: String? = nil

    private let productIDs = ["KnT.CitizenshipTest.removeAds"]

    init() {
        Task {
            await fetchProducts()
            await listenForTransactions()
        }
    }

    func fetchProducts() async {
        do {
            products = try await Product.products(for: productIDs)
        } catch {
            #if DEBUG
            print("Failed to fetch products: \(error)")
            #endif
        }
    }

    func listenForTransactions() async {
        for await verificationResult in Transaction.updates {
            if case .verified(let transaction) = verificationResult {
                purchasedProductIDs.insert(transaction.productID)
                await transaction.finish()
            }
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
            default:
#if DEBUG
                print("purchase error")
#endif
            }
        } catch {
            #if DEBUG
            print("Purchase failed with error: \(error.localizedDescription)")
            #endif
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
        let result = purchasedProductIDs.contains(productID)
        return result
    }
    
}
