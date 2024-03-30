////
////  StoreViwe.swift
////  ToDoWithRealm
////
////  Created by Валерий Зазулин on 28.03.2024.
////
//
//import SwiftUI
//import StoreKit
//
//struct AccessZonesStoreView: View {
//    
//    @ObservedObject var store: Store
//    @State var isPurchased: Bool = false
//    
//    var body: some View {
//        List {
//            ForEach(store.accessZones) { accessZone in
//                HStack {
//                    VStack(alignment: .leading) {
//                        Text(accessZone.displayName)
//                        Text(accessZone.description)
//                            .font(.subheadline)
//                            .foregroundStyle(.secondary)
//                    }
//                    
//                    Spacer()
//                    
//                    Button {
//                        Task {
//                            try await store.purchase(accessZone)
//                        }
//                    } label: {
//                        ZStack {
//                            Capsule()
//                                .fill(isPurchased ? .green : .accentColor)
//                            
//                            if isPurchased {
//                                Text(Image(systemName: "checkmark"))
//                                    .foregroundStyle(.white)
//                                    .bold()
//                                    .padding(10)
//                            } else {
//                                Text(accessZone.displayPrice)
//                                    .foregroundStyle(.white)
//                                    .padding(10)
//                            }
//                        }
//                        .frame(width: 80, height: 40)
//                    }
//                    .onChange(of: store.purchasedAccessZones) { purchasedAccessZone in
//                        Task {
//                            isPurchased = (try? await store.isPurchased(accessZone)) ?? false
//                        }
//                    }
//                }
//            }
//            
//        }
//        .listStyle(.insetGrouped)
//    }
//}
//
//#Preview {
//    AccessZonesStoreView(store: Store())
//}
//
//struct AccessZonesStoreCellView: View {
//    
//    @ObservedObject var store: Store
//    
//    
//    var body: some View {
//        HStack {
//            
//        }
//    }
//}
