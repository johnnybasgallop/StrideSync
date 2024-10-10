import Foundation
import HealthKit
import SwiftUI

/// A view model for managing and retrieving health data from HealthKit, such as steps, distance, and flights climbed.
///
/// This class is responsible for interacting with HealthKit to fetch the daily step count, walking/running distance, and the number of flights climbed. It also provides a way to store this data and update SwiftUI views using `@Published` properties.
class HomeViewModel: ObservableObject {
    
    /// The total number of steps taken by the user today.
    @Published var steps: Int = 0
    
    /// The total distance walked or run by the user today, in kilometers.
    @Published var distance: Double = 0.0
    
    /// The total number of flights of stairs climbed by the user today.
    @Published var flightsClimbed: Int = 0
    
    /// The average number of steps taken by the user per day.
    @Published var averageSteps: Int = 0
    
    /// The HealthKit store used to query and retrieve health data.
    var healthStore = HKHealthStore()
    
    init(healthStore: HKHealthStore = HKHealthStore()) {
        self.healthStore = healthStore
        fetchDailyData()
    }
    
    /// Requests authorization and retrieves daily health data for steps, distance, flights climbed, and average steps.
    func fetchDailyData() {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let flightsType = HKQuantityType.quantityType(forIdentifier: .flightsClimbed)!
        
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        let readTypes: Set<HKObjectType> = [stepType, distanceType, flightsType]
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, _ in
            if success {
                self.getSteps()
                self.getDistance()
                self.getFlightsClimbed()
                self.getAverageSteps() // Fetch the average steps as well
            }
        }
    }
    
    /// Retrieves the cumulative step count for today from HealthKit.
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
    
    /// Retrieves the daily average steps for the past week.
    ///
    /// This function uses `HKStatisticsCollectionQuery` to collect step count data for each day over the past week.
    /// It calculates the daily average steps and updates the `averageSteps` property.
    func getAverageSteps() {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.date(byAdding: .day, value: -7, to: now)!
        
        var interval = DateComponents()
        interval.day = 1
        
        let query = HKStatisticsCollectionQuery(
            quantityType: stepType,
            quantitySamplePredicate: nil,
            options: .cumulativeSum,
            anchorDate: startDate,
            intervalComponents: interval
        )
        
        query.initialResultsHandler = { _, collection, _ in
            var totalSteps: Int = 0
            var dayCount: Int = 0
            
            collection?.enumerateStatistics(from: startDate, to: now) { statistics, _ in
                if let sum = statistics.sumQuantity() {
                    totalSteps += Int(sum.doubleValue(for: HKUnit.count()))
                    dayCount += 1
                }
            }
            
            DispatchQueue.main.async {
                self.averageSteps = dayCount > 0 ? totalSteps / dayCount : 0
            }
        }
        
        healthStore.execute(query)
    }
}
