//
//  StoreKitManager.swift
//  ToDoWithRealm
//
//  Created by Валерий Зазулин on 28.03.2024.
//

import SwiftUI
import StoreKit

class Store: ObservableObject {
    
    @Published private(set) var additions: [Product] = []
    @Published private(set) var accessZones: [Product] = []
    @Published private(set) var subscriptions: [Product] = []
    
    @Published private(set) var purchasedAdditions: [Product] = []
    @Published private(set) var purchasedAccessZones: [Product] = []
    @Published private(set) var purchasedSubscriptions: [Product] = []
    @Published private(set) var subscriptionGroupStatus: StoreKit.Product.SubscriptionInfo.RenewalState?
    
    var updateListenerTask: Task<Void, Error>? = nil
    
    private let productDict: [String : String]
    
    init() {
        
        //Initialize empty products, and then do a product request asynchronously to fill them in.
        additions = []
        accessZones = []
        subscriptions = []
        
        // check the path for the plist
        if let plistPath = Bundle.main.path(forResource: "PropertyList", ofType: "plist"),
           // get the list of products
        let plist = FileManager.default.contents(atPath: plistPath) {
            productDict = (try? PropertyListSerialization.propertyList(from: plist, format: nil) as? [String : String]) ?? [:]
        } else {
            productDict = [:]
        }
        
        // Listen for updates since the store is created
        updateListenerTask = listenerForTransactions()
        
        Task {
            await requestProducts()
            await updateCustomerProductStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    func listenerForTransactions() -> Task<Void, Error> {
        return Task.detached {
            // iterate through any transactions that don't come from a direct call to 'purchase()'
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    
                    // the transaction is verified, deliver the content to the user
                    await self.updateCustomerProductStatus()
                    
                    // always finish a transaction
                    await transaction.finish()
                } catch {
                    // StoreKit has a transaction that fails verification, don't deliver content to the user
                    print("Transaction failed varification")
                }
            }
        }
    }
    
    @MainActor
    func requestProducts() async {
        do {
            // using the Product static method 'products' to retrieve the list of products
            let storeProducts = try await Product.products(for: productDict.values)
            
            // iterate the type if there are multiple product types
            // .consumable
            var newAdditions: [Product] = []
            // .nonConsumable
            var newAccessZones: [Product] = []
            // .autoRenewable
            var newSubscriptions: [Product] = []
            
            for product in storeProducts {
                switch product.type {
                case .consumable:
                    newAdditions.append(product)
                case .nonConsumable:
                    newAccessZones.append(product)
                case .autoRenewable:
                    newSubscriptions.append(product)
                default:
                    print("Unknown product")
                }
            }
            
            // Sort each product category by price to update the store
            additions = sortByPrice(newAdditions)
            accessZones = sortByPrice(newAccessZones)
            subscriptions = sortByPrice(newSubscriptions)
        } catch {
            print("Failed product request from the App Store server: \(error)")
        }
    }
    
    // calls the product purchase and returns an optional Transaction?
    func purchase(_ product: Product) async throws -> StoreKit.Transaction? {
        // make a purchase request - optional parameters available
        let result = try await product.purchase()
        
        // check the results
        switch result {
        case .success(let verificationResult):
            // Transaction will be verified automatically using JWT(jwsRepresentation) - we can check the result
            let transaction = try checkVerified(verificationResult)
            
            // the transaction is verified, deliver content to the user
            await updateCustomerProductStatus()
            
            // always finish a transaction
            await transaction.finish()

            // return transaction to update the UI
            return transaction
        case .userCancelled, .pending:
            return nil
        default:
            return nil
        }
        
    }
    
    // Generics - check the verificationResults
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        // check if JWS passes the StoreKit verification
        switch result {
        case .unverified:
            // failed verification
            throw StoreError.failedVerification
        case .verified(let signedType):
            // the result is verified, return the wrapped value
            return signedType
        }
    }
    
    @MainActor
    func updateCustomerProductStatus() async {
        var purchasedAccessZones: [Product] = []
        var purchasedSubscriptions: [Product] = []
        
        // iterate through all the user's purchased products
        for await result in Transaction.currentEntitlements {
            do {
                // again check if transaction is verified
                let transaction = try checkVerified(result)
                //Check the `productType` of the transaction and get the corresponding product from the store.
                switch transaction.productType {
                case .nonConsumable:
                    if let accessZone = accessZones.first(where: { $0.id == transaction.productID }) {
                        purchasedAccessZones.append(accessZone)
                    }
                case .autoRenewable:
                    if let subscription = subscriptions.first(where: { $0.id == transaction.productID }) {
                        purchasedSubscriptions.append(subscription)
                    }
                default:
                    break
                }
            } catch {
                // StoreKit has a transaction that fails verification, don't deliver content to the user
                print("Transaction failed varification")
            }
            
            //Update the store information with the purchased products.
            self.purchasedAccessZones = purchasedAccessZones
            //Update the store information with auto-renewable subscription products.
            self.purchasedSubscriptions = purchasedSubscriptions
            
            //Check the `subscriptionGroupStatus` to learn the auto-renewable subscription state to determine whether the customer
            //is new (never subscribed), active, or inactive (expired subscription). This app has only one subscription
            //group, so products in the subscriptions array all belong to the same group. The statuses that
            //`product.subscription.status` returns apply to the entire subscription group.
            subscriptionGroupStatus = try? await subscriptions.first?.subscription?.status.first?.state
        }
    }
    
    // check if product has already been purchased
    func isPurchased(_ product: Product) async throws -> Bool {
        //Determine whether the user purchases a given product.
        switch product.type {
        case .nonConsumable:
            return purchasedAccessZones.contains(product)
        case .autoRenewable:
            return purchasedSubscriptions.contains(product)
        default:
            return false
        }
    }
    
    func isPurchased(_ productIdentifier: String) async throws -> Bool {
        // 'latest' method returns the latest transaction to check if it's verified
        guard let result = await Transaction.latest(for: productIdentifier) else {
            // The user hasn't purchased this product.
            return false
        }
        
        let transaction = try checkVerified(result)
        
        // check if transaction was refunded so as not to deliver it by checking 'revocationDate' == nil
        // and ignore 'isUpgraded' transactions to deliver the highest level of subscription
        return transaction.revocationDate == nil && !transaction.isUpgraded
    }
    
    func sortByPrice(_ products: [Product]) -> [Product] {
        return products.sorted { $0.price < $1.price }
    }
    
    //Get a subscription's level of service using the product ID.
    func tier(for productId: String) -> SubscriptionTier {
        switch productId {
        case "Full Access (Monthly)":
            return .monthly
        case "Full Access (Yearly)":
            return .yearly
        default:
            return .none
        }
    }
}

public enum StoreError: Error {
    case failedVerification
}

//Define the app's subscription tiers by level of service, in ascending order.
public enum SubscriptionTier: Int, Comparable {
    case none = 0
    case monthly = 1
    case yearly = 2

    public static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
