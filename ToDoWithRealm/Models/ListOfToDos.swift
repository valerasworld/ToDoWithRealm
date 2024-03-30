//
//  ListOfToDos.swift
//  ToDoWithRealm
//
//  Created by Валерий Зазулин on 28.03.2024.
//

import Foundation
import RealmSwift

class ListOfToDos: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var name: String
    @Persisted var toDos: List<ToDo>
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
}
