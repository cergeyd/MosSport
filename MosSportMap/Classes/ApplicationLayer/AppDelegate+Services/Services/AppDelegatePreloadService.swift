//
//  AppDelegatePreloadService.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import UIKit
import RxSwift

class AppDelegatePreloadService: AppDelegateService {

    private let keychainService: KeychainService
    private let mosDataProcessing: MosDataProcessing
    
    init(keychainService: KeychainService, mosDataProcessing: MosDataProcessing) {
        self.keychainService = keychainService
        self.mosDataProcessing = mosDataProcessing
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?, window: UIWindow) {

    }
}
