//
//  ServicesViewController.swift
//  nun2x3
//
//  Created by Jose De Jesus Garfias Lopez on 13/11/15.
//  Copyright © 2015 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import RealmSwift

class ServicesViewController: UIViewController, UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var Services_CollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "ServicesCollectionViewCell", bundle: nil);
        self.Services_CollectionView.registerNib(nib, forCellWithReuseIdentifier: "CustomCell");
        
        self.Services_CollectionView.allowsMultipleSelection = true;
        
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(animated: Bool) {
        self.Services_CollectionView.reloadData();
    }
    
    func CleanData(){
        
        if let parent = self.presentingViewController?.presentingViewController as? MainViewController{
            parent.Tickets[parent.TicketSelected!].services = List<SimpleServModel>();
        }
        
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let parent = self.presentingViewController?.presentingViewController as? MainViewController{
            return parent.Services.count;
        }
        return 0;
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0);
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var cell:ServicesCollectionViewCell;
        
        cell = self.Services_CollectionView.dequeueReusableCellWithReuseIdentifier("CustomCell", forIndexPath: indexPath) as! ServicesCollectionViewCell;
        
        if let parent = self.presentingViewController?.presentingViewController as? MainViewController{
            cell.Label.text = parent.Services[indexPath.row].denomination;
            cell.ImageView.image = UIImage(named: parent.Services[indexPath.row].img);  // parent?.Cars[indexPath.row].img
        }else{
            cell.Label.text = "";
            cell.ImageView.image = UIImage(named: "SERVICE1.png");
        }
        
        return cell;
        
    }

    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        if let parent = self.presentingViewController?.presentingViewController as? MainViewController{
            
            let newServ:SimpleServModel = SimpleServModel();
            newServ.denomination = parent.Services[indexPath.row].denomination;
            newServ.price = parent.Services[indexPath.row].price;
            
            parent.Tickets[parent.TicketSelected!].services.append(newServ);
            
        }
        
        let selectedCell:ServicesCollectionViewCell = collectionView.cellForItemAtIndexPath(indexPath) as! ServicesCollectionViewCell;
        selectedCell.contentView.backgroundColor = UIColor.MKColor.Green;
        
    }
    
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        
        
        if let parent = self.presentingViewController?.presentingViewController as? MainViewController{
            
            var i:Int?;
            for (index, value) in parent.Tickets[parent.TicketSelected!].services.enumerate() {
                if(value.denomination == parent.Services[indexPath.row].denomination){
                    i=index;
                }
            }
            if (i != nil) {
                parent.Tickets[parent.TicketSelected!].services.removeAtIndex(i!);
            }else{
                print("No se pudo eliminar el servicio");
            }
        }
        
        let selectedCell:ServicesCollectionViewCell = collectionView.cellForItemAtIndexPath(indexPath) as! ServicesCollectionViewCell;
        selectedCell.contentView.backgroundColor = UIColor.clearColor();
        
    }

    
    @IBAction func GoBack(sender: AnyObject) {
        self.CleanData();
        self.dismissViewControllerAnimated(false, completion: nil);
    }
    
    @IBAction func Cancel(sender: AnyObject) {
        self.CleanData();
        
        if let parent = self.presentingViewController?.presentingViewController as? MainViewController{
            parent.dismissViewControllerAnimated(false, completion: nil);
        }
        
    }
    
    @IBAction func Checkout(sender: AnyObject) {
        
        if let parent = self.presentingViewController?.presentingViewController as? MainViewController{
            
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("CobrarViewController") as! CobrarViewController
            vc.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext;
            vc.LavadoEnSesion = parent.LavadoEnSesion;
            vc.UsuarioEnSesion = parent.UsuarioEnSesion;
            vc.PrinterIO = parent.PrinterIO;
            
            self.presentViewController(vc, animated: false, completion: nil);

            
        }

        
        
    }
    
}
