//
//  UIViewController.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import UIKit

extension UIViewController {

    static func topController() -> UIViewController? {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }

    func presentOnRoot(`with` viewController: UIViewController, animated: Bool = true, style: UIModalPresentationStyle = .fullScreen) {
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = style
        self.present(navigationController, animated: animated, completion: nil)
    }

    func push(_ viewController: UIViewController, animated: Bool = true) {
        self.navigationController?.pushViewController(viewController, animated: animated)
    }

    func addViewController(_ viewController: UIViewController, frame: CGRect, completion: (() -> Void)?) {
        viewController.willMove(toParent: self)
        viewController.beginAppearanceTransition(true, animated: false)
        addChild(viewController)
        viewController.view.frame = frame
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
        viewController.endAppearanceTransition()
        completion?()
    }

    func murmur(text: String, isError: Bool = true, subtitle: String = "", duration: Double = 1.0) {
        if (isError) {
            Banner.show(with: text, subtitle: subtitle, time: "now", image: R.image.warning()!)
        } else {
            NotificationBanner.show(with: text, subtitle: subtitle, time: "now", image: R.image.warning())
        }
    }

    func hideKeyboardWhenTappedAround(_view: UIView? = nil) {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        if let view = _view {
            view.addGestureRecognizer(tap)
        } else {
            view.addGestureRecognizer(tap)
        }
    }

    func navigationActivity(isRightItem: Bool = true) {
        let uiBusy = UIActivityIndicatorView(style: .medium)
        uiBusy.color = AppStyle.color(for: .coloured)
        uiBusy.hidesWhenStopped = true
        uiBusy.startAnimating()
        if (isRightItem) {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: uiBusy)
        } else {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: uiBusy)
        }
    }

    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}
