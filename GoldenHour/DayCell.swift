//
//  DayCell.swift
//  GoldenHour
//
//  Created by Carter Borchetta on 12/2/19.
//  Copyright © 2019 Carter Borchetta. All rights reserved.
//

import UIKit

class DayCell: UITableViewCell {
    
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var overcastLabel: UILabel!
    @IBOutlet weak var overcastImageView: UIImageView!
    @IBOutlet weak var eveningGoldenHourBeginsLabel: UILabel!
    @IBOutlet weak var eveningGoldenHourEndsLabel: UILabel!
    
    @IBOutlet weak var morningGoldenHourBeginsLabel: UILabel!
    @IBOutlet weak var morningGoldenHourEndsLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func updateCell(with solarDetail: SolarDetail, dateFormatter: DateFormatter) {
        eveningGoldenHourBeginsLabel.text = dateFormatter.string(from: solarDetail.eveningGoldenHourStart)
        eveningGoldenHourEndsLabel.text = dateFormatter.string(from: solarDetail.eveningGoldenHourEnd)
        
        morningGoldenHourBeginsLabel.text = dateFormatter.string(from: solarDetail.morningGoldenHourStart)
        morningGoldenHourEndsLabel.text = dateFormatter.string(from: solarDetail.morningGoldenHourEnd)
    }
}




