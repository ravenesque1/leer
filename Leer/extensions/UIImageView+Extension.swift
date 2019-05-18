//
//  UIImageView+Extension.swift
//  Leer
//
//  Created by Raven Weitzel on 5/17/19.
//  Copyright © 2019 Raven Weitzel. All rights reserved.
//

import UIKit

extension UIImageView {

    ///fill or empty star depending on save status
    func setSaved(_ saved: Bool) {
        var image = saved ? UIImage(named: "full") : UIImage(named: "empty")
        image = image?.withRenderingMode(.alwaysTemplate)
        self.image = image
    }
}
