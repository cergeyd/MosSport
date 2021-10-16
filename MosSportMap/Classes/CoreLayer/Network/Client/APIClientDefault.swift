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

    //MARK: Function
    func HTTPRequestObservable(requestPattern: RequestPattern) -> Observable<Any> {
        return Observable.create { observer in
            let requestBuilder = self.requestConvertibleFactory.request(with: requestPattern)
            print(requestBuilder.urlRequest ?? "requestBuilder.urlRequest")

            let request = self.sessionManager
                .request(requestBuilder)
                .responseJSON { response in
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
                    if let jsonDictionary = response.value as? [String: Any] {
                        observer.onNext(jsonDictionary)
                        observer.onCompleted()
                    } else if let jsonArray = response.value as? [[String: Any]] {
                        observer.onNext(jsonArray)
                        observer.onCompleted()
                    } else {
                        observer.onCompleted()
                    }
                    break
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

    func upload(requestPattern: RequestPattern, image: Data) -> Observable<Any>? {
        return Observable.create { observer in
            let url = self.multipartRequestFactory.url(with: requestPattern)
            //let headers = self.multipartRequestFactory.headers(with: requestPattern)
            let successRequest = self.sessionManager.upload(multipartFormData: { multipartFormData in
                if let parameters = requestPattern.parameters {
                    for (key, value) in parameters {
                        if let temp = value as? String {
                            multipartFormData.append(temp.data(using: .utf8)!, withName: key)
                        }
                        if let temp = value as? Int {
                            multipartFormData.append("\(temp)".data(using: .utf8)!, withName: key)
                        }
                        if let temp = value as? NSArray {
                            temp.forEach({ element in
                                let keyObj = key + "[]"
                                if let string = element as? String {
                                    multipartFormData.append(string.data(using: .utf8)!, withName: keyObj)
                                } else
                                if let num = element as? Int {
                                    let value = "\(num)"
                                    multipartFormData.append(value.data(using: .utf8)!, withName: keyObj)
                                }
                            })
                        }
                    }
                }
                multipartFormData.append(image, withName: "file", fileName: "file.png", mimeType: "image/png")
            }, with: url as! URLRequestConvertible)
                .uploadProgress(queue: .main, closure: { progress in
                //Current upload progress of file
                print("Upload Progress: \(progress.fractionCompleted)")
            })
                .responseJSON(completionHandler: { response in
                if let error = response.error {
                    observer.onError(error)
                } else {
                    print("API RESPONSE ________________")
                    print(response)
                    print("________________")
                    if let jsonDictionary = response.value as? [String: Any] {
                        observer.onNext(jsonDictionary)
                        observer.onCompleted()
                    } else {
                        observer.onError(APIClientError(error: "R.string.common.responseError()"))
                    }
                }
            })
            return Disposables.create {
                successRequest.cancel()
            }
        }
    }
}
