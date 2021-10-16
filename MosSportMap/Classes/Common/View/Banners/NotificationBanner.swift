//
//  NotificationBanner.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import Bulletin

class NotificationBanner {

    static let shared = NotificationBanner()
    lazy var bulletin: BulletinView = {
        let _bulletin = BulletinView.notification()
        _bulletin.style.roundedCornerRadius = 8
        _bulletin.style.shadowRadius = 10
        _bulletin.style.shadowAlpha = 0.3
        if (UIDevice.current.isModern) {
            _bulletin.style.roundedCornerRadius = 18
            _bulletin.style.edgeInsets = UIEdgeInsets(horizontal: 14, vertical: UIScreen.main.displayFeatureInsets.top + 4)
        }
        _bulletin.embed(content: NotificationBanner.shared.notificationView)
        _bulletin.action = {

        }
        return _bulletin
    }()
    lazy var notificationView: NotificationView = {
        let view = NotificationView()
        return view
    }()

    static func show(with title: String, subtitle: String, time: String, image: UIImage?) {
        NotificationBanner.shared.notificationView.iconImageView.image = image
        NotificationBanner.shared.notificationView.timeLabel.text = time
        NotificationBanner.shared.notificationView.titleLabel.text = title
        NotificationBanner.shared.notificationView.messageLabel.text = subtitle
        Banner.shared.bulletin.duration = .limit(7)
        NotificationBanner.shared.bulletin.present()
    }

    static func hide() {
        Hud.shared.bulletin.dismiss()
    }
}

class NotificationView: UIView {

    var backgroundBlurView: UIVisualEffectView!

    var topContentView: UIView!
    var iconImageView: UIImageView!
    var iconTitleLabel: UILabel!
    var timeLabel: UILabel!

    var titleLabel: UILabel!
    var messageLabel: UILabel!

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
        self.backgroundBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        self.addSubview(backgroundBlurView)
        self.backgroundBlurView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        self.topContentView = UIView()
        self.topContentView.backgroundColor = UIColor.clear
        self.addSubview(topContentView)
        self.topContentView.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(0)
            make.height.equalTo(34)
        }
        self.iconImageView = UIImageView()
        self.iconImageView.backgroundColor = UIColor.clear
        self.iconImageView.contentMode = .scaleToFill
        self.iconImageView.layer.cornerRadius = 4
        self.iconImageView.clipsToBounds = true
        self.topContentView.addSubview(iconImageView)
        self.iconImageView.snp.makeConstraints { (make) in
            make.top.equalTo(8)
            make.left.equalTo(12)
            make.bottom.equalTo(-8)
            make.width.equalTo(iconImageView.snp.height)
        }
        self.timeLabel = UILabel()
        self.timeLabel.textColor = UIColor.black.withAlphaComponent(0.4)
        self.timeLabel.font = UIFont.systemFont(ofSize: 12)
        self.timeLabel.textAlignment = .right
        self.topContentView.addSubview(timeLabel)
        self.timeLabel.snp.makeConstraints { (make) in
            make.right.equalTo(-12)
            make.top.bottom.equalTo(0)
        }
        self.iconTitleLabel = UILabel()
        self.iconTitleLabel.textColor = UIColor.black.withAlphaComponent(0.4)
        self.iconTitleLabel.font = UIFont.systemFont(ofSize: 12)
        self.topContentView.addSubview(iconTitleLabel)
        self.iconTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(iconImageView.snp.right).offset(6)
            make.top.bottom.equalTo(0)
            make.right.equalTo(timeLabel.snp.left).offset(-6)
        }
        self.titleLabel = UILabel()
        self.titleLabel.textColor = UIColor.black
        self.titleLabel.font = UIFont.boldSystemFont(ofSize: 13)
        self.titleLabel.numberOfLines = 0
        self.titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        self.titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.addSubview(titleLabel)
        self.titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(topContentView.snp.bottom)
            make.left.equalTo(12)
            make.right.equalTo(-12)
        }
        self.messageLabel = UILabel()
        self.messageLabel.textColor = UIColor.black
        self.messageLabel.font = UIFont.systemFont(ofSize: 13)
        self.messageLabel.numberOfLines = 0
        self.messageLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        self.messageLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        self.addSubview(messageLabel)
        self.messageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.left.right.equalTo(titleLabel)
            make.bottom.equalTo(-12)
        }
    }
}
