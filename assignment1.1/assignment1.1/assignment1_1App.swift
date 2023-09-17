//
//  assignment1_1App.swift
//  assignment1.1
//
//  Created by thomas on 15/9/2023.
//

import SwiftUI

@main
struct YourAppNameApp: App {
    @StateObject var taskList = SimpleTaskList()

    var body: some Scene {
        WindowGroup {
            ContentView(taskList: taskList)
        }
    }
}

