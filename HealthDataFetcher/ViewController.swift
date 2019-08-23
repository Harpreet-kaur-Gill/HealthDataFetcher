//
//  ViewController.swift
//  FitbitDataFetcher
//
//  Created by Harpreet_kaur on 22/08/19.
//  Copyright © 2019 Harpreet_kaur. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Mark:-To Fetch Data From Healhtkit.
        HealthKitInterface.sharedInstance = HealthKitInterface()
        NotificationCenter.default.addObserver(self,selector: #selector(self.getDistanceFromHealthKit),name: NSNotification.Name(rawValue:healthKitAutorized),object: nil)
        
        //Mark:-Function to Fetch Data From Fitbit.
        FitbitInterface.sharedInstance = FitbitInterface()
        NotificationCenter.default.addObserver(self,selector: #selector(self.getStepsFromFitbit),name: NSNotification.Name(rawValue:FitbitNotification),object: nil)
    }
    
    @objc func getDistanceFromHealthKit() {
        //Mark:-Need to change the type to get data of other metrics.
        HealthKitInterface.sharedInstance?.fetchDataFromHealthKit(forSpecificDate: Date(), type: .distance,completion: { (double, error) in
            if error == nil {
                print("Distance \(double)")
            }
        })
    }
    
    @objc func getStepsFromFitbit() {
        //Mark:-Need to change the type to get data of other metrics
        FitbitInterface.sharedInstance?.getDataPeriodically(resourcePath: FitBitResourcePath.steps.path, startDate: Date().dayBefore, endDate: Date()) { (value) in
        }
    }
}

