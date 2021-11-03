//
//  UserDefaults.swift
//  MosSportMap
//
//  Created by Sergey D on 03.11.2021.
//

import Foundation

extension UserDefaults {

    private enum Keys {
        static let isOSMObjects = "isOSMObjects"
        static let averageDensity = "averageDensity"
    }

    /// Учитывать ли дополнительные объекты
    class var isOSMObjects: Bool {
        get { return UserDefaults.standard.bool(forKey: Keys.isOSMObjects) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.isOSMObjects) }
    }
    
    /// Относительный расчёт
    class var averageDensity: Int {
        get { return UserDefaults.standard.integer(forKey: Keys.averageDensity)}
        set { UserDefaults.standard.set(newValue, forKey: Keys.averageDensity) }
    }
}
