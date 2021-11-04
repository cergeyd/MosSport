//
//  AppDelegateUnauthorizedService.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import UIKit
import RxSwift

class AppDelegateUnauthorizedService: AppDelegateService, UISplitViewControllerDelegate {

    struct Config {
        static let preferredPrimaryColumnWidth = 0.35
        static let maximumPrimaryColumnWidth = 1000.0
    }

    private let menuFactory: MenuFactory
    private let mapFactory: MapFactory
    let disposeBag = DisposeBag()

    init(menuFactory: MenuFactory, mapFactory: MapFactory) {
        self.menuFactory = menuFactory
        self.mapFactory = mapFactory
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?, window: UIWindow) {
        self.showSplit(with: window)
    }

    //MARK: Private func
    private func showSplit(with window: UIWindow) {
        let masterController = self.menuFactory.instantiateModule()
        let masterNavigationController = UINavigationController(rootViewController: masterController)

        let detailController = self.mapFactory.instantiateModule()
        let detailNavigationController = UINavigationController(rootViewController: detailController)
        masterController.delegate = detailController

        let splitViewController = UISplitViewController()
        splitViewController.delegate = self
        splitViewController.viewControllers = [masterNavigationController, detailNavigationController]
        splitViewController.preferredDisplayMode = .oneBesideSecondary
        splitViewController.preferredPrimaryColumnWidthFraction = Config.preferredPrimaryColumnWidth
        splitViewController.maximumPrimaryColumnWidth = Config.maximumPrimaryColumnWidth
        window.rootViewController = splitViewController
        window.makeKeyAndVisible()
    }
    
    func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewController.DisplayMode) {
        NotificationCenter.default.post(name: NSNotification.Name.didChangeDisplayMode, object: displayMode)
    }
}
