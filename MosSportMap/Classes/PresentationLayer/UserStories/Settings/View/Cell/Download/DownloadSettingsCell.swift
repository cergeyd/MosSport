//
//  DownloadSettingsCell.swift
//  MosSportMap
//
//  Created by Sergey D on 05.11.2021.
//

import UIKit

protocol DownloadSettingsCellDelegate: AnyObject {
    func didTapDownload()
}

class DownloadSettingsCell: TableViewCell {

    weak var delegate: DownloadSettingsCellDelegate?

    // MARK: Func
    func configure(with titles: String) {

    }

    // MARK: Action
    @IBAction func didTapDownload() {
        self.delegate?.didTapDownload()
    }

    @IBAction func didTapUpdate(sender: ActivityButton) {
        sender.loading(isBegin: true)
        Dispatch.after(0.6) {
            sender.loading(isBegin: false)
        }
    }
}
