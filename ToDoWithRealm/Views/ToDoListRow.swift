//
//  ToDoListRow.swift
//  ToDoWithRealm
//
//  Created by Валерий Зазулин on 27.03.2024.
//

import SwiftUI
import RealmSwift

struct ToDoListRow: View {
    @ObservedRealmObject var toDo: ToDo
    var body: some View {
        HStack {
            Button {
                $toDo.isCompleted.wrappedValue.toggle()
            } label: {
                Image(systemName: toDo.isCompleted ? "checkmark.circle" : "circle")
            }
            .buttonStyle(.plain)
            
            TextField("Update Todo", text: $toDo.name)
                .textFieldStyle(.roundedBorder)
            Spacer()
            Button {
                $toDo.urgency.wrappedValue = toDo.incrementUrgency()
            } label: {
                Text(toDo.urgency.text)
                    .padding(5)
                    .frame(width: 80)
                    .foregroundStyle(Color(.systemBackground))
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(toDo.urgency.color)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
    }
}

#Preview {
    ToDoListRow(toDo: ToDo(name: ""))
}
