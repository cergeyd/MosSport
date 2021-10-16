//
//  AppStyle.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import UIKit

public class AppStyle {

    struct Config {
        let cornerRadius: CGFloat = 4.0
        let menuWidthMultiplier: CGFloat = 0.86
    }

    static let config = Config()

    public enum Width {
        case bold
        case semibold
        case medium
        case regular
        case italic
    }

    public enum Size: CGFloat {
        case title = 16.0
        case subtitle = 13.0
    }

    public enum `Type` {
        case main
        case background
        case separator
        case title
        case subtitle
        case coloured
    }

    static let shared = AppStyle()

    public static func color(for type: Type) -> UIColor {
        switch type {
        case .main:
            return .white
        case .background:
            return #colorLiteral(red: 0.9379635453, green: 0.9408023953, blue: 0.9759425521, alpha: 1)
        case .separator:
            return #colorLiteral(red: 0.9523044229, green: 0.961090982, blue: 0.9831308722, alpha: 1)
        case .title:
            return #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1)
        case .subtitle:
            return #colorLiteral(red: 0.5741485357, green: 0.5741624236, blue: 0.574154973, alpha: 1)
        case .coloured:
            return #colorLiteral(red: 0.8470588235, green: 0.2941176471, blue: 0.2862745098, alpha: 1)
        }
    }

    public static func font(size: Size, width: Width = .regular) -> UIFont {
        switch width {
        case .bold:
            return UIFont.systemFont(ofSize: size.rawValue, weight: .bold)
        case .semibold:
            return UIFont.systemFont(ofSize: size.rawValue, weight: .semibold)
        case .medium:
            return UIFont.systemFont(ofSize: size.rawValue, weight: .medium)
        case .regular:
            return UIFont.systemFont(ofSize: size.rawValue, weight: .regular)
        case .italic:
            return UIFont.italicSystemFont(ofSize: size.rawValue)
        }
    }
}
