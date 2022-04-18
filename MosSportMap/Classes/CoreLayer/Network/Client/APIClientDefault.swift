//
//  APIClientDefault.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import RxSwift
import Alamofire

class APIClientDefault: APIClient {

    private let sessionManager: Session
    private let requestConvertibleFactory: RequestConvertibleFactory
    private let multipartRequestFactory: MultipartRequestFactory!
    private let notifications: NotificationCenter!

    init(sessionManager: Session, requestConvertibleFactory: RequestConvertibleFactory, multipartRequestFactory: MultipartRequestFactory! = nil, notifications: NotificationCenter) {
        self.requestConvertibleFactory = requestConvertibleFactory
        self.multipartRequestFactory = multipartRequestFactory
        self.notifications = notifications
        self.sessionManager = sessionManager
    }

    // MARK: Function
    func HTTPRequestObservable<T: Decodable>(requestPattern: RequestPattern) -> Observable<T> {
        return Observable.create { observer in
            let requestBuilder = self.requestConvertibleFactory.request(with: requestPattern)
            print(requestBuilder.urlRequest ?? "requestBuilder.urlRequest")

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            let request = self.sessionManager
                .request(requestBuilder)
                .responseDecodable(decoder: decoder) { (response: DataResponse<T, AFError>) in
                print("API RESPONSE ________________")
                print(response)
                print("________________")
                guard let httpUrlResponse = response.response else {
                    //observer.onError(APIClientError(error: R.string.common.responseError()))
                    return
                }
                switch(httpUrlResponse.statusCode) {
                case 200...204, 400...401, 404:
                    print(httpUrlResponse.statusCode)
                    /*
                     * Расскажем всем что мы разлогинились)
                     */
                    print(requestPattern.path)
                    if (httpUrlResponse.statusCode == 401 && !requestPattern.path.hasPrefix("auth")) {
                        self.notifications.post(name: Notification.Name.unauthorized, object: true, userInfo: nil)
                    }
                    if let value = response.value {
                        observer.onNext(value)
                        observer.onCompleted()
                    } else {
                        if let error = response.error {
                            print(error)
                            observer.onError(error)
                        }
                    }
                default:
                    if let error = response.error {
                        observer.onError(error)
                    } else if let jsonDictionary = response.value as? [String: Any] {
                        if let error = jsonDictionary["errorMessage"] as? [String] {
                            observer.onError(APIClientError(error: error.first ?? ""))
                        } else {
                            if let reason = jsonDictionary["reason"] as? String {
                                observer.onError(APIClientError(error: reason))
                            } else {
                                //  observer.onError(APIClientError(error: R.string.common.responseError()))
                            }
                        }
                    } else {
                        //observer.onError(APIClientError(error: R.string.common.responseError()))
                    }
                }
            }

            return Disposables.create {
                request.cancel()
            }
        }
    }
}
