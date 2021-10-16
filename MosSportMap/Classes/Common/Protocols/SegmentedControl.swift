//
//  UserStoriesFactory.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import Foundation
import Pageboy

struct SegmentConfig {
    static let controlTopOffSet: CGFloat = 12.0
    static let controlLeftOffSet: CGFloat = 16.0
    static let controlHeight: CGFloat = 36
}

protocol SegmentProtocol where Self: PageboyViewController {
    var viewControllers: [UIViewController] { get set }
    func configureControl(with titles: [String], selector: Selector, isNeedAddToSuperView: Bool, size: CGSize?) -> SegmentedControl
}

extension SegmentProtocol {

    func pageboyViewController(_ pageboyViewController: PageboyViewController, didReloadWith currentViewController: UIViewController, currentPageIndex: PageboyViewController.PageIndex) {
    }

    func pageboyViewController(_ pageboyViewController: PageboyViewController, didScrollTo position: CGPoint, direction: PageboyViewController.NavigationDirection, animated: Bool) {
    }

    func pageboyViewController(_ pageboyViewController: PageboyViewController, willScrollToPageAt index: PageboyViewController.PageIndex, direction: PageboyViewController.NavigationDirection, animated: Bool) {
    }

    func pageboyViewController(_ pageboyViewController: PageboyViewController, didScrollToPageAt index: PageboyViewController.PageIndex, direction: PageboyViewController.NavigationDirection, animated: Bool) {
    }

    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return self.viewControllers.count
    }

    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        let viewController = self.viewControllers[index]
        return viewController
    }

    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }

    func configureControl(with titles: [String], selector: Selector, isNeedAddToSuperView: Bool = true, size: CGSize? = nil) -> SegmentedControl {
        let segment = SegmentedControl(items: titles)
        segment.selectedSegmentIndex = 0
        let defaultSize = CGSize(width: self.view.frame.width - (2 * SegmentConfig.controlLeftOffSet), height: SegmentConfig.controlHeight)
        if let size = size {
            let leftOFfset = self.view.center.x - (size.width / 2)
            segment.frame = CGRect(x: leftOFfset, y: SegmentConfig.controlTopOffSet, width: size.width, height: size.height)
        } else {
            segment.frame = CGRect(x: SegmentConfig.controlLeftOffSet, y: SegmentConfig.controlTopOffSet, width: defaultSize.width, height: defaultSize.height)
        }
        segment.addTarget(self, action: selector, for: .valueChanged)
        if (isNeedAddToSuperView) {
            self.view.addSubview(segment)
        }
        return segment
    }
}

class SegmentedControl: UISegmentedControl {

    override var intrinsicContentSize: CGSize {
        return UIView.layoutFittingExpandedSize
    }
}

extension SegmentedControl {

    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor);
        context!.fill(rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!
    }

    func removeBackgroundColors() {
        self.setBackgroundImage(imageWithColor(color: .clear), for: .normal, barMetrics: .default)
        self.setBackgroundImage(imageWithColor(color: .clear), for: .selected, barMetrics: .default)
        self.setDividerImage(imageWithColor(color: UIColor.clear), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
    }

    struct viewPosition {
        let originX: CGFloat
        let originIndex: Int
    }

    func updateTintColor(selected: UIColor, normal: UIColor) {
        let views = self.subviews
        var positions = [viewPosition]()
        for (i, view) in views.enumerated() {
            let position = viewPosition(originX: view.frame.origin.x, originIndex: i)
            positions.append(position)
        }
        positions.sort(by: { $0.originX < $1.originX })

        for (i, position) in positions.enumerated() {
            let view = self.subviews[position.originIndex]
            if i == self.selectedSegmentIndex {
                view.tintColor = selected
            } else {
                view.tintColor = normal
            }
        }
    }
}
