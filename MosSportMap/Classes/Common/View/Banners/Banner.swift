//
//  Bulletin.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import Bulletin

class Banner {

    static let shared = Banner()

    lazy var bulletin: BulletinView = {
        let _bulletin = BulletinView.banner()
        _bulletin.style.statusBar = .lightContent
        _bulletin.embed(content: self.bannerView)
        _bulletin.action = {

        }
        return _bulletin
    }()
    lazy var bannerView: BannerView = {
        let view = BannerView()
        return view
    }()

    static func show(with title: String, subtitle: String, time: String, image: UIImage, duration: Double = 3.0) {
        Banner.shared.bannerView.iconImageView.image = image
        Banner.shared.bannerView.titleLabel.text = title
        Banner.shared.bannerView.timeLabel.text = time
        Banner.shared.bannerView.messageLabel.text = subtitle
        Banner.shared.bulletin.duration = .limit(duration)
        Banner.shared.bulletin.present()
    }

    static func hide() {
        Hud.shared.bulletin.dismiss()
    }
}

class BannerView: UIView {
    
    var backgroundBlurView: UIVisualEffectView!
    var statusBarView: UIView!
    let statusBarFrameHeight = UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame.height ?? 20.0
    var iconImageView: UIImageView!
    var titleLabel: UILabel!
    var timeLabel: UILabel!
    var messageLabel: UILabel!
    var grabberView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private func setup() {
        self.backgroundColor = UIColor.clear
        
        self.backgroundBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        self.addSubview(backgroundBlurView)
        self.backgroundBlurView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        self.statusBarView = UIView()
        self.statusBarView.backgroundColor = UIColor.clear
        self.addSubview(statusBarView)

        self.statusBarView.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(0)
            make.height.equalTo(statusBarFrameHeight)
        }
        
        self.grabberView = UIView()
        self.grabberView.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        self.grabberView.layer.cornerRadius = 3
        self.addSubview(grabberView)
        self.grabberView.snp.makeConstraints { (make) in
            make.bottom.equalTo(-6)
            make.centerX.equalTo(self)
            make.width.equalTo(44)
            make.height.equalTo(6)
        }
        
        self.iconImageView = UIImageView()
        self.iconImageView.backgroundColor = UIColor.clear
        self.iconImageView.contentMode = .scaleToFill
        self.iconImageView.layer.cornerRadius = 6
        self.iconImageView.clipsToBounds = true
        self.addSubview(iconImageView)
        self.iconImageView.snp.makeConstraints { (make) in
            make.top.equalTo(statusBarView.snp.bottom).offset(6)
            make.left.equalTo(12)
            make.width.height.equalTo(22)
        }
        
        self.titleLabel = UILabel()
        self.titleLabel.textColor = UIColor.white
        self.titleLabel.font = UIFont.boldSystemFont(ofSize: 13)
        self.titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        self.titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        self.titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        self.titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.addSubview(titleLabel)
        self.titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(iconImageView)
            make.left.equalTo(iconImageView.snp.right).offset(8)
        }
        
        self.timeLabel = UILabel()
        self.timeLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        self.timeLabel.font = UIFont.systemFont(ofSize: 12)
        self.timeLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        self.timeLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        self.addSubview(timeLabel)
        self.timeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel.snp.right).offset(8)
            make.right.equalTo(-12)
            make.bottom.equalTo(titleLabel)
        }
        
        self.messageLabel = UILabel()
        self.messageLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        self.messageLabel.font = UIFont.systemFont(ofSize: 13)
        self.messageLabel.numberOfLines = 0
        self.messageLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        self.messageLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        self.addSubview(messageLabel)
        self.messageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.left.equalTo(titleLabel)
            make.right.equalTo(-12)
            make.bottom.equalTo(grabberView.snp.top).offset(-12)
        }
    }
}
