import SwiftUI

struct ContentView: View {
    @State private var selection: Tab = .dashboard

    enum Tab: Hashable {
        case dashboard, tasks, weekly, settings

        var title: String {
            switch self {
            case .dashboard: return "Home"
            case .tasks:     return "Tasks"
            case .weekly:    return "Weekly"
            case .settings:  return "Settings"
            }
        }

        var systemImage: String {
            switch self {
            case .dashboard: return "house.fill"
            case .tasks:     return "checkmark.square"
            case .weekly:    return "calendar"
            case .settings:  return "gearshape.fill"
            }
        }
    }

    var body: some View {
        TabView(selection: $selection) {
            DashboardView()
                .tabItem { Label(Tab.dashboard.title, systemImage: Tab.dashboard.systemImage) }
                .tag(Tab.dashboard)

            TodoListView()
                .tabItem { Label(Tab.tasks.title, systemImage: Tab.tasks.systemImage) }
                .tag(Tab.tasks)

            WeeklyReviewView()
                .tabItem { Label(Tab.weekly.title, systemImage: Tab.weekly.systemImage) }
                .tag(Tab.weekly)

            SettingsView()
                .tabItem { Label(Tab.settings.title, systemImage: Tab.settings.systemImage) }
                .tag(Tab.settings)
        }
        // Modern iOS tab bar appearance
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
        .toolbarColorScheme(nil, for: .tabBar) // follow system (was .automatic)
        .tint(.primary) // active icon/text
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(TodoViewModel())
    }
}
