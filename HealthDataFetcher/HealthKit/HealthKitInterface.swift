//
//  HealthKitInterface.swift
//  FitbitDataFetcher
//
//  Created by Harpreet_kaur on 22/08/19.
//  Copyright © 2019 Harpreet_kaur. All rights reserved.
//

import Foundation

// STEP 1: MUST import HealthKit
import HealthKit
var healthKitAutorized = "NotificationIdentifier"

enum HealthMetric {
    case distance
    case step
    case calories
    //add other metric here, for which you want to fetch.
    
    var path:HKQuantityType {
        switch self {
        case .distance:
            return HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!
        case .step:
            return HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
        case .calories:
            return HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!
        }
    }
}


class HealthKitInterface {
    
    // STEP 2: a placeholder for a conduit to all HealthKit data
    static var sharedInstance:HealthKitInterface?
    let healthKitDataStore: HKHealthStore?
    
    // STEP 3: create member properties that we'll use to ask
    // if we can read and write heart rate data
    let readableHKQuantityTypes: Set<HKQuantityType>?
    let writeableHKQuantityTypes: Set<HKQuantityType>?
    
    init() {
        
        // STEP 4: make sure HealthKit is available
        if HKHealthStore.isHealthDataAvailable() {
            
            // STEP 5: create one instance of the HealthKit store
            // per app; it's the conduit to all HealthKit data
            self.healthKitDataStore = HKHealthStore()
            
            // STEP 6: create two Sets of HKQuantityTypes representing
            // heart rate data; one for reading, one for writing
            readableHKQuantityTypes = [HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
                ,HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!,HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!
            ]
            writeableHKQuantityTypes = []
            
            // STEP 7: ask user for permission to read and write
            // heart rate data
            
            healthKitDataStore?.requestAuthorization(toShare: writeableHKQuantityTypes,read: readableHKQuantityTypes,completion: { (success, error) -> Void in
                if success {
                    NotificationCenter.default.post(name: Notification.Name(healthKitAutorized), object: nil)
                    print("Successful authorization.")
                } else {
                    print(error.debugDescription)
                }
            })
            
        }else{  // end if HKHealthStore.isHealthDataAvailable()
            self.healthKitDataStore = nil
            self.readableHKQuantityTypes = nil
            self.writeableHKQuantityTypes = nil
            
        }
        
    } // end init()
    
    //MARK:-This function will be used when we have to fetch data for complete day.(Just pass the date for which you want to fetch the data).
    func fetchDataFromHealthKit(forSpecificDate:Date,type:HealthMetric,completion: @escaping (Double,Error?) -> Void) {
        let (start, end) = self.getWholeDate(date: forSpecificDate)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: type.path, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0,error)
                return
            }
            switch type {
            case .distance:
                completion(sum.doubleValue(for: HKUnit.mile()),error)
            case .step:
                completion(sum.doubleValue(for: HKUnit.count()),error)
            case .calories:
                completion(sum.doubleValue(for: HKUnit.kilocalorie()),error)
            }
        }
        self.healthKitDataStore?.execute(query)
    }
    
    //MARK:-This function will be used when we have to fetch data for for specific time period day.(Just pass the start date with time and end date with time for which you want to fetch the data).
    func fetchDataFromHealthKitForTimePeriod(startDate:Date, endDate:Date,type:HealthMetric,completion: @escaping (Double,Error?) -> Void) {
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: type.path, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0,error)
                return
            }
            switch type {
            case .distance:
                completion(sum.doubleValue(for: HKUnit.mile()),error)
            case .step:
                completion(sum.doubleValue(for: HKUnit.count()),error)
            case .calories:
                completion(sum.doubleValue(for: HKUnit.kilocalorie()),error)
            }
            
        }
        self.healthKitDataStore?.execute(query)
    }
    
    //MARK:-This Function will be used to fetch Heart Rate Data From HealthKit.
    func readHeartRateData() -> Void {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        let query = HKAnchoredObjectQuery(type: heartRateType, predicate: nil, anchor: nil, limit: HKObjectQueryNoLimit) {
            (query, samplesOrNil, deletedObjectsOrNil, newAnchor, errorOrNil) in
            if let samples = samplesOrNil {
                for heartRateSamples in samples {
                    print(heartRateSamples)
                }
            }
            else {
                print("No heart rate sample available.")
            }
        }
        //execute the query for heart rate data
        healthKitDataStore?.execute(query)
    }
    
    //MARK:-This function will be used to fetch sleep analysis from HealthKit
    func retrieveSleepAnalysis(startDate:Date, endDate:Date, completion: @escaping (Double,Error?) -> Void) {
        // first, we define the object type we want
        if let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) {
            // Use a sortDescriptor to get the recent data first
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
            // we create our query with a block completion to execute
            let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: 30, sortDescriptors: [sortDescriptor]) { (query, tmpResult, error) -> Void in
                if error != nil {
                    return
                }
                if let result = tmpResult {
                    var sleepAggr: Double = 0
                    // do something with my data
                    for item in result {
                        if let sample = item as? HKCategorySample {
                            let value = (sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue) ? "InBed" : "Asleep"
                            print("Healthkit sleep: \(sample.startDate) \(sample.endDate) - value: \(value)")
                            //                        //return
                            let distanceBetweenDates = (sample.endDate.timeIntervalSince(sample.startDate))
                            sleepAggr += distanceBetweenDates
                        }
                    }
                    completion(sleepAggr,error)
                }
            }
            // finally, we execute our query
            self.healthKitDataStore?.execute(query)
        }
    }
    
    func getWholeDate(date : Date) -> (startDate:Date, endDate: Date) {
        var startDate = date
        var length = TimeInterval()
        print("")
        _ = Calendar.current.dateInterval(of: .day, start: &startDate, interval: &length, for: startDate)
        let endDate:Date = startDate.addingTimeInterval(length)
        return (startDate,endDate)
    }
}
