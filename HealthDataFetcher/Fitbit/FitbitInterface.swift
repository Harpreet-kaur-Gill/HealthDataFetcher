//
//  FitbitInterface.swift
//  FitbitDataFetcher
//
//  Created by Harpreet_kaur on 22/08/19.
//  Copyright © 2019 Harpreet_kaur. All rights reserved.
//

import Foundation
import UIKit

enum FitBitResourcePath {
    case distance
    case steps
    case calories
    case floors
    
    var path:String {
        switch self {
        case .distance:
            return "activities/distance"
        case .steps:
            return "activities/steps"
        case .calories:
            return "activities/calories"
        case .floors:
            return "activities/floors"
        }
    }
}


class FitbitInterface {
    
    static var sharedInstance:FitbitInterface?
    var currentController:UIViewController?
    
    func getSleepTimeFromFitbit(controller:UIViewController,startDate:Date,endDate:Date) {
        self.currentController = controller
        let apiUrl = "https://api.fitbit.com/1.2/user/-/sleep/date/\(startDate.UTCToLocal(inFormat: .fitbitDate))/\(endDate.UTCToLocal(inFormat: .fitbitDate)).json"
        let token = FitbitAuthHandler.getToken()
        let manager = FitbitAPIManager.shared()
        manager?.requestGET(apiUrl, token: token, success: { responseObject in
            if let response = responseObject {
                if let data = response["sleep"] as? [[String:Any]] {
                    var value : Double = 0.0
                    for (_,sample) in data.enumerated()  {
                        value += sample["duration"] as? Double ?? 0.0
                    }
                }
                
            }
        }, failure:  { error in
            if let response = error {
                self.handleFitBitError(error: response)
            }
        })
    }
    
    
    /*//MARK:-Function to create FitBit Api URL.(Fitbit does not return result for 3 days according to time
     1     that is why we have to collect data for each day according to time selected by user.)*/
    @objc func getDataPeriodically(resourcePath:String,startDate:Date,endDate:Date,completion: @escaping (Double) -> Void) {
        let fitbitURL = "https://api.fitbit.com/1/user/-/\(resourcePath)/date/"
        let dayDifference = Common.getDaysDifference(firstDate: startDate, secondDate: endDate)
        if dayDifference == 0 {
            let apiUrl = "\(fitbitURL)\(startDate.UTCToLocal(inFormat: .fitbitDate))/today/time/\(startDate.UTCToLocal(inFormat: .fitbitTime))/\(endDate.UTCToLocal(inFormat: .fitbitTime)).json"
            self.fetchDataFromFibit(resourcePath: resourcePath,url: apiUrl){ (value) in
                completion(value)
            }
        }else{
            var totalResponse = 0.0
            var firstDate = startDate
            var apiUrl = ""
            firstDate = firstDate.dayAfter
            for i in 1...dayDifference {
                switch i {
                case 1:
                    apiUrl = "\(fitbitURL)\(firstDate.UTCToLocal(inFormat: .fitbitDate))/today/time/\(firstDate.UTCToLocal(inFormat: .fitbitTime))/24:00.json"
                    firstDate = firstDate.dayAfter
                case dayDifference :
                    apiUrl = "\(fitbitURL)\(firstDate.UTCToLocal(inFormat: .fitbitDate))/today/time/00:00/\(endDate.UTCToLocal(inFormat: .fitbitTime)).json"
                default:
                    apiUrl = "\(fitbitURL)\(firstDate.UTCToLocal(inFormat: .fitbitDate))/today/time/00:00/\(endDate.UTCToLocal(inFormat: .fitbitTime)).json"
                }
                firstDate = firstDate.dayAfter
                self.fetchDataFromFibit(resourcePath: resourcePath, url: apiUrl){ (value) in
                    totalResponse += value
                }
            }
            completion(totalResponse)
        }
    }
    
    //MARK:-This function will communicate with FitBit Apis.
    func fetchDataFromFibit(resourcePath:String,url:String,completion: @escaping (Double) -> Void) {
        let token = FitbitAuthHandler.getToken()
        let manager = FitbitAPIManager.shared()
        manager?.requestGET(url, token: token, success: { responseObject in
            if let response = responseObject {
                if let data = response["\(resourcePath.replace("/", replacement: "-"))"] as? [[String:Any]] {
                    let valueDict = data[0]
                    if let value = (valueDict["value"] as? String)?.toDouble() {
                        completion(value)
                    }else{
                        completion(0.0)
                    }
                }
            }
        }, failure:  { error in
            if let response = error {
                self.handleFitBitError(error: response)
            }
        })
    }
    
    //MARK:-This function will handle error created by FitBit Apis.
    func handleFitBitError(error:Error) {
        let errorData = error._userInfo?[AFNetworkingOperationFailingURLResponseDataErrorKey] as? Data
        var errorResponse: [AnyHashable : Any]? = nil
        do {
            if let errorData = errorData {
                errorResponse = try JSONSerialization.jsonObject(with: errorData, options: .allowFragments) as? [AnyHashable : Any]
            }
        } catch {
        }
        let errors = errorResponse?["errors"] as? [Any]
        let errorType = (errors?[0] as? NSObject)?.value(forKey: "errorType") as? String
        //   self.showAlert(message:"\(errorType)")
        print("errorTypeerrorTypeerrorType \(String(describing: errorType))")
        if (errorType == fInvalid_Client) || (errorType == fExpied_Token) || (errorType == fInvalid_Token) || (errorType == fInvalid_Request) {
            // To perform login if token is expired
            //            self.showAlert(withTitle: "FiBit Login", message: "You must login to FitBit, After login Tem can fetch your health data from fitbit App", okayTitle: "Login", cancelTitle: "Cancel", okStyle: .default, okCall: {
            FitbitAuthHandler.shareManager()?.loadVars()
            FitbitAuthHandler.shareManager()?.login(currentController)
            //            }) {
            //            }
        }else{
            //  self.showAlert(message:errorType)
        }
}

}
