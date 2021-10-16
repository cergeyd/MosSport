//
//  Global.swift
//  Manage
//
//  Created by Sergey Desyatskiy on 20.06.2020.
//  Copyright © 2020 Sergey. All rights reserved.
//

import UIKit

var googleAPIkey: String {
    return Bundle.main.object(forInfoDictionaryKey: "GoogleAPIkey") as! String
}

var hostUrl: String {
    return Bundle.main.object(forInfoDictionaryKey: "HostURL") as! String
}

func open(url: String) {
    if let userURL = URL.init(string: url) {
        if (UIApplication.shared.canOpenURL(userURL)) {
            UIApplication.shared.open(userURL, options: [:], completionHandler: nil)
        }
    }
}
