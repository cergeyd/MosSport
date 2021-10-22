//
//  Int+Extension.swift
//  MosSportMap
//
//  Created by Sergeyd on 22.10.2021.
//

import Foundation

extension Int {
    func peoples() -> String {
        var dayString: String!
        if "1".contains("\(self % 10)") { dayString = "Человек" }
        if "234".contains("\(self % 10)") { dayString = "Человека" }
        if "567890".contains("\(self % 10)") { dayString = "Человек" }
        if 11...14 ~= self % 100 { dayString = "Человек" }
        return "\(self) " + dayString
    }

    func departments() -> String {
        var dayString: String!
        if "1".contains("\(self % 10)") { dayString = "Департамент" }
        if "234".contains("\(self % 10)") { dayString = "Департамента" }
        if "567890".contains("\(self % 10)") { dayString = "Департаментов" }
        if 11...14 ~= self % 100 { dayString = "Департаментов" }
        return "\(self) " + dayString
    }

    func objects() -> String {
        var dayString: String!
        if "1".contains("\(self % 10)") { dayString = "Объект" }
        if "234".contains("\(self % 10)") { dayString = "Объекта" }
        if "567890".contains("\(self % 10)") { dayString = "Объектов" }
        if 11...14 ~= self % 100 { dayString = "Объектов" }
        return "\(self) " + dayString
    }
}
