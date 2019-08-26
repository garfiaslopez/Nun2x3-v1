//
//  MainNavViewController.swift
//  nun2x3
//
//  Created by Jose De Jesus Garfias Lopez on 21/01/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit

class MainNavViewController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Roboto-Regular", size: 17)!, NSForegroundColorAttributeName:UIColor.white];
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden : Bool {
        return false
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent;
    }


}
