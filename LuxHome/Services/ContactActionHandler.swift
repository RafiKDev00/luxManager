//
//  ContactActionHandler.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/25/25.
//

import Foundation
import UIKit

enum ContactActionType: String {
    case call = "Call"
    case email = "Email"
}

struct ContactActionHandler {
    static func makeCall(to rawNumber: String) -> Bool {
        let cleaned = rawNumber
            .components(separatedBy: CharacterSet.decimalDigits.inverted.union(CharacterSet(charactersIn: "+")))
            .joined()
        guard !cleaned.isEmpty,
              let url = URL(string: "tel://\(cleaned)"),
              UIApplication.shared.canOpenURL(url) else {
            return false
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        return true
    }

    static func sendEmail(to address: String) -> Bool {
        guard let encoded = address.addingPercentEncoding(withAllowedCharacters: .urlUserAllowed),
              let url = URL(string: "mailto:\(encoded)"),
              UIApplication.shared.canOpenURL(url) else {
            return false
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        return true
    }
}
