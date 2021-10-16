//
//  AppDelegate.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import UIKit
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    private let appDelegateAssembler = AppDelegateAssembler()
    var services: [AppDelegateService]!
    var window: UIWindow?

    override init() {
        super.init()
        self.appDelegateAssembler.resolveDependencies(appDelegate: self)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        GMSServices.provideAPIKey(googleAPIkey)
        for service in self.services { service.application(application, didFinishLaunchingWithOptions: launchOptions, window: self.window!) }
        return true
    }
}
