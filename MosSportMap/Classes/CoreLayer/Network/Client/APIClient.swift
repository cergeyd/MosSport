//
//  APIClient.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import RxSwift

protocol APIClient {
    func HTTPRequestObservable<T: Decodable>(requestPattern: RequestPattern) -> Observable<T>
    func MultipartRequestObservable(requestPattern: RequestPattern, filename: String?, mimeType: String?) -> Observable<Any>?
}

extension APIClient {
    func MultipartRequestObservable(requestPattern: RequestPattern, filename: String?, mimeType: String?) -> Observable<Any>? {
        return nil
    }
}
