//
//  TodayItem.swift
//  AppStore JSON
//
//  Created by renks on 02.12.2019.
//  Copyright © 2019 Renald Renks. All rights reserved.
//

import UIKit

struct TodayItem {
    
    let category: String
    let title: String
    let image: UIImage
    let description: String
    let backgroundColor: UIColor
    
    // enum
    let cellType: CellType
    
    let apps: [FeedResult]
    
    enum CellType: String {
        case single, multiple
    }
    
}
