//
//  HealthDataAccessManager.swift
//  Steps
//
//  Created by Aaron Wilson on 4/6/24.
//

import Foundation
import HealthKit

class HealthDataAccessManager: ObservableObject {

    @Published var steps: String = ""
    @Published var stepsBaseline: Int = 0
    @Published var showAlert: Bool = false
    @Published var errorMessage: String?

    init() {
        self.requestAccess()
        self.testStatisticsCollectionQueryCumulative()
    }

    let healthStore = HKHealthStore()
    let mainThread = DispatchQueue.main
    func requestAccess() {
        let read: Set = [
            HKQuantityType(.stepCount)
        ]
        healthStore.requestAuthorization(toShare: .none, read: read) { success, error in
            if success {
                print("Access to healthstore granted")
                self.enableBackgroundDelivery()
            } else {
                if let error = error {
                    print("error requesting access\(error)")
                }
            }
        }
    }

    func enableBackgroundDelivery() {
        healthStore.enableBackgroundDelivery(for: HKQuantityType(.stepCount), frequency: .immediate) { success, error in
            if let error = error {
                print("there was an error \(error)")
            }
            if success {
                print("Background access granted")
                self.backgroundQuery()
            }
        }
    }
    func backgroundQuery() {
        let typeToRead = HKQuantityType(.stepCount)
        let observerQuery = HKObserverQuery(sampleType: typeToRead, predicate: nil) { (query, completionHandler, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            // Perform any necessary actions when the observer query detects a change

            print("Observer query detected a change")
            completionHandler()
            self.steps = query.description
            }
        healthStore.execute(observerQuery)
        DispatchQueue.main.sync {

        }
    }
    func setAverage(days: [HKStatistics]) {
        if days.count < 25 {
            errorMessage = "Oops! You need at least 25 days of steps to set an average. Keep walking and check back soon! "
            showAlert = true
        } else {
            let topEight = days[0...7]
            var sumSteps: Double = 0
            for day in topEight {
                if let dayCount = (day.sumQuantity()?.doubleValue(for: HKUnit.count())) {
                    sumSteps += dayCount
                    print(sumSteps)
                }
            }
            let average = sumSteps / 8
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.stepsBaseline = Int(average)
            }
        }
    }
    func testStatisticsCollectionQueryCumulative() {
        // this is just setting the type of info we can read. If the user disallowed step info i think this would fail.
        guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            fatalError("*** Unable to get the step count type ***")
        }
        // this is used to determine how to slice the time up. By day? Week? Hour min?
        var interval = DateComponents()
        interval.day = 1
        let calendar = Calendar.current
        guard let anchorDate = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) else {
            self.showAlert = true
            self.errorMessage = "Failure to show anchor date"
            return
        }
        let query = HKStatisticsCollectionQuery.init(quantityType: stepCountType,
                                                     quantitySamplePredicate: nil,
                                                     options: .cumulativeSum,
                                                     anchorDate: anchorDate,
                                                     intervalComponents: interval)
        query.initialResultsHandler = { [weak self] query, results, error in
            guard let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) else {
                self?.showAlert = true
                self?.errorMessage = "Failure to set start date for collection query"
                return
            }
            let startDate = calendar.startOfDay(for: oneMonthAgo)
            var statistics: [HKStatistics] = []
            results?.enumerateStatistics(from: startDate,
                                         to: Date(), with: { (result, _) in
                statistics.append(result)
                print("Time: \(result.startDate.formatted(date: .abbreviated, time: .omitted)), \(result.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0)")
            })
            self?.sortTheDays(days: statistics)
        }
        healthStore.execute(query)
    }

    func sortTheDays(days: [HKStatistics]) {
        var sortedDays = days
        sortedDays.sort(by: {
            $0.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0 > $1.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
        })
        mainThread.sync {
            self.setAverage(days: sortedDays)
        }
    }
}
