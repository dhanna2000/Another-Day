import SwiftUI

@main
struct TheAppProjectApp: App {
    @StateObject private var auth   = AuthStore()
    @StateObject private var todoVM = TodoViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(auth)
                .environmentObject(todoVM)
        }
    }
}
