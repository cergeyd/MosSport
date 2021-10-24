//
//  Dispatch.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import Foundation

class Dispatch {

    static func after(_ time: Double = 0.1, completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
            completion()
        }
    }

    static func main(completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            completion()
        }
    }

    static func global(completion: @escaping () -> Void) {
        DispatchQueue.global().async {
            completion()
        }
    }
}
