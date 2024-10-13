import Foundation
import WidgetKit
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
    @Published var averageStepsWeek: Int = 0
    @Published var averageStepsMonth: Int = 0
    @Published var averageStepsYear: Int = 0
    
    /// Step data for the last 7 days.
    @Published var weekData: [StepEntry] = []
    
    /// Step data for the last 30 days (each day).
    @Published var monthData: [StepEntry] = []
    
    /// Step data for the last year (each month).
    @Published var yearData: [StepEntry] = []
    
    /// The HealthKit store used to query and retrieve health data.
    var healthStore = HKHealthStore()
    
    init(healthStore: HKHealthStore = HKHealthStore()) {
        self.healthStore = healthStore
    }
    
    ///Fetches all of the initial data needed, including graph data.
    func fetchAllData(){
        self.fetchDailyData()
        
        self.fetchData(for: .week){steps in
            self.weekData = steps
        }
        self.getAverageSteps(for: .week){average in
            self.averageStepsWeek = average
        }
        
        self.fetchData(for: .month){steps in
            self.monthData = steps
        }
        self.getAverageSteps(for: .month){average in
            self.averageStepsMonth = average
            self.saveToSharedDefaults()
        }
        
        self.fetchData(for: .year) { steps in
            self.yearData = steps
        }
        self.getAverageSteps(for: .year){average in
            self.averageStepsYear = average
        }
        
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
    
    /// Retrieves the daily average steps for the given period (week, month, or year).
    ///
    /// - Parameters:
    ///   - period: The time period for which to calculate the average (e.g., `.week`, `.month`, `.year`).
    ///   - completion: A closure that returns the calculated daily average steps for the specified period.
    func getAverageSteps(for period: TimePeriod, completion: @escaping (Int) -> Void) {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let calendar = Calendar.current
        let now = Date()
        var interval = DateComponents()
        var startDate: Date
        
        // Set the start date and interval based on the specified period
        switch period {
        case .week:
            interval.day = 1
            startDate = calendar.date(byAdding: .day, value: -7, to: now)!
        case .month:
            interval.day = 1 // Daily intervals for a month
            startDate = calendar.date(byAdding: .month, value: -1, to: now)!
        case .year:
            interval.day = 1 // Daily intervals to accurately calculate daily average over a year
            startDate = calendar.date(byAdding: .year, value: -1, to: now)!
        }
        
        // Create a statistics collection query for the specified period
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
            
            // Enumerate through the statistics and calculate the total steps and count of days
            collection?.enumerateStatistics(from: startDate, to: now) { statistics, _ in
                if let sum = statistics.sumQuantity() {
                    totalSteps += Int(sum.doubleValue(for: HKUnit.count()))
                    dayCount += 1
                }
            }
            
            // Calculate the daily average steps for the specified period
            DispatchQueue.main.async {
                let average = dayCount > 0 ? totalSteps / dayCount : 0
                completion(average)
            }
        }
        
        // Execute the query
        healthStore.execute(query)
    }
    
    /// Fetch steps data for the specified period and store in appropriate property.
    func fetchData(for period: TimePeriod, completion: @escaping ([StepEntry]) -> Void) {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let calendar = Calendar.current
        let now = Date()
        var interval = DateComponents()
        var startDate: Date
        var endDate: Date
        
        switch period {
        case .week:
            interval.day = 1
            startDate = calendar.date(byAdding: .day, value: -7, to: now)! // Start from 7 days ago
            endDate = calendar.date(byAdding: .day, value: -1, to: now)! // End at yesterday
        case .month:
            interval.day = 1
            startDate = calendar.date(byAdding: .month, value: -1, to: now)!
            endDate = now
        case .year:
            interval.month = 1
            // Start date should be January 1st of the current year
            startDate = calendar.date(from: Calendar.current.dateComponents([.year], from: now))!
            endDate = now
        }
        
        let query = HKStatisticsCollectionQuery(
            quantityType: stepType,
            quantitySamplePredicate: nil,
            options: .cumulativeSum,
            anchorDate: startDate,
            intervalComponents: interval
        )
        
        query.initialResultsHandler = { _, collection, _ in
            var stepEntries: [StepEntry] = []
            collection?.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
                let steps = statistics.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                let label = self.getLabel(for: statistics.startDate, period: period)
                stepEntries.append(StepEntry(label: label, steps: Int(steps)))
            }
            DispatchQueue.main.async {
                completion(stepEntries)
            }
        }
        
        healthStore.execute(query)
    }
    
    private func getLabel(for date: Date, period: TimePeriod) -> String {
        let dateFormatter = DateFormatter()
        switch period {
        case .week:
            dateFormatter.dateFormat = "EEE" // Use short day names, e.g., "Mon", "Tue"
        case .month:
            dateFormatter.dateFormat = "d" // Use numeric days for month
        case .year:
            dateFormatter.dateFormat = "MMM" // Use short month names, e.g., "Jan", "Feb"
        }
        return dateFormatter.string(from: date)
    }
    
    func saveToSharedDefaults() {
        let sharedDefaults = UserDefaults(suiteName: "group.basgallop.StrideSyncApp")
        sharedDefaults?.set(self.steps, forKey: "totalSteps")
        sharedDefaults?.set(self.distance, forKey: "distance")
        sharedDefaults?.set(self.flightsClimbed, forKey: "flightsClimbed")
        sharedDefaults?.set(self.averageStepsMonth, forKey: "averageSteps")
        
        WidgetCenter.shared.reloadAllTimelines()
    }
}
