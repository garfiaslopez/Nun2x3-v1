//
//  MainCollectionViewCell.swift
//  NUn2x3
//
//  Created by Jose De Jesus Garfias Lopez on 12/07/15.
//  Copyright (c) 2015 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit

class MainCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var Timer_Label: UILabel!
    @IBOutlet weak var CarType_Label: UILabel!
    @IBOutlet weak var CarPrice_Label: UILabel!
    
    override func awakeFromNib() {
        self.layer.shadowColor = UIColor.grayColor().CGColor;
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowRadius = 2.0;
        self.layer.shadowOffset = CGSizeMake(1.0, 1.0);
        self.layer.masksToBounds = false;
    }
}
