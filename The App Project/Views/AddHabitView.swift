// Views/AddHabitView.swift

import SwiftUI

struct AddHabitView: View {
    @Binding var isPresented: Bool
    var addAction: (HabitItem) -> Void

    @State private var name        = ""
    @State private var timeOfDay   = TimeOfDay.morning
    @State private var selectedDays: Set<Weekday> = []

    var body: some View {
        NavigationView {
            Form {
                Section("Habit Name") {
                    TextField("Enter name", text: $name)
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
                    Picker("When", selection: $timeOfDay) {
                        ForEach(TimeOfDay.allCases) { tod in
                            Text(tod.displayName).tag(tod)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("New Habit")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let newHabit = HabitItem(
                            name: name,
                            selectedDays: Array(selectedDays).sorted(by: { $0.rawValue < $1.rawValue }),
                            timeOfDay: timeOfDay
                        )
                        addAction(newHabit)
                        isPresented = false
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || selectedDays.isEmpty)
                }
            }
        }
    }
}

struct AddHabitView_Previews: PreviewProvider {
    static var previews: some View {
        AddHabitView(isPresented: .constant(true)) { _ in }
    }
}
