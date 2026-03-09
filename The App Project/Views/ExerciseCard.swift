import SwiftUI

struct ExerciseCard: View {
    @StateObject private var hk = HealthKitManager.shared
    let dailyGoal: Double = 30  // your daily exercise‑minutes target

    var body: some View {
        VStack(spacing: 8) {
            Text("Exercise")
                .font(.subheadline)
                .bold()
            ZStack {
                Circle()
                    .stroke(lineWidth: 6)
                    .opacity(0.3)
                    .foregroundColor(.red)

                Circle()
                    .trim(from: 0,
                          to: min(hk.exerciseMinutes / dailyGoal, 1.0))
                    .stroke(style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .foregroundColor(.red)
                    .rotationEffect(.degrees(-90))

                Text("\(Int(hk.exerciseMinutes))m")
                    .font(.caption)
                    .bold()
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .frame(height: 140)
        .onAppear {
            hk.requestAuthorization()
        }
    }
}

struct ExerciseCard_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseCard()
    }
}
