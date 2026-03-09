import Foundation
import HealthKit

@MainActor
final class HealthKitManager: NSObject, ObservableObject {
    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()

    @Published var waterIntake: Int = 0            // glasses today
    @Published var dailyWaterGoal: Int = 8         // your goal
    @Published var exerciseMinutes: Double = 0     // minutes today
    @Published var dailyExerciseGoal: Double = 30  // your goal

    private override init() { super.init() }

    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let waterType    = HKQuantityType.quantityType(forIdentifier: .dietaryWater)!
        let exerciseType = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!

        healthStore.requestAuthorization(toShare: [], read: [waterType, exerciseType]) { success, _ in
            guard success else { return }

            // Everything inside here runs on the main actor
            Task { @MainActor in
                await self.updateWaterIntake()
                await self.updateExerciseTime()
                self.startObservers()
            }
        }
    }

    private func startObservers() {
        let waterType    = HKQuantityType.quantityType(forIdentifier: .dietaryWater)!
        let exerciseType = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!

        for type in [waterType, exerciseType] {
            let query = HKObserverQuery(sampleType: type, predicate: nil) { [weak self] _, completionHandler, error in
                guard let self = self, error == nil else {
                    completionHandler()
                    return
                }
                // Re-fetch on new data, still main‐actor isolated
                Task { @MainActor in
                    if type == waterType {
                        await self.updateWaterIntake()
                    } else {
                        await self.updateExerciseTime()
                    }
                    completionHandler()
                }
            }
            healthStore.execute(query)
            healthStore.enableBackgroundDelivery(for: type, frequency: .immediate) { _, _ in }
        }
    }

    func updateWaterIntake() async {
        let type       = HKQuantityType.quantityType(forIdentifier: .dietaryWater)!
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate  = HKQuery.predicateForSamples(withStart: startOfDay, end: Date())
        let query      = HKStatisticsQuery(
            quantityType: type,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, _ in
            let ml      = result?.sumQuantity()?.doubleValue(for: .literUnit(with: .milli)) ?? 0
            let glasses = Int(ml / 250.0)
            DispatchQueue.main.async { self.waterIntake = glasses }
        }
        healthStore.execute(query)
    }

    func updateExerciseTime() async {
        let type       = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate  = HKQuery.predicateForSamples(withStart: startOfDay, end: Date())
        let query      = HKStatisticsQuery(
            quantityType: type,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, _ in
            let mins = result?.sumQuantity()?.doubleValue(for: .minute()) ?? 0
            DispatchQueue.main.async { self.exerciseMinutes = mins }
        }
        healthStore.execute(query)
    }
}
