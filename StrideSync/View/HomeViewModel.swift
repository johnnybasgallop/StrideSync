import Foundation
import HealthKit
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var steps: Int = 0
    @Published var distance: Double = 0.0 // Published variable for distance
    @Published var flightsClimbed: Int = 0 // Published variable for flights climbed
    
    var healthStore = HKHealthStore()
    
    init(healthStore: HKHealthStore = HKHealthStore()) {
        self.healthStore = healthStore
        fetchDailyData()
    }
    
    func fetchDailyData() {
        // Define the types for steps, distance, and flights climbed
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let flightsType = HKQuantityType.quantityType(forIdentifier: .flightsClimbed)!
        
        // Check if HealthKit is available on this device
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        // Request authorization for step count, distance, and flights climbed
        let readTypes: Set<HKObjectType> = [stepType, distanceType, flightsType]
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, _ in
            if success {
                self.getSteps()
                self.getDistance()
                self.getFlightsClimbed()
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
                let distanceInKM = sum.doubleValue(for: HKUnit.meter()) / 1000.0 // Convert meters to kilometers
                self.distance = floor(distanceInKM * 10) / 10
            }
        }
        
        // Execute the query
        healthStore.execute(query)
    }
    
    func getFlightsClimbed() {
        let flightsType = HKQuantityType.quantityType(forIdentifier: .flightsClimbed)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        
        // Create a predicate to filter the data for today
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        // Define a statistics query for flights climbed
        let query = HKStatisticsQuery(quantityType: flightsType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else { return }
            DispatchQueue.main.async {
                self.flightsClimbed = Int(sum.doubleValue(for: HKUnit.count()))
                print(self.flightsClimbed)
            }
        }
        
        // Execute the query
        healthStore.execute(query)
    }
}
