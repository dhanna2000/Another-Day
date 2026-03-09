import SwiftUI

struct TodoListView: View {
    @EnvironmentObject private var vm: TodoViewModel
    @State private var showingAddTask = false
    @State private var selection: Period = .week

    enum Period: String, CaseIterable, Identifiable {
        case week = "This Week"
        case month = "This Month"
        var id: String { rawValue }
    }

    var body: some View {
        NavigationView {
            VStack {
                Picker("Period", selection: $selection) {
                    ForEach(Period.allCases) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                List(tasksForSelectedPeriod) { task in
                    TaskRow(task: task)
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTask = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView()
                    .environmentObject(vm)
            }
        }
    }

    // MARK: - Data
    private var tasksForSelectedPeriod: [TaskItem] {
        switch selection {
        case .week:
            return weeklyTasks
        case .month:
            return monthlyTasks
        }
    }

    private var weeklyTasks: [TaskItem] {
        let currentWeek = Calendar.current.component(.weekOfYear, from: Date())
        return vm.tasks.filter {
            Calendar.current.component(.weekOfYear, from: $0.dueDate) == currentWeek
        }
    }

    private var monthlyTasks: [TaskItem] {
        let now = Date()
        let comps = Calendar.current.dateComponents([.year, .month], from: now)
        return vm.tasks.filter {
            let dcomps = Calendar.current.dateComponents([.year, .month], from: $0.dueDate)
            return dcomps.year == comps.year && dcomps.month == comps.month
        }
    }
}

struct TaskRow: View {
    @EnvironmentObject private var vm: TodoViewModel
    var task: TaskItem

    var body: some View {
        HStack {
            Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                .onTapGesture { vm.toggle(task) }
                .foregroundColor(task.isDone ? .green : .secondary)
            Text(task.title)
        }
    }
}

struct TodoListView_Previews: PreviewProvider {
    static var previews: some View {
        TodoListView()
            .environmentObject(TodoViewModel())
    }
}

