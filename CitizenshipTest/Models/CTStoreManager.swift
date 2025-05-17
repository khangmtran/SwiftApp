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

    private let productIDs = ["K.CitizenshipTest.removeads"]

    init() {
        Task {
            await fetchProducts()
            //await updatePurchasedProducts()
        }
    }

    func fetchProducts() async {
        do {
            print("Fetching products with IDs: \(productIDs)")
            products = try await Product.products(for: productIDs)
            print("Fetched \(products.count) products")
            
            if products.isEmpty {
                loadError = "No products found. Please check your App Store Connect configuration."
                print("No products found!")
            }
        } catch {
            loadError = "Failed to fetch products: \(error.localizedDescription)"
            print("Failed to fetch products: \(error)")
        }
    }

    func purchase(_ product: Product) async {
        do {
            print("Attempting to purchase: \(product.id)")
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                print("Purchase successful, verifying...")
                if case .verified(let transaction) = verification {
                    print("Transaction verified: \(transaction.productID)")
                    purchasedProductIDs.insert(transaction.productID)
                    await transaction.finish()
                    print("Transaction finished, product unlocked")
                } else {
                    print("Transaction verification failed")
                }
            case .userCancelled:
                print("Purchase cancelled by user")
            case .pending:
                print("Purchase pending further action")
            default:
                print("Other purchase result")
            }
        } catch {
            print("Purchase failed with error: \(error.localizedDescription)")
        }
    }

    func updatePurchasedProducts() async {
        print("Checking for existing purchases...")
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                print("Found verified purchase: \(transaction.productID)")
                purchasedProductIDs.insert(transaction.productID)
            }
        }
        print("Finished checking purchases. Found \(purchasedProductIDs.count) purchased products")
    }

    func isPurchased(_ productID: String) -> Bool {
        let result = purchasedProductIDs.contains(productID)
        print("Checking if product \(productID) is purchased: \(result)")
        return result
    }
    
}
