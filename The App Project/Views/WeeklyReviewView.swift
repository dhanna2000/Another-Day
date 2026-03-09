import SwiftUI

/// Which day marks the end of the week.
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


struct WeeklyReviewView: View {
    @EnvironmentObject private var vm: TodoViewModel
    @StateObject    private var hk               = HealthKitManager.shared
    @AppStorage("weekEndDay") private var weekEndRawValue: Int = WeekEndDay.sunday.rawValue

    @State private var weekOffset      = 0
    @State private var showReviewStart = false
    @State private var habits          = [HabitItem]()
    @State private var completedHabits = Set<UUID>()

    private let spacing = CGFloat(16)
    private let calendar = Calendar.current

    private var targetDate: Date {
        calendar.date(byAdding: .weekOfYear, value: weekOffset, to: .now) ?? .now
    }

    private var startOfWeek: Date {
        calendar.date(
            from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: targetDate)
        ) ?? targetDate
    }

    private var weekYear: Int {
        calendar.component(.weekOfYear, from: targetDate)
    }

    private var weeklyTasks: [TaskItem] {
        vm.tasks.filter { $0.weekOfYear == weekYear }
    }

    private var tasksDone  : Int { weeklyTasks.filter(\.isDone).count }
    private var tasksTotal : Int { weeklyTasks.count   }

    private var daysElapsedThisWeek: Int {
        guard weekOffset == 0 else { return weekOffset < 0 ? 7 : 0 }
        let wd = calendar.component(.weekday, from: .now)
        return wd == 1 ? 7 : wd - 1
    }

    private var waterThisWeek    : Int    { 3 * daysElapsedThisWeek }
    private var exerciseThisWeek : Double { 0 /* TODO: hook up HealthKit */ }

    private var isLastDayOfWeek: Bool {
      #if DEBUG
        true
      #else
        calendar.component(.weekday, from: .now) == weekEndRawValue
      #endif
    }

    private var habitCompletions: Set<Int> {
        Set((0..<7).compactMap { offset in
            let day = calendar.date(byAdding: .day, value: offset, to: startOfWeek)!
            let wd  = calendar.component(.weekday, from: day)
            let todays = habits.filter { $0.selectedDays.contains(Weekday(rawValue: wd)!) }
            guard !todays.isEmpty else { return nil }
            return todays.allSatisfy { completedHabits.contains($0.id) }
                ? offset : nil
        })
    }

    var body: some View {
        VStack {
            weekSelector
                .padding(.top, 60)

            ScrollView {
                VStack(alignment: .leading, spacing: spacing) {
                    Text(dateRangeTitle())
                        .font(.headline)
                        .padding(.horizontal)

                    VStack(spacing: spacing) {
                        LazyVGrid(columns: [
                            GridItem(.flexible()), GridItem(.flexible())
                        ], spacing: spacing) {
                            InfoCard(title: "Tasks",       value: "\(tasksDone)/\(tasksTotal)")
                            InfoCard(title: "Outstanding", value: "\(tasksTotal - tasksDone)")
                            InfoCard(title: "Water",       value: "\(waterThisWeek) glasses")
                            InfoCard(title: "Exercise",    value: String(format: "%.0f min", exerciseThisWeek))
                        }

                        VStack(spacing: 8) {
                            Text("Habits Progress")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                            HabitWeekView(
                                weekStart: startOfWeek,
                                completions: habitCompletions
                            )
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color(UIColor.secondarySystemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    )
                    .padding(.horizontal)

                    if isLastDayOfWeek {
                        Button { showReviewStart = true } label: {
                            Text("Start Weekly Review")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                                .background(Capsule().fill(Color.accentColor))
                        }
                        .padding(.horizontal)
                        .padding(.top, spacing)
                    }
                }
            }
        }
        .onAppear { hk.requestAuthorization() }
        .navigationBarHidden(true)
        .sheet(isPresented: $showReviewStart) {
            WeeklyReviewStartView(isPresented: $showReviewStart)
        }
    }

    private var weekSelector: some View {
        HStack(spacing: 16) {
            Button { weekOffset -= 1 } label: {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
            Text(weekTitle)
                .font(.headline)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(
                    Capsule()
                        .fill(Color(UIColor.secondarySystemBackground))
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
            Button { weekOffset += 1 } label: {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var weekTitle: String {
        switch weekOffset {
        case  0: return "This Week"
        case -1: return "Last Week"
        case  1: return "Next Week"
        default: return dateRangeTitle()
        }
    }

    private func dateRangeTitle() -> String {
        let end = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!
        let fmt = DateFormatter(); fmt.dateFormat = "MMM d"
        return "\(fmt.string(from: startOfWeek)) – \(fmt.string(from: end))"
    }
}
