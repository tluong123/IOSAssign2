import SwiftUI
import Foundation

// Protocol to represent a task
protocol Task: Identifiable {
    var title: String { get }
    var description: String { get }
    var dueDate: Date { get }
    var isCompleted: Bool { get set }
    
    func complete()
    func isInProgress() -> Bool
}

// Class to represent a basic task
struct BasicTask: Identifiable { // Conforming to Identifiable
    var id = UUID() // Unique identifier
    var title: String
    var description: String
    var dueDate: Date
    var isCompleted: Bool = false
    
    init(title: String, description: String, dueDate: Date) {
        self.title = title
        self.description = description
        self.dueDate = dueDate
    }
    
    mutating func complete() {
        isCompleted = true
    }
    
    func isInProgress() -> Bool {
        return !isCompleted
    }
}

// Protocol for a task list
protocol TaskList {
    var tasks: [any Task] { get }
    
    func addTask(_ task: any Task)
    func removeTask(_ task: any Task)
}

// Class to represent a simple task list
class SimpleTaskList: ObservableObject {
    @Published var tasks: [BasicTask] = []
    
    func addTask(_ task: BasicTask) {
        tasks.append(task)
    }
    
    func removeTask(_ task: BasicTask) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks.remove(at: index)
        }
    }
}
struct AddTaskView: View {
    @ObservedObject var taskList: SimpleTaskList
    @Binding var isAddingTask: Bool
    @State private var newTaskTitle = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Task Title", text: $newTaskTitle)
                }
                
                Section {
                    Button("Add Task") {
                        if !newTaskTitle.isEmpty {
                            let newTask = BasicTask(title: newTaskTitle, description: "", dueDate: Date())
                            taskList.addTask(newTask)
                            newTaskTitle = ""
                            isAddingTask = false
                        }
                    }
                }
            }
            .navigationTitle("Add Task")
            .navigationBarItems(trailing: Button("Cancel") {
                isAddingTask = false
            })
        }
    }
}


struct ContentView: View {
    @ObservedObject var taskList: SimpleTaskList
    @State private var isAddingTask = false // Added to control the Add Task sheet

    var body: some View {
        NavigationView {
            
            List {
                ForEach(taskList.tasks.indices, id: \.self) { index in
                    let isCompleted = Binding(
                        get: { self.taskList.tasks[index].isCompleted },
                        set: { newValue in
                            self.taskList.tasks[index].isCompleted = newValue
                        }
                    )

                    HStack {
                        Button(action: {
                            // Toggle task completion
                            isCompleted.wrappedValue.toggle()
                        }) {
                            Image(systemName: isCompleted.wrappedValue ? "checkmark.square" : "square")
                                .imageScale(.large)
                        }

                        Text(taskList.tasks[index].title)
                            .strikethrough(isCompleted.wrappedValue, color: .gray)
                            .foregroundColor(isCompleted.wrappedValue ? .gray : .primary)
                    }
                }
                .onDelete { indexSet in
                    // Remove tasks when swiped and deleted
                    indexSet.forEach { index in
                        taskList.tasks.remove(at: index)
                    }
                }
            }
            .navigationTitle("Habit Breaker")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Task") {
                        isAddingTask.toggle() // Toggle the sheet
                    }
                }
            }
        }
        
        .sheet(isPresented: $isAddingTask) {
            AddTaskView(taskList: self.taskList, isAddingTask: self.$isAddingTask)
        }
    }
}







struct TaskApp: App {
    @StateObject var taskList = SimpleTaskList()

    var body: some Scene {
        WindowGroup {
            ContentView(taskList: taskList) // Pass the taskList parameter here
        }
    }
}

