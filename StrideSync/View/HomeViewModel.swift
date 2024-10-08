import Foundation
import HealthKit
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var steps: Int = 0
    @Published var distance: Double = 0.0 // Add a published variable for distance
    var healthStore = HKHealthStore()
    
    init(healthStore: HKHealthStore = HKHealthStore()) {
        self.healthStore = healthStore
    }
    
    func fetchDailyStepsAndDistance() {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)! // Define distance type
        
        // Check if HealthKit is available on this device
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        // Request authorization for both step count and distance
        let readTypes: Set<HKObjectType> = [stepType, distanceType]
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, _ in
            if success {
                self.getSteps()
                self.getDistance()
            }
        }
    }
    
    func getSteps() {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        
        // Create a predicate to filter the data for today
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        // Define a statistics query for step count
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else { return }
            DispatchQueue.main.async {
                self.steps = Int(sum.doubleValue(for: HKUnit.count()))
            }
        }
        
        // Execute the query
        healthStore.execute(query)
    }
    
    func getDistance() {
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        
        // Create a predicate to filter the data for today
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        // Define a statistics query for distance
        let query = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else { return }
            DispatchQueue.main.async {
                self.distance = sum.doubleValue(for: HKUnit.meter()) / 1000.0 // Convert meters to kilometers
            }
        }
        
        // Execute the query
        healthStore.execute(query)
    }
}
