//
//  ContentView.swift
//  ToDoWithRealm
//
//  Created by Валерий Зазулин on 27.03.2024.
//

import SwiftUI
import RealmSwift

struct ToDoListView: View {
    @ObservedRealmObject var listOfToDos: ListOfToDos
    @State private var name = ""
    @State private var searchFilter = ""
    @FocusState private var isFocused: Bool?
    
    var body: some View {
        VStack {
            HStack {
                TextField("New ToDo", text: $name)
                    .focused($isFocused, equals: true)
                    .textFieldStyle(.roundedBorder)
                
                Button {
                    let newToDo = ToDo(name: name)
                    $listOfToDos.toDos.append(newToDo)
                    name = ""
                    isFocused = nil
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
                .disabled(name.isEmpty)
            }
            .padding()
            
            List {
                // ForEach(toDos.sorted(byKeyPath: "isCompleted")) { toDo in
                ForEach(listOfToDos.toDos/*.sorted(by: [*/
//                    SortDescriptor(keyPath: "isCompleted"),
//                    SortDescriptor(keyPath: "urgency", ascending: false)
                /*])*/) { toDo in
                    ToDoListRow(toDo: toDo)
                }
                .onDelete(perform: $listOfToDos.toDos.remove)
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
//            .searchable(
//                text: $searchFilter,
//                collection: $listOfToDos.toDos,
//                keyPath: \.name) {
//                    ForEach(listOfToDos.toDos) { toDo in
//                        Text(toDo.name)
//                            .searchCompletion(toDo.name)
//                    }
//                }
        }
        .animation(.default, value: listOfToDos.toDos)
        .navigationTitle(listOfToDos.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button {
                        isFocused = nil
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                    }
                }
            }
        }
    }
}


#Preview {
    ToDoListView(listOfToDos: ListOfToDos(name: "Shopping List"))
}
