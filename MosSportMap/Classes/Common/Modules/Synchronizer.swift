//
//  Synchronizer.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import Foundation

class Synchronizer {

    typealias SimpleNotifyAlias = () -> (Void)

    let dispatchGroup = DispatchGroup()

    private let wait: Int

    var hadSync = false
    var notify: SimpleNotifyAlias?
    var currentCount = 0

    init(wait until: Int) {
        self.wait = until
        self.run()
    }

    func updateState() {
        self.hadSync = false
        for _ in 0...self.wait - 1 {
            self.currentCount += 1
            self.dispatchGroup.enter()
        }
        self.dispatchGroup.notify(queue: .main) {
            self.hadSync = true
            self.notify?()
        }
    }

    //MARK: Public
    func leave(isNotifyIfMultipleTimesCall: Bool = false) {
        guard (!self.hadSync) else {
            if (isNotifyIfMultipleTimesCall) {
                self.notify?()
            } else {
                print("Wrong Synchronizer wait - \(self.wait) but .leave() called more")
            }
            return
        }
        if (self.currentCount > 0) {
            self.currentCount -= 1
            self.dispatchGroup.leave()
        } else {
            if (isNotifyIfMultipleTimesCall) {
                self.notify?()
            }
            print("Wrong Synchronizer wait - \(self.wait) but .leave() called more")
        }
    }

    //MARK: Private
    private func run() {
        for _ in 0...self.wait - 1 {
            self.currentCount += 1
            self.dispatchGroup.enter()
        }

        self.dispatchGroup.notify(queue: .main) {
            self.hadSync = true
            self.notify?()
        }
    }
}
