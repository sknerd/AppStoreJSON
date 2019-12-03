//
//  ReviewCell.swift
//  AppStore JSON
//
//  Created by renks on 29.11.2019.
//  Copyright © 2019 Renald Renks. All rights reserved.
//

import UIKit

class ReviewCell: UICollectionViewCell {
    
    let titleLabel = UILabel(text: "Review Title", font: .boldSystemFont(ofSize: 18))
    let autholLabel = UILabel(text: "Author", font: .systemFont(ofSize: 16))
    let starsLabel = UILabel(text: "Stars", font: .systemFont(ofSize: 14))
    
    let starsStackView: UIStackView = {
        var arrangedSubviews = [UIView]()
        (0..<5).forEach { (_) in
            let imageView = UIImageView(image: UIImage(systemName: "star.fill"))
            imageView.tintColor = #colorLiteral(red: 0.9557852149, green: 0.5130294561, blue: 0, alpha: 1)
            imageView.constrainWidth(constant: 20)
            imageView.constrainHeight(constant: 20)
            arrangedSubviews.append(imageView)
        }
        arrangedSubviews.append(UIView())
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        return stackView
    }()
    
    let bodyLable = UILabel(text: "Review Body\nReview Body\nReview Body\nReview Body", font: .systemFont(ofSize: 16), numberOfLines: 8)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = #colorLiteral(red: 0.9469226003, green: 0.9451182485, blue: 0.974506557, alpha: 1)
        layer.cornerRadius = 16
        clipsToBounds = true
        autholLabel.textColor = .darkGray
        
        let stackView = VerticalStackView(arrangedSubviews: [
            UIStackView(arrangedSubviews: [
            titleLabel,autholLabel
            ], customSpacing: 8),
            starsStackView,
            bodyLable
        ], spacing: 12)
        
        titleLabel.setContentCompressionResistancePriority(.init(0), for: .horizontal)
        autholLabel.textAlignment = .right
  
        addSubview(stackView)
        stackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 20, left: 20, bottom: 0, right: 20))
//        stackView.fillSuperview(padding: .init(top: 20, left: 20, bottom: 20, right: 20))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
