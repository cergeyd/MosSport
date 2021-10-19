//
//  MapMapAssembly.swift
//  MosSportMap
//
//  Created by sergiusX on 14/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import Swinject
import RxSwift

class MapModule: Assembly {

    func assemble(container: Container) {
        container.register(MapFactory.self) { r in
            return MapFactory(container: container)
        }
        container.register(MapViewController.self) { r in
            return MapViewController()
        }.initCompleted { (r, viewController) in
            viewController.output = r.resolve(MapPresenter.self)!
        }
        container.register(MapRouter.self) { r in
            MapRouter(viewController: r.resolve(MapViewController.self)!, detailFactory: r.resolve(DetailFactory.self)!, listInitialFactory: r.resolve(ListInitialFactory.self)!)
        }
        container.register(MapPresenter.self) { _ in MapPresenter() }
            .initCompleted { (r, presenter) in
            presenter.router = r.resolve(MapRouter.self)!
            presenter.interactor = r.resolve(MapInteractor.self)!
            presenter.view = r.resolve(MapViewController.self)!
        }
        container.register(MapInteractor.self) { r in MapInteractor(localService: r.resolve(LocalService.self)!) }
            .initCompleted { (r, interactor) in
            interactor.output = r.resolve(MapPresenter.self)!
            interactor.disposeBag = DisposeBag()
        }
    }
}
