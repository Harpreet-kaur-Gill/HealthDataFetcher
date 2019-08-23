//
//  Common.swift
//  FitbitDataFetcher
//
//  Created by Harpreet_kaur on 22/08/19.
//  Copyright © 2019 Harpreet_kaur. All rights reserved.
//

import Foundation
import UIKit
@objc public class Common : NSObject {
    
    class func getDaysDifference(firstDate:Date,secondDate:Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: firstDate, to: secondDate)
        return components.day ?? 0
    }
    
    class func getMinutesDifference(firstDate:Date,secondDate:Date) -> Int {
        return Int(secondDate.timeIntervalSince(firstDate)/60)
    }
    
    @objc public class func presentFitBitController(url:String) {
        if let _ = UIApplication.topViewController() as? FitBitLogin {
        }else{
            guard let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "FitBitLogin") as? FitBitLogin else{
                return
            }
            vc.urlString = url
            UIApplication.topViewController()?.navigationController?.pushViewController(vc , animated: true)
        }
    }
    
    @objc public class func removeFitBitController() {
        UIApplication.topViewController()?.navigationController?.popViewController(animated: true)
    }
}

extension String {
    
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
    
    func replace(_ string: String, replacement: String) -> String {
        return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }
    
    func utcToLocal(_ withFormat: DateFormat = .preDefined, toFormat: DateFormat = .preDefined) -> String {
        let dateFormatter = DIDateFormator.format(dateFormat: withFormat)
        guard let date = dateFormatter.date(from: self) else {
            return ""
        }
        dateFormatter.dateFormat = toFormat.format
        dateFormatter.timeZone = NSTimeZone.local
        return dateFormatter.string(from: date)
    }
    
    func toDate( dateFormat format  : DateFormat = .preDefined) -> Date {
        let dateFormatter = DIDateFormator.format(dateFormat: format)
        if let date = dateFormatter.date(from: self){
            return date
        }
        //print("Invalid arguments ! Returning Current Date . ")
        return Date()
    }
}


extension UIApplication {
    class func topViewController(base: UIViewController? = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
