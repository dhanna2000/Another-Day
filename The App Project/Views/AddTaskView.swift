import SwiftUI

struct AddTaskView: View {
    @EnvironmentObject private var vm: TodoViewModel
    @Environment(\.presentationMode) private var presentationMode

    @State private var title: String = ""
    @State private var dueDate: Date = Date()

    var body: some View {
        NavigationView {
            Form {
                Section("Task Title") {
                    TextField("Enter title", text: $title)
                }

                Section("Due Date") {
                    DatePicker(
                        "Select date",
                        selection: $dueDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.compact)
                }
            }
            .navigationTitle("Add Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        vm.addTask(title: title, dueDate: dueDate)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskView()
            .environmentObject(TodoViewModel())
    }
}
