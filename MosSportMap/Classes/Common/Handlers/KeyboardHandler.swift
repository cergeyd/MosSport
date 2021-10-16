//
//  KeyboardHandler.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import UIKit

protocol KeyboardHandlerDataSource: AnyObject {
    func currentScrollView() -> UIScrollView?
}

protocol KeyboardHandlerDelegate where Self: KeyboardHandlerDataSource {
    func didUpdateKeyboard(height: CGFloat, duration: Double, isShown: Bool)
}

extension KeyboardHandlerDelegate {
    func didUpdateKeyboard(height: CGFloat, duration: Double, isShown: Bool) {
        if let scrollView = self.currentScrollView() {
            if (isShown) {
                scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: height, right: 0)
            } else {
                scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }
        }
    }
}

class KeyboardHandler {
    public static let shared = KeyboardHandler()
    private let notificationCenter = NotificationCenter.default

    var isKyboardShown = false
    weak public var dataSource: KeyboardHandlerDataSource?
    lazy private var younce: Void = { self.setupKeyboardObserver() }()
    private var listeners: [KeyboardHandlerDelegate] = [] {
        didSet {
            let _ = self.younce
        }
    }
    weak var delegate: KeyboardHandlerDelegate? {
        didSet {
            let _ = self.younce
        }
    }

    func add(delegate: KeyboardHandlerDelegate) {
        if (delegate.currentScrollView() == nil) {
            self.listeners.append(delegate)
            return
        }
        let exist = self.listeners.filter { (current) -> Bool in
            return current.currentScrollView() == delegate.currentScrollView()
        }
        if (exist.isEmpty) {
            self.listeners.append(delegate)
        }
    }

    func remove(delegate: KeyboardHandlerDelegate) {

    }

    private func setupKeyboardObserver() {
        self.notificationCenter.addObserver(self, selector: #selector(KeyboardHandler.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        self.notificationCenter.addObserver(self, selector: #selector(KeyboardHandler.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func keyboardWillChange(userInfo: [AnyHashable: Any]?, isShown: Bool = false) {
        if let userInfo = userInfo {
            if let height = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
                if let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue {
                    let safeHeight = height - UIScreen.main.bottomInsetSafeArea()
                    if (self.isKyboardShown != isShown) {
                        for listener in self.listeners {
                            listener.didUpdateKeyboard(height: safeHeight, duration: duration, isShown: isShown)
                        }
                        self.isKyboardShown = isShown
                    }
                }
            }
        }
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        self.keyboardWillChange(userInfo: notification.userInfo, isShown: true)
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.keyboardWillChange(userInfo: notification.userInfo)
    }
}
