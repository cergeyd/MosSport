//
//  FilesBrowser.swift
//  MosSportMap
//
//  Created by Sergey D on 05.11.2021.
//

import Foundation
import UIKit

protocol FilesBrowserDelegate: AnyObject {
    func didDownload(file url: URL)
}

class FilesBrowser: NSObject {

    private let documentInteractionController = UIDocumentInteractionController()
    private let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.data])
    private let currentController: UIViewController
    weak var delegate: FilesBrowserDelegate?

    init(controller: UIViewController) {
        self.currentController = controller
        super.init()
        self.setupFileBrowser()
        self.documentPicker.delegate = self
    }

    private func setupFileBrowser() {
        //self.browserController.delegate = self
        //self.browserController.allowsMultipleSelection = false
    }

    func show() {

        // Present the document picker.
        self.currentController.present(self.documentPicker, animated: true, completion: nil)

        //self.currentController.present(self.browserController, animated: true, completion: nil)
    }

    func downloadBy(url: URL) {

    }

    func downloadLocal(file destination: URL) {
        self.delegate?.didDownload(file: destination)
    }
}

extension FilesBrowser: UIDocumentPickerDelegate {

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let url = urls.first {
            self.delegate?.didDownload(file: url)
        }
    }
}
