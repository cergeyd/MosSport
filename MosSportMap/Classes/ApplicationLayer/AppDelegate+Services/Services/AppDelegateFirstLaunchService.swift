//
//  AppDelegateFirstLaunchService.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import UIKit
import UserNotifications

class AppDelegateFirstLaunchService: NSObject, AppDelegateService {

    private let keychainService: KeychainService
    private let notifications: NotificationCenter

    init(keychainService: KeychainService, notifications: NotificationCenter) {
        self.keychainService = keychainService
        self.notifications = notifications
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?, window: UIWindow) {
 
    }
}
