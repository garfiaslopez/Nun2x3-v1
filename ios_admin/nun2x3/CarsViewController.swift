//
//  CarsViewController.swift
//  nun2x3
//
//  Created by Jose De Jesus Garfias Lopez on 12/11/15.
//  Copyright © 2015 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit

class CarsViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var Cars_CollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "CarsCollectionViewCell", bundle: nil);
        self.Cars_CollectionView.registerNib(nib, forCellWithReuseIdentifier: "CustomCell");

        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(animated: Bool) {
        self.Cars_CollectionView.reloadData();
    }
    
    func CleanData(){
    
        if let parent = self.presentingViewController as? MainViewController{
            if (parent.TicketSelected != nil) {
                parent.Tickets[parent.TicketSelected!].car!.denomination = "Seleccionar";
                parent.Tickets[parent.TicketSelected!].car!.price = 0.0;
                
                parent.Tickets_CollectionView.reloadData();
            }
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let parent = self.presentingViewController as? MainViewController{
            return parent.Cars.count;
        }
        return 0;
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0);
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var cell:CarsCollectionViewCell;
        
        cell = self.Cars_CollectionView.dequeueReusableCellWithReuseIdentifier("CustomCell", forIndexPath: indexPath) as! CarsCollectionViewCell;
        
        if let parent = self.presentingViewController as? MainViewController{
            
            //Propertys
            cell.Label.text = parent.Cars[indexPath.row].denomination;
            cell.ImageView.image = UIImage(named: parent.Cars[indexPath.row].img);
            
            //if previusly was selected a car.
            if(parent.Tickets[parent.TicketSelected!].car!.denomination == parent.Cars[indexPath.row].denomination){
                cell.contentView.backgroundColor = UIColor.MKColor.Green;
            }else{
                cell.contentView.backgroundColor = UIColor.clearColor();
            }

        }else{
            cell.Label.text = "";
            cell.ImageView.image = UIImage(named: "CARRO.png");
        }

        return cell;
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if let parent = self.presentingViewController as? MainViewController{
            
            parent.secondsAfterOpen = 0;
            
            if (parent.TicketSelected != nil) {
                parent.Tickets[parent.TicketSelected!].car!.denomination = parent.Cars[indexPath.row].denomination;
                parent.Tickets[parent.TicketSelected!].car!.price = parent.Cars[indexPath.row].price;
                parent.Tickets_CollectionView.reloadData();
            }
        }
        
        let selectedCell:CarsCollectionViewCell = collectionView.cellForItemAtIndexPath(indexPath) as! CarsCollectionViewCell;
        selectedCell.contentView.backgroundColor = UIColor.MKColor.Green;
                
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ServicesViewController") as! ServicesViewController
        vc.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext;
        self.presentViewController(vc, animated: false, completion: nil);

    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        
        let selectedCell:CarsCollectionViewCell = collectionView.cellForItemAtIndexPath(indexPath) as! CarsCollectionViewCell;
        selectedCell.contentView.backgroundColor = UIColor.clearColor();
        
    }
    @IBAction func DeleteTicketAction(sender: AnyObject) {
        
        if let parent = self.presentingViewController as? MainViewController{
            parent.isOpenModal = false;
            parent.secondsAfterOpen = 0;
            
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("LoginAdminViewController") as! LoginAdminViewController
            vc.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext;
            vc.LavadoEnSesion = parent.LavadoEnSesion;
            vc.UsuarioEnSesion = parent.UsuarioEnSesion;
            vc.TicketSelected = parent.TicketSelected;
            
            SocketIOManager.sharedInstance.EmitTicketActive();
            self.presentViewController(vc, animated: false, completion: nil);

        }

    }

    @IBAction func Cancel(sender: AnyObject) {
        self.CleanData();
        self.dismissViewControllerAnimated(false, completion: nil);
    }
}
