//
//  StoreView.swift
//  ToDoWithRealm
//
//  Created by Валерий Зазулин on 29.03.2024.
//

import SwiftUI
import StoreKit

struct StoreView: View {
    
    @EnvironmentObject var store: Store
    
    var body: some View {
        VStack {
            Section {
                VStack {
                    ForEach(store.accessZones) { accessZone in
                        NonConsumableStoreCellView(store: store, product: accessZone)
                    }
                }
            }
            Section {
                VStack {
                    ForEach(store.additions) { addition in
                        ConsumableStoreCellView(store: store, product: addition)
                    }
                }
            }
            
            
        }
    }
}

#Preview {
    StoreView()
        .environmentObject(Store())
}

struct NonConsumableStoreCellView: View {
    
    @ObservedObject var store: Store
    @State var isPurchased: Bool = false
    
    let product: Product
    @State var toDosAvailbale: Int = 10
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15.0)
                .stroke(lineWidth: 1.0)
                .frame(height: 80)
            HStack {
                VStack(alignment: .leading) {
                    Text(product.displayName)
                        .bold()
                    Text(product.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button {
                    Task {
                        try await store.purchase(product)
                    }
                } label: {
                    oneTimePurchaseButton
                }
                .onChange(of: store.purchasedAccessZones) { _, _ in
                    Task {
                        isPurchased = (try? await store.isPurchased(product)) ?? false
                    }
                }
                
                
            }
            .padding()
        }
        .padding(.horizontal)
    }
    
    var oneTimePurchaseButton: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 50)
                .stroke(lineWidth: 1)
                .fill(isPurchased ? .green : .accentColor)
            
            if isPurchased {
                Text(Image(systemName: "checkmark"))
                    .foregroundStyle(Color.green)
                    .bold()
                    .padding(10)
            } else {
                Text(product.displayPrice)
                    .foregroundStyle(Color.accentColor)
                    .padding(10)
            }
            
        }
        .frame(width: 80, height: 40)
    }
}

struct ConsumableStoreCellView: View {
    
    @ObservedObject var store: Store
    @State var isPurchased: Bool = false
    
    let product: Product
    @State var toDosAvailbale: Int = 10
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15.0)
                .stroke(lineWidth: 1.0)
                .frame(height: 80)
            HStack {
                VStack(alignment: .leading) {
                    Text(product.displayName)
                        .bold()
                    Text(product.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
//                    if product.type == .consumable {
//                        Text("Now available: \(product.id == "fivetodos" ? toDosAvailbale : 0)")
//                            .foregroundStyle(Color.accentColor)
//                    }
                }
                
                Spacer()
                
                Button {
                    Task {
                        try await store.purchase(product)
                    }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 50)
                            .stroke(lineWidth: 1)
                            .fill(isPurchased ? .green : .accentColor)
                        
                        if isPurchased {
                            Text(Image(systemName: "checkmark"))
                                .foregroundStyle(Color.green)
                                .bold()
                                .padding(10)
                        } else {
                            Text(product.displayPrice)
                                .foregroundStyle(Color.accentColor)
                                .padding(10)
                        }
                        
                    }
                    .frame(width: 80, height: 40)
                }
                .onChange(of: store.purchasedAccessZones) { _, _ in
                    Task {
                        isPurchased = (try? await store.isPurchased(product)) ?? false
                    }
                }
                
                
            }
            .padding()
        }
        .padding(.horizontal)
    }
}

