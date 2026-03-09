import SwiftUI

struct WeeklyReviewStartView: View {
    @Binding var isPresented: Bool
    @State private var animate = false

    // Day vs. night palettes
    private var isDaytime: Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return (6...17).contains(hour)
    }
    private var palette1: [Color] {
        isDaytime
            ? [Color.orange, Color.yellow, Color.pink]
            : [Color.indigo, Color.blue, Color.black]
    }
    private var palette2: [Color] {
        isDaytime
            ? [Color.pink, Color.orange, Color.yellow]
            : [Color.black, Color.indigo, Color.blue]
    }

    // Animated gradient that smoothly shifts between two palettes
    private var animatedGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: animate ? palette1 : palette2),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        ZStack {
            animatedGradient
                .ignoresSafeArea()
                .onAppear {
                    withAnimation(
                        Animation.linear(duration: 60)
                            .repeatForever(autoreverses: true)
                    ) {
                        animate.toggle()
                    }
                }

            VStack(spacing: 24) {
                Spacer()

                Text("Ready to start your weekly review?")
                    .font(.largeTitle).bold()
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding(.horizontal)

                Button("Continue") {
                    isPresented = false
                }
                .font(.headline)
                .foregroundColor(.primary) // Adapts to light/dark
                .padding(.vertical, 12)
                .padding(.horizontal, 32)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(UIColor.systemBackground))
                )
                .padding(.horizontal)

                Spacer()
            }
        }
    }
}

struct WeeklyReviewStartView_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyReviewStartView(isPresented: .constant(true))
    }
}

