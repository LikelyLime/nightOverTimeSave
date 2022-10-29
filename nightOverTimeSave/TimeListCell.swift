//
//  TimeListCell.swift
//  nightOverTimeSave
//
//  Created by 백시훈 on 2022/09/19.
//

import UIKit

class TimeListCell: UICollectionViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.contentView.layer.cornerRadius = 5.0
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.blue.cgColor
        
    }
}
