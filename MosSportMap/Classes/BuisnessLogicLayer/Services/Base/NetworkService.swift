//
//  NetworkService.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import Foundation
import RxSwift

class NetworkService {

    internal let apiClient: APIClient
    internal let requestPatternFactory: RequestPatternFactory

    init(apiClient: APIClient, requestPatternFactory: RequestPatternFactory) {
        self.apiClient = apiClient
        self.requestPatternFactory = requestPatternFactory
    }
}
