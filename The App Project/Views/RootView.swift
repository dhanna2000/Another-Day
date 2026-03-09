import SwiftUI
import AuthenticationServices

// MARK: – Utility to round specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
private struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: – Simple bottom overlay (fills all the way to the bottom)
private struct SimpleOverlayView: View {
    private var overlayColor: Color {
        let hour = Calendar.current.component(.hour, from: .now)
        return (6..<18).contains(hour)
            ? Color.green.opacity(0.8)
            : Color.blue.opacity(0.8)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemBackground)
                .ignoresSafeArea()

            Rectangle()
                .fill(overlayColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .cornerRadius(30, corners: [.topLeft, .topRight])
                .ignoresSafeArea(edges: .bottom)
        }
    }
}

// MARK: – Root and onboarding
struct RootView: View {
    @EnvironmentObject var auth: AuthStore
    @AppStorage("username") private var username: String = ""

    // Onboarding state
    @State private var tempName   = ""
    @State private var showLine1  = false
    @State private var showLine2  = false
    @State private var showField  = false
    @State private var showButton = false

    var body: some View {
        Group {
            if username.isEmpty {
                onboardingView
            } else if !auth.isSignedIn {
                LoginView()
            } else {
                ContentView()
            }
        }
    }

    private var onboardingView: some View {
        ZStack {
            SimpleOverlayView()

            VStack(alignment: .leading, spacing: 20) {
                Spacer().frame(height: 250)

                if showLine1 {
                    Text("Hi there!")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white)
                        .opacity(showLine1 ? 1 : 0)
                        .animation(.easeOut(duration: 0.6), value: showLine1)
                }

                if showLine2 {
                    Text("What should we call you?")
                        .font(.title2)
                        .foregroundColor(.white)
                        .opacity(showLine2 ? 1 : 0)
                        .animation(.easeIn(duration: 0.6), value: showLine2)
                }

                Spacer()

                if showField {
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Your name", text: $tempName)
                            .font(.title3)
                            .foregroundColor(.white)
                            .textFieldStyle(PlainTextFieldStyle())
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                if showButton {
                    Button {
                        let trimmed = tempName.trimmingCharacters(in: .whitespaces)
                        if !trimmed.isEmpty { username = trimmed }
                    } label: {
                        Text("Continue")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(30)
                    }
                    .transition(.opacity)
                }

                Spacer().frame(height: 100)
            }
            .padding()
            .onAppear {
                withAnimation { showLine1 = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { showLine2 = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) { showField = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) { showButton = true }
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(AuthStore())
    }
}


