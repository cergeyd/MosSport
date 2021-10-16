//
//  MapMapInteractor.swift
//  MosSportMap
//
//  Created by sergiusX on 14/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import RxSwift

class MapInteractor {
    weak var output: MapInteractorOutput?
    private let localService: LocalService!
    var disposeBag: DisposeBag!

    init(localService: LocalService) {
        self.localService = localService
    }
}

extension MapInteractor: MapInteractorInput {

}
