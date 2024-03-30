//
//  SubscriptionsView.swift
//  ToDoWithRealm
//
//  Created by Валерий Зазулин on 29.03.2024.
//

//import SwiftUI
//import StoreKit
//
//struct SubscriptionsView: View {
//    
//    @EnvironmentObject var store: Store
//    
//    @State var currentSubscription: Product?
//    @State var status: Product.SubscriptionInfo.Status?
//    
//    var availableSubscriptions: [Product] {
//        store.subscriptions.filter { $0.id != currentSubscription?.id }
//    }
//    
//    var body: some View {
//        Text("Hello, World!")
//    }
//    
//    @MainActor
//    func updateSubscriptionStatus() async {
//        do {
//            //This app has only one subscription group, so products in the subscriptions
//            //array all belong to the same group. The statuses that
//            //`product.subscription.status` returns apply to the entire subscription group.
//            guard let product = store.purchasedSubscriptions.first,
//                  let statuses = try await product.subscription?.status else {
//                return
//            }
//            
//            // iterate throug each status to get the highest one
//            var highestStatus: Product.SubscriptionInfo.Status? = nil
//            var highestProduct: Product? = nil
//            
//            for status in statuses {
//                switch status.state {
//                    // we are not interested in these results and can skip them
//                case .expired, .revoked:
//                    continue
//                    // otherwise we need to get the renewalInfo and check if it's verified
//                default:
//                    let renewalInfo = try store.checkVerified(status.renewalInfo)
//                    
//                    guard let newSubscription = store.subscriptions.first(where: { $0.id == renewalInfo.currentProductID }) else {
//                        continue
//                    }
//                    
//                    // Get the highest product we've already seen, if any
//                    guard let currentProduct = highestProduct else {
//                        highestStatus = status
//                        highestProduct = newSubscription
//                        continue
//                    }
//                    
//                    // Get the tier for each product we've seen
//                    let highestTier = store.tier(for: currentProduct.id)
//                    let newTier = store.tier(for: renewalInfo.currentProductID)
//                    
//                    // Compare this tier with the previous highest tier
//                    if newTier > highestTier {
//                        highestStatus = status
//                        highestProduct = newSubscription
//                    }
//                }
//            }
//            // update the View
//            status = highestStatus
//            currentSubscription = highestProduct
//            
//        } catch {
//            print("Could not update subscription status \(error)")
//        }
//    }
//}
//
//#Preview {
//    SubscriptionsView(availableSubscriptions: [])
//}
