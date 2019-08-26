//
//  FirstSetupTableViewCell.swift
//  nun2x3
//
//  Created by Jose De Jesus Garfias Lopez on 24/10/15.
//  Copyright © 2015 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit

class FirstSetupTableViewCell: UITableViewCell {
    
    var select:Bool = false;
    
    @IBOutlet weak var name: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
