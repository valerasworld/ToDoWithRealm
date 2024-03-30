//
//  ListsView.swift
//  ToDoWithRealm
//
//  Created by Валерий Зазулин on 28.03.2024.
//

import SwiftUI
import RealmSwift

struct ListsView: View {
    @ObservedResults(ListOfToDos.self) var listsOfToDos
    @FocusState private var isFocused: Bool?
        
//    @EnvironmentObject var store: Store
    
    var body: some View {
        NavigationStack {
            VStack {
                if listsOfToDos.isEmpty {
                    Group {
                        Text("Tap on the ")
                        + Text("\(Image(systemName: "plus.circle.fill")) ")
                            .foregroundStyle(Color.accentColor)
                        + Text("button above\nto create a new List.")
                    }
                    .foregroundStyle(Color.secondary)
                } else {
                    List {
                        ForEach(listsOfToDos.sorted(byKeyPath: "name")) { list in
                            NavigationLink {
                                ToDoListView(listOfToDos: list)
                            } label: {
                                ListRowView(listOfToDos: list, isFocused: _isFocused)
                            }
                        }
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                }
                Spacer()
            }
            .animation(.default, value: listsOfToDos)
            .navigationTitle("My ToDo Lists")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        $listsOfToDos.append(ListOfToDos())
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        //
                    } label: {
                        Image(systemName: "cart.fill")
                            .font(.title2)
                    }
                }
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
}

#Preview {
    ListsView()
        .environmentObject(Store())
}
