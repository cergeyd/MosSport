//
//  RatingInitialRatingInitialViewController.swift
//  MosSportMap
//
//  Created by Sergey D on 02/11/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import Pageboy

enum RateType {
    case squareForOne
    case sportForOne
    case objectForOne
}

class RatingInitialViewController: PageboyViewController, SegmentProtocol, PageboyViewControllerDataSource, PageboyViewControllerDelegate {

    var output: RatingInitialViewOutput!
    /// Сегменты
    var segment: SegmentedControl!
    private lazy var ratingSquareForOne = { return self.output.ratingViewController(type: .squareForOne) }()
    private lazy var ratingSportForOne = { return self.output.ratingViewController(type: .sportForOne) }()
    private lazy var ratingObjectForOne = { return self.output.ratingViewController(type: .objectForOne) }()
    lazy var viewControllers: [UIViewController] = { return [self.ratingSquareForOne, self.ratingSportForOne, self.ratingObjectForOne] }()
    private var isAscending = true

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.output.didLoadView()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.up.arrow.down.circle"), style: .plain, target: self, action: #selector(didTapShowAscending))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let children = (self.navigationController?.children.count ?? 1)
        self.isModalInPresentation = children > 1
    }

    // MARK: Private func
    @objc private func didTapShowAscending() {
        let alert = UIAlertController(title: "Направление сортировки", message: "Доступность", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Восходящий", style: .default, handler: { _ in self.updateSort() }))
        alert.addAction(UIAlertAction(title: "Нисходящий", style: .default, handler: { _ in self.updateSort() }))
        alert.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        self.present(alert, animated: true)
    }

    private func updateSort() {
        self.isAscending = !self.isAscending
        for controller in viewControllers as! [RatingViewController] {
            controller.configureDetails(isAscending: self.isAscending)
        }
    }

    private func configurePageboy() {
        self.dataSource = self
        self.delegate = self
    }

    @objc func controlValueChanged(segment: UISegmentedControl) {
        self.scrollToPage(.at(index: segment.selectedSegmentIndex), animated: true)
    }

    private func configureElements() {
        self.segment = self.configureControl(with: ["Площадь", "Виды спорта", "Спортивные объекты"], selector: #selector(ListInitialViewController.controlValueChanged(segment:)), isNeedAddToSuperView: false, size: CGSize(width: 100.0, height: 37.0))
        self.navigationItem.titleView = self.segment
        self.configurePageboy()
        self.isScrollEnabled = false
    }
}

extension RatingInitialViewController: RatingInitialViewInput {

    func setupInitialState() {
        self.title = "На среднюю плотность населения"
        self.configureElements()
    }
}
