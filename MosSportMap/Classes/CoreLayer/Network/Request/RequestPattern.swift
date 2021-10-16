//
//  RequestPattern.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import Alamofire

public typealias HTTPHeaders = [String: String]

protocol RequestPattern {
    var isAuthNeeded: Bool { get }
    var method: HTTPMethod { get }
    var path: String { get }
    var parameters: Parameters? { get }
    var httpBody: Data? { get }
    var httpHeaders: HTTPHeaders? { get }
    var encoding: ParameterEncoding { get }
    var timeoutInterval: TimeInterval? { get }
    var hostUrl: String { get }
}

extension RequestPattern {
    var hostUrl: String { return Bundle.main.object(forInfoDictionaryKey: "HostURL") as! String }
    /*
     * Если к запроcу нужно приложить токен в header
     */
    var isAuthNeeded: Bool {
        return true
    }
    /*
     * Если к запроcу нужно приложить apiKey в header
     */
    var isApiKeyNeeded: Bool {
        return false
    }

    var method: HTTPMethod {
        return .get
    }

    var parameters: Parameters? {
        return nil
    }

    var encoding: ParameterEncoding {
        switch self.method {
        case .post:
            return JSONEncoding.default
        default:
            return URLEncoding.default
        }
    }
    /*
     * Для того чтобы отправить массив значений без ключа либо словарь
     * Нужно сериализовать это в Data
     * try JSONSerialization.data(withJSONObject: array, options: [])
     * Когда вы реализуете этот метод в своих реквестах parameters не будет учтен
     */
    var httpBody: Data? {
        return nil
    }

    var httpHeaders: HTTPHeaders? {
        return nil
    }

    var timeoutInterval: TimeInterval? {
        return nil
    }
    /**
    Тело запроса
    */
    func bodyWith(dict: [String: Any]?) -> Data? {
        if let dict = dict {
            return try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        }
        return nil
    }

    func bodyWith(dict: [[String: Any]]?) -> Data? {
        if let dict = dict {
            return try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        }
        return nil
    }

    func patch(parameters: inout [String: String], with values: [String: String]) {
        for key in values.keys {
            let value = values[key]
            parameters[key] = value
        }
    }
}
