//
//  ViewController.swift
//  HealthDataFetcher
//
//  Created by Harpreet_kaur on 22/08/19.
//  Copyright © 2019 Harpreet_kaur. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Mark:-To fetch Data from HealthKit.
        HealthKitInterface.sharedInstance = HealthKitInterface()
        NotificationCenter.default.addObserver(self,selector: #selector(self.getDistanceFromHealthKit),name: NSNotification.Name(rawValue:healthKitAutorized),object: nil)
        
        
        
        //Mark:-To fetch Data from Fitbit.
        FitbitInterface.sharedInstance = FitbitInterface()
        self.getCaloriesFromFitbit()
        NotificationCenter.default.addObserver(self,selector: #selector(self.getCaloriesFromFitbit),name: NSNotification.Name(rawValue:FitbitNotification),object: nil)
    }
    
    @objc func getDistanceFromHealthKit() {
        //TO fetch other metric(like steps, calories etc need to change the type)
        HealthKitInterface.sharedInstance?.fetchDataFromHealthKit(forSpecificDate: Date(), type: .distance,completion: { (double, error) in
            if error == nil {
                print("Distance \(double)")
            }
        })
    }
    
    @objc func getCaloriesFromFitbit()  {
        FitbitInterface.sharedInstance?.getDataPeriodically(resourcePath: FitBitResourcePath.steps.path, startDate: Date(), endDate: Date()) { (value) in
            print("Steps \(value)")
        }
    }
    
}
