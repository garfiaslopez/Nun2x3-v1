//
//  DataBaseTableViewCell.swift
//  nun2x3
//
//  Created by Jose De Jesus Garfias Lopez on 19/11/15.
//  Copyright © 2015 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import MaterialKit
import SWTableViewCell

class DataBaseTableViewCell: SWTableViewCell{

    @IBOutlet weak var Denomination: UILabel!
    @IBOutlet weak var Price: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
