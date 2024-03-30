////
////  PayWallView.swift
////  ToDoWithRealm
////
////  Created by Валерий Зазулин on 28.03.2024.
////
//
//import SwiftUI
//import StoreKit
//
//struct PayWallView: View {
//    
//    @StateObject var store = Store()
//    
//    var body: some View {
//        VStack {
//            ForEach(store.accessZones, id: \.id) { addition in
//                HStack {
//                    VStack(alignment: .leading) {
//                        Text(addition.displayName)
//                            .fontWeight(.medium)
//                        Text(addition.description)
//                            .font(.subheadline)
//                            .foregroundStyle(.secondary)
//                    }
//                    
//                    Spacer()
//                    
//                    Button {
//                        Task {
//                            try await store.purchase(addition)
//                        }
//                    } label: {
//                        StoreItem(store: store, product: addition)
//                    }
//                    
//                }
//                .padding((.horizontal))
//            }
////            
////            Button("Restore Purchases") {
////                Task {
////                    // This call displays a system prompt that asks users to authenticate with their AppStore credentials.
////                    // Call this function only in response to an explicit user action, such as tapping a button.
////                    try? await AppStore.sync()
////                }
////            }
//            AccessZonesStoreView(store: store)
//        }
//    }
//}
//
//struct StoreItem: View {
//    
//    @ObservedObject var store: Store
//    @State var isPurchased: Bool = false
//    var product: Product
//    
//    var body: some View {
//        VStack {
//            ZStack {
//                Capsule()
//                    .fill(isPurchased ? .green : .accentColor)
//                
//                if isPurchased {
//                    Text(Image(systemName: "checkmark"))
//                        .foregroundStyle(.white)
//                        .bold()
//                        .padding(10)
//                } else {
//                    Text(product.displayPrice)
//                        .foregroundStyle(.white)
//                        .padding(10)
//                }
//            }
//            .frame(width: 80, height: 40)
//            .onChange(of: store.purchasedAdditions) { purchasedProduct in
//            Task {
//                isPurchased = (try? await store.isPurchased(product)) ?? false
//            }
//        }
//        }
//
//    }
//}
//
//#Preview {
//    PayWallView()
//}
//
