// Views/DashboardView.swift

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var vm: TodoViewModel
    @StateObject    private var weatherVM = WeatherViewModel()
    @StateObject    private var hk        = HealthKitManager.shared

    @State private var habits          : [HabitItem] = []
    @State private var showingAddHabit : Bool         = false
    @State private var editingHabit    : HabitItem?   = nil
    @State private var completedHabits : Set<UUID>    = []

    @State private var weatherExpanded = false
    @State private var showingAddGoal  = false

    private let cardHeight: CGFloat = 140
    private let spacing   : CGFloat = 16

    private var todayTasks: [TaskItem] {
        vm.tasks.filter { Calendar.current.isDateInToday($0.dueDate) }
    }

    private var isDaytime: Bool {
        let h = Calendar.current.component(.hour, from: Date())
        return (6...17).contains(h)
    }

    private var backgroundGradient: LinearGradient {
        if isDaytime {
            return LinearGradient(
                colors: [Color.orange, Color.white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [Color.blue, Color.black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    header
                    cardsSection
                    tasksWidget
                    habitsWidget
                    debugSection
                    Spacer()
                }
                .padding(.top)
            }
            .navigationBarHidden(true)
            .background(backgroundGradient.ignoresSafeArea())

            // ——— NEW: onAppear does three things: ———
            // 1) initial weather fetch
            // 2) HealthKit permission & observers
            // 3) immediate data fetch of water + exercise
            .onAppear {
                weatherVM.requestPermissionAndFetch()
                hk.requestAuthorization()
                Task { @MainActor in
                    await hk.updateWaterIntake()
                    await hk.updateExerciseTime()
                }
            }
            // ————————————————————————————————————————

            .sheet(isPresented: $showingAddGoal) {
                AddGoalView(isPresented: $showingAddGoal) { title in
                    vm.tasks.append(TaskItem(title: title, dueDate: Date()))
                }
            }
        }
    }


    // MARK: Header
    private var header: some View {
        HStack {
            Text("Today")
                .font(.largeTitle).bold()
            Spacer()
            weatherHeader
        }
        .padding(.horizontal)
    }


    // MARK: Weather Header
    private var weatherHeader: some View {
        HStack(spacing: 6) {
            Image(systemName: "cloud.sun.fill")
                .font(.system(size: weatherExpanded ? 22 : 18, weight: .semibold))
                .symbolRenderingMode(.palette)
                .foregroundStyle(.yellow, .gray)

            Group {
                if weatherExpanded {
                    VStack(alignment: .leading, spacing: 1) {
                        if weatherVM.isLoading {
                            ProgressView()
                        } else if let errorMessage = weatherVM.errorMessage {
                            Text(errorMessage)
                                .font(.caption2)
                                .foregroundColor(.red)
                                .lineLimit(2)
                        } else if let t = weatherVM.temperature {
                            Text("H: \(Int(t.value + 5))°  L: \(Int(t.value - 3))°")
                                .font(.caption2)
                        } else {
                            Text("No weather data")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        Text(weatherVM.condition?.description.capitalized ?? "Unknown")
                            .font(.caption2)
                        
                        // Add refresh button and last updated info
                        HStack(spacing: 4) {
                            Button(action: {
                                weatherVM.refreshWeather()
                            }) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                            }
                            .disabled(weatherVM.isLoading)
                            
                            if let lastUpdated = weatherVM.lastUpdated {
                                Text("Updated \(timeAgoString(from: lastUpdated))")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } else if weatherVM.isLoading {
                    ProgressView().scaleEffect(0.5)
                } else if let errorMessage = weatherVM.errorMessage {
                    Text("!")
                            .font(.title3).bold()
                            .foregroundColor(.red)
                } else if let t = weatherVM.temperature {
                    Text("\(Int(t.value))°")
                        .font(.title3).bold()
                } else {
                    Text("--°")
                        .font(.title3).bold()
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, weatherExpanded ? 12 : 8)
        .frame(width: weatherExpanded ? 160 : 50, height: 34)
        .background(
            RoundedRectangle(cornerRadius: 17, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                weatherExpanded.toggle()
                if !weatherExpanded {
                    weatherVM.refreshWeather()
                }
            }
        }
    }


    // MARK: Cards Section
    private var cardsSection: some View {
        HStack(spacing: spacing) {
            todayGoalCard
                .onTapGesture { showingAddGoal = true }
            healthWidget
        }
        .padding(.horizontal)
    }

    private var todayGoalCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today's Goal").font(.title3).bold()
            if let task = todayTasks.first {
                Text(task.title).font(.headline)
            } else {
                Text("Tap to add a goal")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(height: cardHeight)
        .frame(maxWidth: .infinity)
        .background(cardBackground)
    }


    // MARK: Health Widget
    private var healthWidget: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Health").font(.title3).bold()
            HStack(spacing: spacing) {
                // Water ring
                ringCard(
                    label:    "Water",
                    value:    "\(hk.waterIntake)/\(hk.dailyWaterGoal)",
                    fraction: Double(hk.waterIntake) / Double(max(hk.dailyWaterGoal, 1)),
                    color:    .blue
                )

                // Exercise ring
                ringCard(
                    label:    "Exercise",
                    value:    "\(Int(hk.exerciseMinutes)) min",
                    fraction: min(hk.exerciseMinutes / hk.dailyExerciseGoal, 1.0),
                    color:    .red
                )
            }
        }
        .padding()
        .frame(height: cardHeight)
        .frame(maxWidth: .infinity)
        .background(cardBackground)
    }

    // MARK: Ring Card Helper
    private func ringCard(
        label: String,
        value: String,
        fraction: Double,
        color: Color
    ) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle().stroke(color.opacity(0.3), lineWidth: 6)
                Circle()
                    .trim(from: 0, to: CGFloat(fraction))
                    .stroke(
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .foregroundColor(color)
                Text(value).font(.caption).bold()
            }
            .frame(width: 80, height: 80)

            Text(label).font(.caption).foregroundColor(.secondary)
        }
    }


    // MARK: Tasks Widget
    private var tasksWidget: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tasks for Today").font(.title3).bold()
            if todayTasks.isEmpty {
                Text("No tasks for today").foregroundColor(.secondary)
            } else {
                ForEach(todayTasks) { task in
                    HStack {
                        Image(
                            systemName: task.isDone
                                ? "checkmark.circle.fill"
                                : "circle"
                        )
                        .onTapGesture { vm.toggle(task) }
                        .foregroundColor(
                            task.isDone ? .green : .secondary
                        )
                        Text(task.title)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(cardBackground)
        .padding(.horizontal)
    }


    // MARK: Habits Widget
    private var habitsWidget: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Habits").font(.title3).bold()
                Spacer()
                Button { showingAddHabit = true } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }

            if habits.isEmpty {
                Text("No habits yet").foregroundColor(.secondary)
            } else {
                ForEach(habits) { habit in
                    HStack {
                        Image(
                            systemName: completedHabits.contains(habit.id)
                                ? "checkmark.circle.fill"
                                : "circle"
                        )
                        .onTapGesture {
                            if completedHabits.contains(habit.id) {
                                completedHabits.remove(habit.id)
                            } else {
                                completedHabits.insert(habit.id)
                            }
                        }
                        .foregroundColor(
                            completedHabits.contains(habit.id)
                                ? .green
                                : .secondary
                        )

                        Text(habit.name)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { editingHabit = habit }
                }
            }
        }
        .padding()
        .background(cardBackground)
        .padding(.horizontal)
        .sheet(isPresented: $showingAddHabit) {
            AddHabitView(isPresented: $showingAddHabit) { newHabit in
                habits.append(newHabit)
            }
        }
        .sheet(item: $editingHabit) { habit in
            EditHabitView(
                habit: habit,
                saveAction: { updated in
                    if let idx = habits.firstIndex(where: { $0.id == updated.id }) {
                        habits[idx] = updated
                    }
                }
            )
        }
    }

    // MARK: Debug Section (temporary - remove after fixing weather)
    private var debugSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Debug Info").font(.caption).bold()
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Location Status: \(locationStatusText)")
                    .font(.caption2)
                Text("Weather Loading: \(weatherVM.isLoading ? "Yes" : "No")")
                    .font(.caption2)
                if let temp = weatherVM.temperature {
                    Text("Temperature: \(temp)")
                        .font(.caption2)
                } else {
                    Text("Temperature: nil")
                        .font(.caption2)
                        .foregroundColor(.red)
                }
                if let condition = weatherVM.condition {
                    Text("Condition: \(condition.description)")
                        .font(.caption2)
                } else {
                    Text("Condition: nil")
                        .font(.caption2)
                        .foregroundColor(.red)
                }
                if let lastUpdated = weatherVM.lastUpdated {
                    Text("Last Updated: \(lastUpdated, style: .time)")
                        .font(.caption2)
                } else {
                    Text("Last Updated: Never")
                        .font(.caption2)
                        .foregroundColor(.red)
                }
                if let error = weatherVM.errorMessage {
                    Text("Error: \(error)")
                        .font(.caption2)
                        .foregroundColor(.red)
                }
                
                // Add refresh button in debug section
                Button("Refresh Weather") {
                    weatherVM.refreshWeather()
                }
                .font(.caption2)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(4)
                .disabled(weatherVM.isLoading)
                
                Button("Test WeatherKit") {
                    Task {
                        await weatherVM.testWeatherKitConnection()
                    }
                }
                .font(.caption2)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.2))
                .cornerRadius(4)
                .disabled(weatherVM.isLoading)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal)
    }

    private var locationStatusText: String {
        switch weatherVM.locationStatus {
        case .notDetermined: return "Not Determined"
        case .restricted: return "Restricted"
        case .denied: return "Denied"
        case .authorizedAlways: return "Always"
        case .authorizedWhenInUse: return "When In Use"
        @unknown default: return "Unknown"
        }
    }


    // MARK: Card Background
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color(UIColor.secondarySystemBackground))
            .shadow(color: .black.opacity(0.18), radius: 12, x: 0, y: 6)
            .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
    }
    
    // MARK: Helper Functions
    private func timeAgoString(from date: Date) -> String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)
        
        if timeInterval < 60 {
            return "just now"
        } else if timeInterval < 3600 {
            let minutes = Int(timeInterval / 60)
            return "\(minutes)m ago"
        } else if timeInterval < 86400 {
            let hours = Int(timeInterval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(timeInterval / 86400)
            return "\(days)d ago"
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(TodoViewModel())
    }
}
