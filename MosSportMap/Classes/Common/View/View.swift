//
//  View.swift
//  MosSportMap
//
//  Created by Sergeyd on 22.10.2021.
//

import UIKit

class View: UIView {

    public static var identifier: String {
        return String(describing: self)
    }

    //MARK: Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func setUpLayout() {

    }
}
