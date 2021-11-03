//
//  SettingsSettingsPresenter.swift
//  MosSportMap
//
//  Created by Sergey D on 03/11/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

class SettingsPresenter {
    var interactor: SettingsInteractorInput!
    var router: SettingsRouter!
    weak var view: SettingsViewInput!
}

extension SettingsPresenter: SettingsViewOutput {

    func didLoadView() {
        self.view.setupInitialState()
    }
}

extension SettingsPresenter: SettingsInteractorOutput {

}
