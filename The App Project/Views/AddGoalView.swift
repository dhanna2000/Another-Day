import SwiftUI

struct AddGoalView: View {
    @Binding var isPresented: Bool
    var onSave: (String) -> Void

    @State private var title: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("New Goal")) {
                    TextField("Enter goal", text: $title)
                }
                Section {
                    Button("Save") {
                        let trimmed = title.trimmingCharacters(in: .whitespaces)
                        if !trimmed.isEmpty {
                            onSave(trimmed)
                        }
                        isPresented = false
                    }
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Add Goal")
        }
    }
}

struct AddGoalView_Previews: PreviewProvider {
    @State static var showing = true
    static var previews: some View {
        AddGoalView(isPresented: $showing) { _ in }
    }
}
