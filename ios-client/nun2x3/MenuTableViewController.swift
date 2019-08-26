//
//  MenuTableViewController.swift
//  nun2x3
//
//  Created by Jose De Jesus Garfias Lopez on 31/01/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit


class MenuTableViewController: UITableViewController {

    var UsuarioEnSesion:Session = Session();
    
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var EmailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        NameLabel.text = UsuarioEnSesion.name;
        EmailLabel.text = UsuarioEnSesion.rol;
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let cell = tableView.cellForRow(at: indexPath);        
        if cell?.tag == 1 {
            
            if let swreveal = self.parent as? SWRevealViewController {
                if let navigation = swreveal.frontViewController as? MainNavViewController {
                    if let Dashboard = navigation.viewControllers.first as? StateViewController{
                        Dashboard.performSegue(withIdentifier: "LoginSegue", sender: self);
                    }
                }
            }
            
        }
    }
}
