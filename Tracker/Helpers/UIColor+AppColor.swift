//
//  UIColor+AppColor.swift
//  Tracker
//
//  Created by Cascade on 10.08.2025.
//

import UIKit

public extension UIColor {
    convenience init(appColor: AppColor) {
        self.init(
            red: CGFloat(appColor.red),
            green: CGFloat(appColor.green),
            blue: CGFloat(appColor.blue),
            alpha: CGFloat(appColor.alpha)
        )
    }

    var appColor: AppColor {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return AppColor(red: Double(red), green: Double(green), blue: Double(blue), alpha: Double(alpha))
        }
        // Fallback using white/alpha if needed
        var white: CGFloat = 0
        if getWhite(&white, alpha: &alpha) {
            return AppColor(red: Double(white), green: Double(white), blue: Double(white), alpha: Double(alpha))
        }
        return .black
    }
}
