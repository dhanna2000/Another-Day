import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject private var auth: AuthStore

    var body: some View {
        ZStack {
            // ——— Animated background ———
            AnimatedBackgroundView()

            // ——— Content stacked vertically ———
            VStack {
                Spacer()

                Text("Welcome to Another Day")
                    .font(.largeTitle).bold()
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)

                Spacer()

                // Sign in button raised near bottom
                SignInWithAppleButton(
                    onRequest: { _ in auth.signInWithApple() },
                    onCompletion: { _ in }
                )
                .signInWithAppleButtonStyle(.white)
                .frame(height: 44)
                .cornerRadius(30)
                .padding(.horizontal)
                .padding(.bottom, 60)
            }
            .ignoresSafeArea(edges: .bottom)
        }
        // Force dark color scheme for consistent status bar appearance
        .preferredColorScheme(.dark)
    }
}

// ——— Inlined animated gradient ———
private struct AnimatedBackgroundView: View {
    @State private var toggle = false
    private let gradient1 = [Color.blue, Color.purple]
    private let gradient2 = [Color.pink, Color.orange]

    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: toggle ? gradient1 : gradient2),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .onAppear { toggle.toggle() }
        .animation(
            Animation.linear(duration: 5)
                .repeatForever(autoreverses: true),
            value: toggle
        )
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthStore())
    }
}



