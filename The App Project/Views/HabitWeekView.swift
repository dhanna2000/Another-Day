import SwiftUI

struct HabitWeekView: View {
    let weekStart : Date
    let completions: Set<Int>

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<7, id: \.self) { offset in
                let done = completions.contains(offset)
                Circle()
                    .strokeBorder(done ? Color.green : Color.secondary, lineWidth: 2)
                    .background(Circle().fill(done ? Color.green.opacity(0.3) : .clear))
                    .frame(width: 24, height: 24)
            }
        }
    }
}

struct HabitWeekView_Previews: PreviewProvider {
    static var previews: some View {
        HabitWeekView(weekStart: Date(), completions: [0,2,4])
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
