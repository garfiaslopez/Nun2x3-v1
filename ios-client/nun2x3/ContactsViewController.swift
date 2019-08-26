//
//  ContactsViewController.swift
//  nun2x3
//
//  Created by Jose De Jesus Garfias Lopez on 01/02/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit

class ContactsViewController: UIViewController {
    
    
    let ApiUrl = VARS().getApiUrl();
    let Format = Formatter();
    
    var UsuarioEnSesion:Session = Session();
    
    @IBOutlet weak var MenuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if revealViewController() != nil {
            MenuButton.target = revealViewController()
            MenuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
    }


}
