//
//  Helpers+Extensions.swift
//  Continuum
//
//  Created by Curt McCune on 6/14/22.
//  Copyright © 2022 trevorAdcock. All rights reserved.
//

import Foundation
import UIKit

class DateForm {
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
}

extension UIViewController {
    func presentsSimpleAlertWith(title: String, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}
