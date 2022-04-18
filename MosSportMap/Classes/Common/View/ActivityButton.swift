//
//  ActivityButton.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import UIKit

class ActivityButton: UIButton {

    var isFilled = false
    var originalButtonText: String?
    var originalButtonImage: UIImage?
    var originButtonImageInsets: UIEdgeInsets?
    lazy var activityIndicator: UIActivityIndicatorView = { return self.createActivityIndicator(isFilled: self.isFilled) }()

    // MARK: Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 6.0
    }

    // MARK: Func
    func standart(with title: String) {
        self.backgroundColor = AppStyle.color(for: .background)
        self.titleLabel?.font = AppStyle.font(size: .title, width: .semibold)
        self.setTitle(title, for: .normal)
        self.layer.cornerRadius = 6.0
    }
}

// MARK: Activity
extension ActivityButton {

    func loading(isBegin: Bool, color: UIColor = .white, newTitle: String? = nil, image: UIImage? = nil, isCircle: Bool = false) {
        self.isHidden = false
        if (isBegin) {
            self.activityIndicator.color = color
            self.originalButtonText = self.titleLabel?.text
            self.originalButtonImage = self.imageView?.image
            self.setTitle(nil, for: .normal)
            self.setImage(nil, for: .normal)
            self.showSpinning()
            if (isCircle) {
                self.backgroundColor = .white
                self.layer.cornerRadius = self.frame.width / 2
                self.clipsToBounds = true
            }
        } else {
            if let newTitle = newTitle {
                self.originalButtonText = newTitle
            } else {
                self.originalButtonText = self.titleLabel?.text
            }
            if let originalButtonImage = self.originalButtonImage {
                self.setImage(originalButtonImage, for: .normal)
            } else {
                self.setImage(image, for: .normal)
            }
            self.setTitle(self.originalButtonText, for: .normal)
            self.activityIndicator.stopAnimating()
        }
    }

    private func createActivityIndicator(isFilled: Bool) -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.backgroundColor = .clear
        activityIndicator.stopAnimating()
        if (!isFilled) {
            activityIndicator.color = .black
        } else {
            activityIndicator.color = .white
        }
        return activityIndicator
    }

    private func showSpinning() {
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.activityIndicator)
        self.centerActivityIndicatorInButton()
        self.activityIndicator.startAnimating()
    }

    private func centerActivityIndicatorInButton() {
        let xCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: activityIndicator, attribute: .centerX, multiplier: 1, constant: 0)
        self.addConstraint(xCenterConstraint)

        let yCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: activityIndicator, attribute: .centerY, multiplier: 1, constant: 0)
        self.addConstraint(yCenterConstraint)
    }
}
