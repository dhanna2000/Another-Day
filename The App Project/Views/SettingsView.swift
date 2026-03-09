import SwiftUI

struct SettingsView: View {
    enum WeekEndDay: Int, CaseIterable, Identifiable {
        case sunday = 1, saturday = 7
        var id: Int { rawValue }
        var displayName: String {
            switch self {
            case .sunday:   return "Sunday"
            case .saturday: return "Saturday"
            }
        }
    }

    @EnvironmentObject private var auth: AuthStore

    @AppStorage("lastGreetingDate") private var lastGreetingDate: String = ""
    @AppStorage("colorScheme")      private var colorScheme:      String = "system"
    @AppStorage("weekEndDay")       private var weekEndRawValue: Int    = WeekEndDay.sunday.rawValue

    @State private var notificationsEnabled = true
    private let appearanceOptions = ["Light", "Dark", "System"]

    var body: some View {
        NavigationView {
            Form {
                Section("General") {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                }
                Section("Appearance") {
                    Picker("App Theme", selection: $colorScheme) {
                        ForEach(appearanceOptions, id: \.self) { label in
                            Text(label).tag(label.lowercased())
                        }
                    }
                    .pickerStyle(.segmented)
                }
                Section("Calendar") {
                    Picker("Last Day of Week", selection: $weekEndRawValue) {
                        ForEach(WeekEndDay.allCases) { day in
                            Text(day.displayName).tag(day.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                Section("Account") {
                    // <-- **NO** dollar sign here
                    Button("Sign Out", role: .destructive) {
                        auth.signOut()
                    }
                }
                Section("Developer") {
                    Button("Reset Greeting Date") {
                        lastGreetingDate = ""
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AuthStore())
    }
}
