//
//  DayType.swift
//  GoldenHour
//
//  Created by Carter Borchetta on 12/3/19.
//  Copyright © 2019 Carter Borchetta. All rights reserved.
//

import UIKit

enum DayType: Int {
    case normal, morningGoldenHour, sunrise, eveningGoldenHour, sunset
    
    static var allTypes: [DayType] = [.normal, .morningGoldenHour, .sunrise, .eveningGoldenHour, .sunset]
    
    var description: String {
        switch self {
        case .normal:
            return ""
        case .morningGoldenHour:
            return "Morning Golden Hour"
        case .sunrise:
            return "Sunrise"
        case .eveningGoldenHour:
            return "Evening Golden Hour"
        case .sunset:
            return "Sunset"
            
        }
    }
    
    var color: UIColor {
        switch self {
        case .normal:
            return UIColor.lightGray
        case .morningGoldenHour:
            return UIColor.StorageExample.progressYellow
        case .sunrise:
            return UIColor.StorageExample.progressOrange
        case .eveningGoldenHour:
            return UIColor.StorageExample.progressYellow
        case .sunset:
            return UIColor.StorageExample.progressOrange
        }
    }
}
