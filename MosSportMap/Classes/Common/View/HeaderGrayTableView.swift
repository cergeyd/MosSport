//
//  HeaderGrayTableView.swift
//  MosSportMap
//
//  Created by Sergeyd on 22.10.2021.
//

import UIKit

class HeaderGrayTableView: View {

    lazy var label: UILabel = {
        var label = UILabel()
        label.numberOfLines = 1
        label.textColor = AppStyle.color(for: .subtitle)
        label.font = UIFont.systemFont(ofSize: 13.0, weight: .light)
        self.addSubview(label)
        return label
    }()

    //MARK: Lifecycle
    override func setUpLayout() {
        super.setUpLayout()
        self.backgroundColor = .clear
        self.label.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(22.0)
            make.bottom.equalToSuperview().inset(6.0)
        }
    }
}
