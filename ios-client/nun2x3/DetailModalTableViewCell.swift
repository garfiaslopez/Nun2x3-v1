//
//  DetailModalTableViewCell.swift
//  EnUn2x3
//
//  Created by Jose De Jesus Garfias Lopez on 25/08/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit

class DetailModalTableViewCell: UITableViewCell {

    
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var denominationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
