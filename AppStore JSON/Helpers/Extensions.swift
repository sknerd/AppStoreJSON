//
//  Extensions.swift
//  AppStore JSON
//
//  Created by renks on 28.11.2019.
//  Copyright © 2019 Renald Renks. All rights reserved.
//

import UIKit

extension UILabel {
    convenience init(text: String, font: UIFont) {
        self.init(frame: .zero)
        self.text = text
        self.font = font
    }
}

extension UIImageView {
    convenience init (cornerRadius: CGFloat) {
        self.init(image: nil)
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
        self.contentMode = .scaleAspectFill
    }
}

extension UIButton {
    convenience init (title: String) {
        self.init(type: .system)
        self.setTitle(title, for: .normal)
    }
}
