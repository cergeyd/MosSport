//
//  MenuCell.swift
//  MosSportMap
//
//  Created by Sergeyd on 15.10.2021.
//

import UIKit

class MenuCell: TableViewCell {

    lazy var title: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 13.0, weight: .medium)
        self.contentView.addSubview(label)
        return label
    }()
    lazy var subtitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11.0, weight: .regular)
        label.textColor = #colorLiteral(red: 0.5704585314, green: 0.5704723597, blue: 0.5704649091, alpha: 1)
        label.numberOfLines = 0
        self.contentView.addSubview(label)
        return label
    }()
    
    //MARK: Lifecycle
    override func setUpLayout() {
        self.title.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12.0)
            make.left.equalToSuperview().offset(16.0)
            make.right.equalToSuperview().inset(12.0)
        }
        self.subtitle.snp.makeConstraints { make in
            make.top.equalTo(self.title.snp.bottom).offset(6.0)
            make.left.equalTo(self.title)
            make.right.equalTo(self.title)
            make.bottom.equalToSuperview().inset(6.0)
        }
    }
    
    //MARK: Func
    func configure(with menu: MenuItem) {
        self.title.text = menu.title
        self.subtitle.text = menu.subtitle
    }
}
