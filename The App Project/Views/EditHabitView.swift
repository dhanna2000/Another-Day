import SwiftUI

struct EditHabitView: View {
    @Environment(\.presentationMode) private var presentation
    var habit: HabitItem
    var saveAction: (HabitItem) -> Void

    @State private var name        : String
    @State private var timeOfDay   : TimeOfDay
    @State private var selectedDays: Set<Weekday>

    init(habit: HabitItem, saveAction: @escaping (HabitItem) -> Void) {
        self.habit      = habit
        self.saveAction = saveAction
        _name        = State(initialValue: habit.name)
        _timeOfDay   = State(initialValue: habit.timeOfDay)
        _selectedDays = State(initialValue: Set(habit.selectedDays))
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Habit") {
                    TextField("Name", text: $name)
                }
                Section("Select Days") {
                    ForEach(Weekday.allCases) { day in
                        Toggle(day.displayName, isOn: Binding(
                            get: { selectedDays.contains(day) },
                            set: { isOn in
                                if isOn { selectedDays.insert(day) }
                                else    { selectedDays.remove(day) }
                            }
                        ))
                    }
                }
                Section("Time of Day") {
                    Picker("Time", selection: $timeOfDay) {
                        ForEach(TimeOfDay.allCases) { t in
                            Text(t.displayName).tag(t)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Edit Habit")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentation.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let updated = HabitItem(
                            id: habit.id,
                            name: name,
                            selectedDays: Array(selectedDays).sorted(by: { $0.rawValue < $1.rawValue }),
                            timeOfDay: timeOfDay
                        )
                        saveAction(updated)
                        presentation.wrappedValue.dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || selectedDays.isEmpty)
                }
            }
        }
    }
}

