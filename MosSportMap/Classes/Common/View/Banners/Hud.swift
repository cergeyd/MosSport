//
//  Bulletin.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import Bulletin

class Hud {

    static let shared = Hud()

    lazy var bulletin: BulletinView = {
        let view = HudView()
        let _bulletin = BulletinView.hud()
        _bulletin.duration = .limit(30)
        _bulletin.snp_embed(content: view, usingStrictHeightConstraint: view.snp.width)
        return _bulletin
    }()

    static func show() {
        Hud.shared.bulletin.present()
    }

    static func hide() {
        Dispatch.after {
            Hud.shared.bulletin.dismiss()
        }
    }
}

class HudView: UIView {

    var backgroundBlurView: UIVisualEffectView!
    var activityIndicator: UIActivityIndicatorView!

    //MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }

    //MARK: Private func
    private func setup() {
        self.backgroundColor = UIColor.clear
        self.backgroundBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        self.addSubview(backgroundBlurView)
        self.backgroundBlurView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        self.activityIndicator = UIActivityIndicatorView(style: .large)
        self.activityIndicator.color = .white
        self.addSubview(activityIndicator)
        self.activityIndicator.snp.makeConstraints { (make) in
            make.edges.equalTo(self).inset(20)
        }
        self.activityIndicator.startAnimating()
    }
}
