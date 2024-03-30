//
//  ListRowView.swift
//  ToDoWithRealm
//
//  Created by Валерий Зазулин on 28.03.2024.
//

import SwiftUI
import RealmSwift

struct ListRowView: View {
    @ObservedRealmObject var listOfToDos: ListOfToDos
    @FocusState var isFocused: Bool?
    
    var body: some View {
        HStack {
            TextField("New List", text: $listOfToDos.name)
                .focused($isFocused, equals: true)
                .textFieldStyle(.roundedBorder)
            Text("\(listOfToDos.toDos.count)")
                .foregroundStyle(listOfToDos.toDos.count > 0 ? Color.primary : Color.green)
        }
//        .padding()
        .frame(height: 30)
    }
}

#Preview {
    ListRowView(listOfToDos: ListOfToDos(name: "Shopping List"))
}
