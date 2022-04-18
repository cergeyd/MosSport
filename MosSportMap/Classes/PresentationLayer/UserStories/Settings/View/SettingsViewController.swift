//
//  SettingsSettingsViewController.swift
//  MosSportMap
//
//  Created by Sergey D on 03/11/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import UIKit

class SettingsViewController: TableViewController {

    struct Config {
        static let animationDuration = 0.4
        static let width = 0.5
    }

    var output: SettingsViewOutput!
    lazy var filesBrowser: FilesBrowser = {
        let _filesBrowser = FilesBrowser(controller: self)
        _filesBrowser.delegate = self
        return _filesBrowser }()
    private let sections = [
        SettingSection(header: "Дополнительные спортивные объекты", type: .OSM),
        SettingSection(header: "Относительная величина расчёта", type: .calculated),
        SettingSection(header: "Загрузить новые объекты", type: .download),
    ]

    // MARK: Lifecycle
    override func viewDidLoad() {
        self.configureTableView()
        super.viewDidLoad()
        self.output.didLoadView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: Config.animationDuration) {
            self.splitViewController?.preferredPrimaryColumnWidthFraction = Config.width
        }
    }

    // MARK: Private func
    private func configureTableView() {
        self.tableView = UITableView(frame: .zero, style: .insetGrouped)
        self.tableView.register(UINib(nibName: CalculateSettingsCell.identifier, bundle: nil), forCellReuseIdentifier: CalculateSettingsCell.identifier)
        self.tableView.register(UINib(nibName: OSMSettingsCell.identifier, bundle: nil), forCellReuseIdentifier: OSMSettingsCell.identifier)
        self.tableView.register(UINib(nibName: DownloadSettingsCell.identifier, bundle: nil), forCellReuseIdentifier: DownloadSettingsCell.identifier)
    }

    // MARK: TableView
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 1) {
            let isFull = currentCalculatePerPeoples != 0
            return isFull ? 180.0 : 110.0
        }
        return UITableView.automaticDimension
    }

    private func section(at section: Int) -> SettingSection {
        return self.sections[section]
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = self.section(at: section)
        return section.header
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = self.section(at: indexPath.section)
        switch section.type {
        case .OSM:
            let settingsCell = tableView.dequeueReusableCell(withIdentifier: OSMSettingsCell.identifier) as! OSMSettingsCell
            settingsCell.delegate = self
            settingsCell.configure(with: UserDefaults.isOSMObjects)
            return settingsCell
        case .calculated:
            let calculateCell = tableView.dequeueReusableCell(withIdentifier: CalculateSettingsCell.identifier) as! CalculateSettingsCell
            calculateCell.delegate = self
            let density = UserDefaults.averageDensity
            calculateCell.configure(with: density == 0, value: density)
            return calculateCell
        case .download:
            let downloadCell = tableView.dequeueReusableCell(withIdentifier: DownloadSettingsCell.identifier) as! DownloadSettingsCell
            downloadCell.delegate = self
            downloadCell.configure(with: "hello")
            return downloadCell
        }
    }
}

extension SettingsViewController: SettingsViewInput {

    func setupInitialState() {
        self.title = "Настройки"
    }
}

// MARK: Cell Delegates
extension SettingsViewController: SettingsCellDelegate, CalculateSettingsCellDelegate, DownloadSettingsCellDelegate, FilesBrowserDelegate {

    func didDownload(file url: URL) {
        /// Новые объекты.
        /// т.к. изначально формат не оптимальный (куча одинаковы объектов с разными играми лишь
        /// сделаем нормально -> переведём в наш формат (1н объект с массивом игр))
        let newObjects = CVSModule.parseCSV(filepath: url)
        let objects = SharedManager.shared.fromMultipleSportToSingle(objects: newObjects)
        self.murmur(text: "Успешно добавлено", subtitle: "\(objects.count) новых объекта")
    }

    /// Локально загружаем список объектов
    func didTapDownload() {
        self.filesBrowser.show()
    }

    /// Конкретная плотность населения
    func didSetAverage(density: Int?) {
        lastSelectedAreaReport = nil
        let _density = density ?? 0
        UserDefaults.averageDensity = _density
        currentCalculatePerPeoples = _density
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }

    /// Обновим с будущим API
    func didUpdateAdditioOSMObjects() {
        let isOSMObjects = !UserDefaults.isOSMObjects
        UserDefaults.isOSMObjects = isOSMObjects
        SharedManager.shared.updateSportObjectsList(isOSMObjects: isOSMObjects)
    }
}
