//
//  PendingTableViewCell.swift
//  EnUn2x3 Admin
//
//  Created by Jose De Jesus Garfias Lopez on 28/08/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import MaterialKit
import SWTableViewCell

class PendingTableViewCell: SWTableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var denominationLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
