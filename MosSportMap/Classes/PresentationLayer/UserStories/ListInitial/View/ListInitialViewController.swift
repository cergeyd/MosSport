//
//  ListInitialListInitialViewController.swift
//  MosSportMap
//
//  Created by sergiusX on 17/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import Pageboy

class ListInitialViewController: PageboyViewController, SegmentProtocol, PageboyViewControllerDataSource, PageboyViewControllerDelegate {

    var output: ListInitialViewOutput!
    var type: ListType!
    var listViewDelegate: ListViewDelegate?
    /// Сегменты
    var segment: SegmentedControl!
    private lazy var listViewController: ListViewController = { return self.output.listViewController(type: self.type, index: 0) }()
    private lazy var listViewController1: ListViewController = { return self.output.listViewController(type: self.type, index: 1) }()
    private lazy var listViewController2: ListViewController = { return self.output.listViewController(type: self.type, index: 2) }()
    private lazy var listViewController3: ListViewController = { return self.output.listViewController(type: self.type, index: 3) }()
    lazy var viewControllers: [UIViewController] = {
        switch self.type! {
        case .details(detail: let detail, report: let report):
            switch detail.type {
            case .department:
                self.title = "Департаменты"
            case .sportTypes:
                self.title = "Типы спортивных объектов"
                return [self.listViewController, self.listViewController1]
            default:
                return [self.listViewController]
            }
        case .sport(object: let object):
            self.title = "Спортивный объект"
        case .sportObjectsAround:
            self.rightNavigationBar(isLoading: false)
            return [self.listViewController, self.listViewController1, listViewController2, listViewController3]
        default: break
        }
        return [self.listViewController]
    }()
    lazy var searchController: UISearchController = {
        let _searchController = UISearchController(searchResultsController: nil)
        _searchController.searchBar.autocapitalizationType = .none
        _searchController.searchBar.placeholder = "Поиск по разделам"
        _searchController.isActive = true
        _searchController.obscuresBackgroundDuringPresentation = false
        _searchController.delegate = self as? UISearchControllerDelegate
        return _searchController
    }()

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.output.didLoadView()
        self.setupSearchController()
    }

    func setupSearchController() {
        switch self.type! {
        case .sport:
            break
        default:
            self.navigationItem.searchController = self.searchController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = false
        let children = (self.navigationController?.children.count ?? 1)
        self.isModalInPresentation = children > 1
    }

    // MARK: Private func
    private func setupDelegate() {
        for controller in self.viewControllers as! [ListViewController] {
            controller.delegate = self.listViewDelegate
        }
    }

    private func rightNavigationBar(isLoading: Bool = false) {
        if (isLoading) {
            self.navigationActivity()
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(didTapExport))
        }
    }
    /// Создаэм PDF
    @objc private func didTapExport() {
        self.rightNavigationBar(isLoading: true)
        Dispatch.after(1.0, completion: { self.rightNavigationBar(isLoading: false) })
        if let topController = UIViewController.topController() {
            if let children = topController.children.last {
                if let listInitialViewController = children as? ListInitialViewController {
                    let listViewController = listInitialViewController.viewControllers[listInitialViewController.segment.selectedSegmentIndex] as! ListViewController
                    switch self.type! {
                    case .sportObjectsAround:
                        let availability = SharedManager.shared.title(for: listViewController.index)
                        let name = "Объекты рядом. Доступность: \(availability)"
                        self.pdfData(with: listViewController.tableView, name: name, sourceView: self.navigationItem.rightBarButtonItem!)
                        self.murmur(text: "Сохранено", isError: false, subtitle: name)
                    default: break
                    }
                }
            }
        }
    }

    private func configurePageboy() {
        self.dataSource = self
        self.delegate = self
    }

    @objc func controlValueChanged(segment: UISegmentedControl) {
        self.scrollToPage(.at(index: segment.selectedSegmentIndex), animated: true)
        self.searchController.searchResultsUpdater = self.viewControllers[segment.selectedSegmentIndex] as? UISearchResultsUpdating
    }

    private func configureElements() {
        if (self.viewControllers.count > 1) {
            switch self.type! {
            case .sportObjectsAround:
                self.segment = self.configureControl(with: ["Шаговая", "Районная", "Окружная", "Городская"], selector: #selector(ListInitialViewController.controlValueChanged(segment:)), isNeedAddToSuperView: false, size: CGSize(width: 100.0, height: 37.0))
            default:
                self.segment = self.configureControl(with: ["Присутствуют", "Отсутствуют"], selector: #selector(ListInitialViewController.controlValueChanged(segment:)), isNeedAddToSuperView: false, size: CGSize(width: 100.0, height: 37.0))
            }
            self.navigationItem.titleView = self.segment
        }
        self.configurePageboy()
        self.isScrollEnabled = false
    }
}

extension ListInitialViewController: ListInitialViewInput {

    func setupInitialState() {
        self.configureElements()
        self.setupDelegate()
    }
}
