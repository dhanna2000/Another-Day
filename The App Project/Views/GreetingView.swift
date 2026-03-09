import SwiftUI

// MARK: – Shared DateFormatter helper
extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
}

struct GreetingView: View {
    @Binding var showGreeting: Bool
    @AppStorage("lastGreetingDate") private var lastGreetingDate: String = ""

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Dynamic greeting
            Text(getGreeting())
                .font(.largeTitle)
                .bold()

            Spacer()

            // Continue button, lifted up
            Button(action: {
                let today = DateFormatter.yyyyMMdd.string(from: Date())
                lastGreetingDate = today
                showGreeting = false
            }) {
                Text("Continue")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            .padding(.bottom, 80)
        }
    }

    private func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:   return "Good Morning"
        case 12..<17:  return "Good Afternoon"
        default:       return "Good Evening"
        }
    }
}

struct GreetingView_Previews: PreviewProvider {
    static var previews: some View {
        GreetingView(showGreeting: .constant(true))
            // If GreetingView uses EnvironmentObject elsewhere, add it here:
            // .environmentObject(TodoViewModel())
    }
}
