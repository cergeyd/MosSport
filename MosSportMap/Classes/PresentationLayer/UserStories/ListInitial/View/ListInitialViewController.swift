//
//  ListInitialListInitialViewController.swift
//  MosSportMap
//
//  Created by sergiusX on 17/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import Pageboy
import UIKit

class ListInitialViewController: PageboyViewController, SegmentProtocol {

    var output: ListInitialViewOutput!
    var type: ListType!
    var isExist = true

    lazy var listViewController: ListViewController = { return self.output.listViewController(type: self.type, isExist: true) }()
    lazy var listNonExistViewController: ListViewController = { return self.output.listViewController(type: self.type, isExist: false) }()
    lazy var viewControllers: [UIViewController] = {
        switch self.type! {
        case .details(detail: let detail, report: let report):
            switch detail.type {
            case .department:
                self.title = "Департаменты"
            case .sportTypes:
                self.title = "Типы спортивных объектов"
                return [self.listViewController, self.listNonExistViewController]
            default:
                return [self.listViewController]
            }
        case .sport(object: let object):
            self.title = "Спортивный объект"
        case .filterDepartments:
            self.title = "Департаменты"
        }
        return [self.listViewController]
    }()
    var segment: SegmentedControl!

    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.output.didLoadView()
        self.configureElements()
        self.isModalInPresentation = true
    }

    //MARK: Private func
    private func configurePageboy() {
        self.dataSource = self
        self.delegate = self
    }

    @objc func controlValueChanged(segment: UISegmentedControl) {
        //let isSign = segment.selectedSegmentIndex == 0
        // self.title = isSign ? "Вход" : "Регистрация"
        self.scrollToPage(.at(index: segment.selectedSegmentIndex), animated: true)
    }

    private func configureElements() {
        if (self.viewControllers.count > 1) {
            self.segment = self.configureControl(with: ["Присутствуют", "Отсутствуют"], selector: #selector(ListInitialViewController.controlValueChanged(segment:)), isNeedAddToSuperView: false, size: CGSize(width: 100.0, height: 37.0))
            self.navigationItem.titleView = self.segment
        }
        self.configurePageboy()
        //  self.isScrollEnabled = false
    }
}

extension ListInitialViewController: ListInitialViewInput {

    func setupInitialState() {

    }
}

extension ListInitialViewController: PageboyViewControllerDataSource, PageboyViewControllerDelegate {

}

extension UITableViewController {

    func pdfDataWithTableView(name: String, sourceView: UIView) {
        let priorBounds = tableView.bounds
        let fittedSize = tableView.sizeThatFits(CGSize(width: priorBounds.size.width, height: tableView.contentSize.height + 200.0))
        tableView.bounds = CGRect(x: 0, y: 0, width: fittedSize.width, height: fittedSize.height)
        let pdfPageBounds = CGRect(x: 0, y: 0, width: tableView.frame.width, height: self.view.frame.height)
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, pdfPageBounds, nil)
        var pageOriginY: CGFloat = 0
        while pageOriginY < fittedSize.height {
            UIGraphicsBeginPDFPageWithInfo(pdfPageBounds, nil)
            UIGraphicsGetCurrentContext()!.saveGState()
            UIGraphicsGetCurrentContext()!.translateBy(x: 0, y: -pageOriginY)
            tableView.layer.render(in: UIGraphicsGetCurrentContext()!)
            UIGraphicsGetCurrentContext()!.restoreGState()
            pageOriginY += pdfPageBounds.size.height
        }
        UIGraphicsEndPDFContext()
        tableView.bounds = priorBounds
        var docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
        docURL = docURL.appendingPathComponent(name + ".pdf")
        pdfData.write(to: docURL as URL, atomically: true)

        // Create the Array which includes the files you want to share
        var filesToShare = [Any]()

        // Add the path of the file to the Array
        filesToShare.append(docURL)

        // Make the activityViewContoller which shows the share-view
        let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = sourceView

        // Show the share-view
        self.present(activityViewController, animated: true, completion: nil)
    }
}
