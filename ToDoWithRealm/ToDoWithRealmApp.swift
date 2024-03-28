//
//  ToDoWithRealmApp.swift
//  ToDoWithRealm
//
//  Created by Валерий Зазулин on 27.03.2024.
//

import SwiftUI

@main
struct ToDoWithRealmApp: App {
    var body: some Scene {
        WindowGroup {
            ToDoListView()
                .onAppear {
                    print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path)
                    UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
                }
        }
    }
}
