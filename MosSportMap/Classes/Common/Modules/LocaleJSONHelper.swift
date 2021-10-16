//
//  LocaleJSONHelper.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import RxSwift
import Foundation

class LocaleJSONHelper {

    func loadJson(with fileName: String) -> Observable<Any> {
        return Observable.create { observer in
            if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                    let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                    observer.onNext(jsonResult)
                    observer.onCompleted()
                } catch let error {
                    observer.onError(error)
                }
            } else {
                observer.onError((NSError.init(domain: "error.load fileName: \(fileName)", code: 0, userInfo: nil)))
            }
            return Disposables.create { }
        }
    }
}
