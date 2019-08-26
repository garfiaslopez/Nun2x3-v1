//
//  ShowTicketViewController.swift
//  nun2x3
//
//  Created by Jose De Jesus Garfias Lopez on 28/11/15.
//  Copyright © 2015 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit

class ShowTicketViewController: UIViewController {
    
    var ActualTicket:TicketModel!;
    var PrinterIO:Printer!;

    @IBOutlet weak var TicketScrollView: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewDidAppear(animated: Bool) {
        let Image = self.PrinterIO.TicketToImage(ActualTicket, isClient: true);
        let imageView = UIImageView(image: Image);

        self.TicketScrollView.addSubview(imageView);
        self.TicketScrollView.contentSize = CGSizeMake(imageView.frame.size.width, imageView.frame.size.height);
        self.TicketScrollView.scrollEnabled = true;
    }

    @IBAction func CloseView(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil);
    }
    


}
