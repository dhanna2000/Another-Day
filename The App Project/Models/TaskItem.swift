import Foundation

struct TaskItem: Identifiable, Codable {
    let id: UUID
    let title: String
    let dueDate: Date
    var isDone: Bool

    init(id: UUID = UUID(), title: String, dueDate: Date, isDone: Bool = false) {
        self.id = id
        self.title = title
        self.dueDate = dueDate
        self.isDone = isDone
    }

    var weekOfYear: Int { Calendar.current.component(.weekOfYear, from: dueDate) }
    var month:      Int { Calendar.current.component(.month,      from: dueDate) }
    var year:       Int { Calendar.current.component(.year,       from: dueDate) }
}
