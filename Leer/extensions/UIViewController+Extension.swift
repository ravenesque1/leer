//
//  UIViewController+Extension.swift
//  Leer
//
//  Created by Raven Weitzel on 5/17/19.
//  Copyright © 2019 Raven Weitzel. All rights reserved.
//

import UIKit

extension UIViewController {

    @objc func showTip(_ message: String) {
        let alert = UIAlertController(title: "Tip! 💡", message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)

        present(alert, animated: true, completion: nil)
    }
}
