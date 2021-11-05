//
//  FilesBrowser.swift
//  MosSportMap
//
//  Created by Sergey D on 05.11.2021.
//

import Foundation
import UIKit

class FilesBrowser: NSObject {

    let documentInteractionController = UIDocumentInteractionController()
    let browserController = UIDocumentPickerViewController(documentTypes: ["public.text"], in: .import)
    var currentController: UIViewController!

    init(controller: UIViewController) {
        super.init()
        self.currentController = controller
        self.setupFileBrowser()
    }

    private func setupFileBrowser() {
        self.browserController.delegate = self
        self.browserController.allowsMultipleSelection = false
    }

    func show() {
        self.currentController.present(self.browserController, animated: true, completion: nil)
    }

    func downloadBy(url: URL) {

    }

    func title(from destination: String) -> (String, String) {
        let arr = destination.split(separator: "/")
        var title = destination
        var ext = ""
        if let last = arr.last {
            title = String(last)
        }
        let arr1 = title.split(separator: ".")
        if (arr1.count > 1) {
            ext = String(arr1[arr1.count - 1])
            for (ind, a) in arr1.enumerated() {
                if (ind != arr1.count - 1) && (ind < 5) {
                    title += a
                }
            }
        }
        var newTitle = title.replacingOccurrences(of: ext, with: "", options: NSString.CompareOptions.literal, range: nil)
        let newArray = newTitle.split(separator: ".")
        if (newArray.count > 1) {
            let one = newArray[0]
            let two = newArray[1]
            if (one == two) {
                newTitle = String(one)
            }
        }
        return (newTitle, ext)
    }

    func downloadLocal(file destination: URL) {

    }
}

extension FilesBrowser: UIDocumentPickerDelegate {

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        // do something with the selected document
        print(url)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let url = urls.first {
            self.downloadLocal(file: url)
        }
    }
}
