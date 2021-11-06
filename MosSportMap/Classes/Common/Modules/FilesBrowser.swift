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
            // Start accessing a security-scoped resource.
            guard url.startAccessingSecurityScopedResource() else {
                // Handle the failure here.
                return
            }
            // Make sure you release the security-scoped resource when you finish.
            defer { url.stopAccessingSecurityScopedResource() }
            // Use file coordination for reading and writing any of the URL’s content.
            var error: NSError? = nil
            NSFileCoordinator().coordinate(readingItemAt: url, error: &error) { (url) in
                let keys: [URLResourceKey] = [.nameKey, .isDirectoryKey]
                // Get an enumerator for the directory's content.
                guard let fileList =
                    FileManager.default.enumerator(at: url, includingPropertiesForKeys: keys) else {
                    Swift.debugPrint("*** Unable to access the contents of \(url.path) ***\n")
                    return
                }

                for case let file as URL in fileList {
                    // Start accessing the content's security-scoped URL.
                    guard url.startAccessingSecurityScopedResource() else {
                        // Handle the failure here.
                        continue
                    }

                    // Do something with the file here.
                    Swift.debugPrint("chosen file: \(file.lastPathComponent)")

                    // Make sure you release the security-scoped resource when you finish.
                    url.stopAccessingSecurityScopedResource()
                }
            }
            if let url = urls.first {
                self.delegate?.didDownload(file: url)
            }
        }
    }
}
