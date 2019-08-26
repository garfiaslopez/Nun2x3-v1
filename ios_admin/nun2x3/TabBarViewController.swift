//
//  TabBarViewController.swift
//  nun2x3
//
//  Created by Jose De Jesus Garfias Lopez on 09/12/15.
//  Copyright © 2015 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import MaterialKit
class TabBarViewController: UITabBarController {

    @IBOutlet weak var MainTabBar: UITabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.MainTabBar.barTintColor = UIColor.whiteColor();
        self.MainTabBar.tintColor = UIColor.MKColor.Orange;

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
