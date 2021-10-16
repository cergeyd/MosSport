//
//  Date.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import Foundation

extension Date {
//
//    func isEqualTo(_ date: Date) -> Bool {
//        return self == date
//    }
//
//    func isGreaterThan(_ date: Date) -> Bool {
//        return self > date
//    }
//
//    func isSmallerThan(_ date: Date) -> Bool {
//        return self < date
//    }

    func key() -> String {
        return self.getDay() + self.getMonth() + self.getYear()
    }

    func getMinutes() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "mm"
        let strMonth = dateFormatter.string(from: self)
        return strMonth
    }

    var milliseconds: Double {
        return self.timeIntervalSinceReferenceDate * 1000.0
    }

    func getSeconds() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ss"
        let strMonth = dateFormatter.string(from: self)
        return strMonth
    }

    func getHours() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        let strMonth = dateFormatter.string(from: self)
        return strMonth
    }

    func getMonth() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        let strMonth = dateFormatter.string(from: self)
        return strMonth
    }

    func getMonthName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        let strMonth = dateFormatter.string(from: self)
        return strMonth
    }

    func getDay() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        let strMonth = dateFormatter.string(from: self)
        return strMonth
    }
    
    func getDayName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let dayInWeek = dateFormatter.string(from: self)
        return dayInWeek
    }

    func getYear() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let strMonth = dateFormatter.string(from: self)
        return strMonth
    }

    func getYearLast() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy"
        let strMonth = dateFormatter.string(from: self)
        return strMonth
    }

    func requestStyle(isSeconds: Bool = false) -> String {
        var date = ""
        if (isSeconds) {
            date = self.getDay() + "." + self.getMonth() + "." + self.getYearLast() + " в " + self.getHours() + ":" + self.getMinutes()
            date += ":" + self.getSeconds()
        } else {
            date = self.getDay() + " " + self.getMonthName() + " " + self.getYear() + " в " + self.getHours() + ":" + self.getMinutes()
        }
        return date
    }

    func fromStyle() -> String {
        return "С " + self.getDay() + " " + self.getMonthName() + " " + self.getYear()
    }

    func toStyle() -> String {
        return "по " + self.getDay() + " " + self.getMonthName() + " " + self.getYear()
    }

    func dateAndTimeStyle() -> String {
        return self.getDay() + "." + self.getMonth() + "." + self.getYear() + " " + self.getHours() + ":" + self.getMinutes()
    }

    func dateUsualTimeStyle() -> String {
        return self.getDay() + " " + self.getMonthName() + ", " + self.getHours() + ":" + self.getMinutes()
    }

    func dateStyle() -> String {
        return self.getDay() + "." + self.getMonth() + "." + self.getYear()
    }

    func onlyDate() -> String {
        return self.getHours() + ":" + self.getMinutes()
    }
    
    func dateNday() -> String {
        return self.getHours() + ":" + self.getMinutes() + " " + self.getDay() + " " + self.getMonthName()
    }

    func onlyMinutes() -> String {
        return self.getMinutes() + ":" + self.getSeconds()
    }

    func onlyDay() -> String {
        return self.getDay() + " " + self.getMonthName()
    }
    
    func superOnlyDay() -> String {
        return self.getDay()
    }
    
    func twoDayName() -> String {
        var text = ""
        let dayName = self.getDayName()
        for (ind, d) in dayName.enumerated() {
            text += String(d)
            if (ind == 1) {
                return text
            }
        }
        return text
    }
    // +
    func passStyle() -> String {
        return self.getDay() + " " + self.getMonthName() + " " + self.getYear()
    }

    // +
    func dayNmount() -> String {
        return self.getDay() + " " + self.getMonthName()
    }
}
