//
//  AppDelegateService.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import UIKit

protocol AppDelegateService: AnyObject {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?, window: UIWindow)
    func application(_ app: UIApplication, open url: URL)
}

extension AppDelegateService {
    func application(_ app: UIApplication, open url: URL) { }
}
