import Foundation
import HealthKit
import SwiftUI

/// A view model for managing and retrieving health data from HealthKit, such as steps, distance, and flights climbed.
///
/// This class is responsible for interacting with HealthKit to fetch the daily step count, walking/running distance, and the number of flights climbed. It also provides a way to store this data and update SwiftUI views using `@Published` properties.
class HomeViewModel: ObservableObject {
    
    /// The total number of steps taken by the user today.
    ///
    /// This property is updated asynchronously by querying HealthKit for the cumulative step count data since the start of the day.
    @Published var steps: Int = 0
    
    /// The total distance walked or run by the user today, in kilometers.
    ///
    /// This property represents the cumulative distance covered by the user in kilometers, calculated from HealthKit's distance walking/running data type. It is rounded down to one decimal place for display purposes.
    @Published var distance: Double = 0.0
    
    /// The total number of flights of stairs climbed by the user today.
    ///
    /// This property is updated based on HealthKit's `flightsClimbed` data and is calculated as the cumulative number of flights of stairs ascended since the start of the day.
    @Published var flightsClimbed: Int = 0
    
    /// The HealthKit store used to query and retrieve health data.
    ///
    /// This property is initialized with a default `HKHealthStore` instance and is used throughout the view model to request authorization and execute HealthKit queries.
    var healthStore = HKHealthStore()
    
    /// Initializes the `HomeViewModel` with an optional `HKHealthStore` instance.
    ///
    /// - Parameter healthStore: The HealthKit store instance. Defaults to a new `HKHealthStore` if not provided.
    ///
    /// Upon initialization, this method calls `fetchDailyData()` to start fetching health data immediately.
    init(healthStore: HKHealthStore = HKHealthStore()) {
        self.healthStore = healthStore
        fetchDailyData()
    }
    
    /// Requests authorization and retrieves daily health data for steps, distance, and flights climbed.
    ///
    /// This method first checks if HealthKit data is available on the device. If so, it requests read permissions for the following HealthKit data types:
    /// - `stepCount`: The cumulative step count for today.
    /// - `distanceWalkingRunning`: The total distance walked or run today.
    /// - `flightsClimbed`: The cumulative number of flights of stairs climbed today.
    ///
    /// Once authorization is granted, the method calls the internal functions `getSteps()`, `getDistance()`, and `getFlightsClimbed()` to retrieve the respective data.
    func fetchDailyData() {
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
    
    /// Retrieves the cumulative step count for today from HealthKit.
    ///
    /// This method queries HealthKit for the total step count data since the start of the day. It uses a `HKStatisticsQuery` to calculate the cumulative sum of steps and updates the `steps` property on the main thread.
    func getSteps() {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else { return }
            DispatchQueue.main.async {
                self.steps = Int(sum.doubleValue(for: HKUnit.count()))
            }
        }
        
        healthStore.execute(query)
    }
    
    /// Retrieves the total distance walked or run for today in kilometers.
    ///
    /// This method queries HealthKit for the total distance data since the start of the day using `HKStatisticsQuery`.
    /// The result is converted from meters to kilometers and rounded down to one decimal place for display.
    func getDistance() {
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else { return }
            DispatchQueue.main.async {
                let distanceInKM = sum.doubleValue(for: HKUnit.meter()) / 1000.0
                self.distance = floor(distanceInKM * 10) / 10
            }
        }

        healthStore.execute(query)
    }
    
    /// Retrieves the number of flights of stairs climbed today.
    ///
    /// This method queries HealthKit for the total number of flights climbed since the start of the day using `HKStatisticsQuery`. The result is updated on the main thread and stored in the `flightsClimbed` property.
    func getFlightsClimbed() {
        let flightsType = HKQuantityType.quantityType(forIdentifier: .flightsClimbed)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: flightsType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else { return }
            DispatchQueue.main.async {
                self.flightsClimbed = Int(sum.doubleValue(for: HKUnit.count()))
            }
        }
        
        healthStore.execute(query)
    }
}
