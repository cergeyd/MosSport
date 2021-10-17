//
//  LoadXibByClass.swift
//  MosSportMap
//
//  Created by Sergeyd on 18.10.2021.
//

import UIKit

class LoadXibByClass: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }

    func initialize() {
        let nibName = NSStringFromClass(type(of: self)).components(separatedBy: ".").last!
        guard let view = Bundle.main.loadNibNamed(nibName, owner: self, options: nil)?[0] as? UIView else {
            fatalError("view not should be nil")
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        let constraints = [
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            view.topAnchor.constraint(equalTo: self.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ]
        self.addConstraints(constraints)
    }
}
