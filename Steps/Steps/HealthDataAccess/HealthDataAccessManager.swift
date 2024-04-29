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
    
    init() {
        self.requestAccess()
    }
    
    let healthStore = HKHealthStore()
    
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
//            self.fetchAllStats()
            print("Observer query detected a change")
            completionHandler()
            self.steps = query.description
            }
        healthStore.execute(observerQuery)
        DispatchQueue.main.sync {
            
//            self.queriesRan += 1
//            print("times ran: \(self.queriesRan)")2212
            
        }
    }
    func setAverage(days: [HKStatistics]) {
        if days.count < 25 {
//        TODO: handle if less than 25 days of history
        } else {
            let topEight = days[0...7]
            var sumSteps: Double = 0
            for day in topEight {
                sumSteps += (day.sumQuantity()?.doubleValue(for: HKUnit.count()))!
                print(sumSteps)
            }
            let average = sumSteps / 8
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.stepsBaseline = Int(average)
            }
        }
    }
}
