import Foundation

@MainActor
class TodoViewModel: ObservableObject {
    @Published var tasks: [TaskItem] = []

    private let fileURL: URL = {
        let docs = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
        return docs.appendingPathComponent("tasks.json")
    }()

    init() {
        Task {
            await loadTasks()
        }
    }

    /// Load saved tasks from disk (off the main actor) then assign back on main
    private func loadTasks() async {
        let data = await Task.detached { () -> Data? in
            try? Data(contentsOf: self.fileURL)
        }.value

        guard
            let data,
            let decoded = try? JSONDecoder().decode([TaskItem].self, from: data)
        else { return }

        // assign on main actor
        tasks = decoded
    }

    /// Save current tasks array to disk asynchronously
    private func saveTasks() {
        let snapshot = tasks
        Task.detached {
            guard let data = try? JSONEncoder().encode(snapshot) else { return }
            try? data.write(to: self.fileURL, options: [.atomicWrite])
        }
    }

    /// Toggle completion state of a given task
    func toggle(_ task: TaskItem) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].isDone.toggle()
        saveTasks()
    }

    /// Add a new task with title and due date
    func addTask(title: String, dueDate: Date) {
        let newTask = TaskItem(title: title, dueDate: dueDate)
        tasks.append(newTask)
        saveTasks()
    }
}

