//
//  DateExtension.swift
//  FitbitDataFetcher
//
//  Created by Harpreet_kaur on 22/08/19.
//  Copyright © 2019 Harpreet_kaur. All rights reserved.
//

import Foundation
import UIKit


enum DateFormat {
    case preDefined
    case display
    case fitbitDate
    case fitbitTime
    case sleep
    
    var format: String {
        switch self {
        case .preDefined: return "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        case .display: return "MMM dd, yyyy"
        case .fitbitDate: return "yyyy-MM-dd"
        case .fitbitTime: return "HH:mm"
        case .sleep: return "yyyy-MM-dd hh:mm a"
        }
    }
}
extension Date {
    
    static var yesterday: Date { return Date().dayBefore }
    static var tomorrow:  Date { return Date().dayAfter }
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }
    
    func toString(inFormat format: DateFormat) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = format.format
        return dateFormatter.string(from: self)
    }
    
    func UTCToLocal(inFormat format: DateFormat) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = format.format
        return dateFormatter.string(from: self)
    }
}//Extnsion....

class DIDateFormator:NSObject {
    class func format(dateFormat:DateFormat = .preDefined) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.dateFormat = dateFormat.format
        dateFormatter.locale =  Locale(identifier: "en")
        return dateFormatter
    }
    class func localFormat(dateFormat:DateFormat = .preDefined) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone.local
        dateFormatter.dateFormat = dateFormat.format
        dateFormatter.locale =  Locale(identifier: "en")
        return dateFormatter
    }
}
