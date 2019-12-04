//
//  DayProgressSection.swift
//  GoldenHour
//
//  Created by Carter Borchetta on 12/3/19.
//  Copyright © 2019 Carter Borchetta. All rights reserved.
//

import UIKit
import MultiProgressView

class DayProgressSection: ProgressViewSection {
    
    private let rightBorder: UIView = {
        let border = UIView()
        border.backgroundColor = .clear
        return border
    }()
    
    func configure(withDayType dayType: DayType) {
        addSubview(rightBorder)
        rightBorder.anchor(top: topAnchor, bottom: bottomAnchor, right: rightAnchor, width: 1)
        backgroundColor = dayType.color
    }
}


