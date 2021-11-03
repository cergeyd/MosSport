//
//  SettingsSettingsAssembly.swift
//  MosSportMap
//
//  Created by Sergey D on 03/11/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import UIKit
import Swinject

class SettingsModule: Assembly {

    func assemble(container: Container) {
        container.register(SettingsFactory.self) { r in
            return SettingsFactory(container: container)
        }
        container.register(SettingsViewController.self) { r in
            return SettingsViewController()
        }.initCompleted { (r, viewController) in
            viewController.output = r.resolve(SettingsPresenter.self)!
        }
        container.register(SettingsRouter.self) { r in
            SettingsRouter(viewController: r.resolve(SettingsViewController.self)!)
        }
        container.register(SettingsPresenter.self) { _ in SettingsPresenter() }
            .initCompleted { (r, presenter) in
                presenter.router = r.resolve(SettingsRouter.self)!
                presenter.interactor = r.resolve(SettingsInteractor.self)!
                presenter.view = r.resolve(SettingsViewController.self)!
        }
        container.register(SettingsInteractor.self) { _ in SettingsInteractor() }
            .initCompleted { (r, interactor) in
                interactor.output = r.resolve(SettingsPresenter.self)!
        }
    }
}
