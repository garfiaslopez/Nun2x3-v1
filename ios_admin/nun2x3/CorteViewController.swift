//
//  CorteViewController.swift
//  nun2x3
//
//  Created by Jose De Jesus Garfias Lopez on 21/11/15.
//  Copyright © 2015 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import MaterialKit
import SwiftyJSON
import Alamofire
import RealmSwift


class CorteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let ApiUrl = VARS().getApiUrl();
    let Format = Formatter();
    
    var PrinterIO:Printer!;
    var UsuarioEnSesion:Session!;
    var LavadoEnSesion:LavadoSession!;
    
    var SelectedTicket:Int? = nil;
    var TicketsHistory:Array<TicketModel> = [];
    var ResumeArray:Array<(String,String)> = [];
    var SpendsHistory:Array<BaseModel> = [];
    var IngressesHistory:Array<BaseModel> = [];
    var PaybillsHistory:Array<BaseModel> = [];
    
    var isCorteCompleto = false;
    var ImageCorte:UIImage!;
    
    @IBOutlet weak var NavigationBar: UINavigationBar!
    @IBOutlet weak var ResumeView: UIView!
    @IBOutlet weak var ResumeTableView: UITableView!
    @IBOutlet weak var ResumeTotalLabel: UILabel!
    @IBOutlet weak var DetailScrollView: UIScrollView!
    @IBOutlet weak var LoadingView: UIImageView!
    @IBOutlet weak var MakeCorteButton: MKButton!
    @IBOutlet weak var PrintButton: MKButton!
    @IBOutlet weak var CorteIButton: MKButton!
    @IBOutlet weak var CorteCButton: MKButton!
    @IBOutlet weak var BackgroundView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let nib = UINib(nibName: "DataBaseTableViewCell", bundle: nil);
        self.ResumeTableView.registerNib(nib, forCellReuseIdentifier: "cell");
        
        self.NavigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Roboto-Regular", size: 25)!, NSForegroundColorAttributeName: UIColor.whiteColor()];
                
        ResumeView.layer.shadowColor = UIColor.grayColor().CGColor;
        ResumeView.layer.shadowOpacity = 0.5;
        ResumeView.layer.shadowRadius = 2.0;
        ResumeView.layer.shadowOffset = CGSizeMake(1.0, 1.0);
        ResumeView.layer.masksToBounds = false;
        
        DetailScrollView.layer.shadowOpacity = 0.55;
        DetailScrollView.layer.shadowRadius = 5.0;
        DetailScrollView.layer.shadowColor = UIColor.grayColor().CGColor;
        DetailScrollView.layer.shadowOffset = CGSize(width: 0, height: 2.5);
        
        PrintButton.layer.shadowOpacity = 0.55;
        PrintButton.layer.shadowRadius = 5.0;
        PrintButton.layer.shadowColor = UIColor.grayColor().CGColor;
        PrintButton.layer.shadowOffset = CGSize(width: 0, height: 2.5);
        
        MakeCorteButton.layer.shadowOpacity = 0.55;
        MakeCorteButton.layer.shadowRadius = 5.0;
        MakeCorteButton.layer.shadowColor = UIColor.grayColor().CGColor;
        MakeCorteButton.layer.shadowOffset = CGSize(width: 0, height: 2.5);
        
        var ImagesForAnimation: [UIImage] = [];
        for i in 1...21 {
            ImagesForAnimation.append(UIImage(named:"Loading_\(i).png")!);
        }
        LoadingView.animationImages = ImagesForAnimation;
        LoadingView.animationDuration = 1.0;
        self.BackgroundView.backgroundColor = UIColor.MKColor.LightGreen.colorWithAlphaComponent(0.20);
    }
    
    override func viewDidAppear(animated: Bool) {
        if let parent = self.presentingViewController as? MainViewController{
            self.UsuarioEnSesion = parent.UsuarioEnSesion;
            self.LavadoEnSesion = parent.LavadoEnSesion;
            self.PrinterIO = parent.PrinterIO;
        }
        self.ReloadData(self.UsuarioEnSesion.date, endDate: NSDate().forServer);
       
        self.BackgroundView.backgroundColor = UIColor.MKColor.LightGreen.colorWithAlphaComponent(0.20);
        self.isCorteCompleto = false;
        self.PrintButton.hidden = false;

    }
    
    func ReloadData(startDate:String, endDate:String){
        

        self.LoadingView.startAnimating();
        
        if let parent = self.presentingViewController as? MainViewController{
            
            self.TicketsHistory = [];
            self.ResumeArray = [];
            
            parent.Store.RecoverCorteOnSession();
            
            self.TicketsHistory = parent.Store.StoredTickets;
            self.SpendsHistory = parent.Store.StoredSpends;
            self.IngressesHistory = parent.Store.StoredIngresses;
            self.PaybillsHistory = parent.Store.StoredBills;
            
            var totalTickets = 0.0;
            for ticket in parent.Store.StoredTickets {
                totalTickets += Double(ticket.total);
            }
            
            if(parent.Store.StoredTickets.count > 0){
                self.ResumeArray.append(("\(parent.Store.StoredTickets.count).- Tickets","+ $\(self.Format.Number.stringFromNumber(totalTickets)!)"));
            }
            
            var totalSpends = 0.0;
            let countSpends = parent.Store.StoredSpends.count;
            for spend in parent.Store.StoredSpends {
                totalSpends += Double(spend.total);
            }
            if(countSpends > 0){
                self.ResumeArray.append(("\(countSpends).- Gastos","- $\(self.Format.Number.stringFromNumber(totalSpends)!)"));
            }
            
            var totalIngresses = 0.0;
            let countIngresses = parent.Store.StoredIngresses.count;
            for ingress in parent.Store.StoredIngresses {
                totalIngresses += Double(ingress.total);
            }
            if(countIngresses > 0 ){
                self.ResumeArray.append(("\(countIngresses).- Ingresos","+ $\(self.Format.Number.stringFromNumber(totalIngresses)!)"));
            }
            
            var totalPaybills = 0.0;
            let countPaybills = parent.Store.StoredBills.count;
            for bill in parent.Store.StoredBills {
                totalPaybills += Double(bill.total);
            }
            if(countPaybills > 0 ){
                self.ResumeArray.append(("\(countPaybills).- Vales","- $\(self.Format.Number.stringFromNumber(totalPaybills)!)"));
            }
            
            let difference = (totalTickets + totalIngresses) - totalSpends - totalPaybills;
            self.ResumeTotalLabel.text = self.Format.Number.stringFromNumber(difference);
            
            self.ResumeTableView.reloadData();
            self.LoadingView.stopAnimating();
            self.RefreshImage();

        }
        
    }
    
    func RefreshImage () {
        
        if isCorteCompleto{
            ImageCorte = self.PrinterIO.CorteToImage(self.TicketsHistory, Spends: self.SpendsHistory, Ingresses: self.IngressesHistory, Paybills: self.PaybillsHistory, Type: "Corte Completo");
        }else{
            ImageCorte = self.PrinterIO.CorteToImage(self.TicketsHistory, Spends: self.SpendsHistory, Ingresses: self.IngressesHistory, Paybills: self.PaybillsHistory, Type: "Corte Intermedio");
        
        }
        
        let imageView = UIImageView(image: ImageCorte);
        self.DetailScrollView.addSubview(imageView);
        self.DetailScrollView.contentSize = CGSizeMake(imageView.frame.size.width, imageView.frame.size.height);
        self.DetailScrollView.scrollEnabled = true;
        
    }
    
    // MARK: UITableViewDataSource Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ResumeArray.count;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50;
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if cell.respondsToSelector(Selector("setSeparatorInset:")){
            cell.separatorInset = UIEdgeInsetsZero;
        }
        if cell.respondsToSelector(Selector("setPreservesSuperviewLayoutMargins:")){
            cell.preservesSuperviewLayoutMargins = false;
        }
        
        if cell.respondsToSelector(Selector("setLayoutMargins:")){
            cell.layoutMargins = UIEdgeInsetsZero;
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:DataBaseTableViewCell!;

        cell = self.ResumeTableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! DataBaseTableViewCell
        
        cell.Denomination?.text = self.ResumeArray[indexPath.row].0;
        cell.Price?.text = self.ResumeArray[indexPath.row].1;

        return cell;
    }
    
    
    // MARK:  UITableViewDelegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    @IBAction func Print(sender: AnyObject) {
        
        CozyLoadingActivity.show("Imprimiendo...", disableUI: true);
        {self.PrinterIO.PrintImage(self.ImageCorte)} ~> {
            CozyLoadingActivity.hide(success: true, animated: true);
        }
        
    }
    
    
    @IBAction func MakeCorte(sender: AnyObject) {
        if let parent = self.presentingViewController as? MainViewController{
            if(isCorteCompleto){
                if parent.Tickets.count == 0 {
                    let vc = self.storyboard?.instantiateViewControllerWithIdentifier("LoginCorteViewController") as! LoginCorteViewController
                    vc.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext;
                    vc.LavadoEnSesion = parent.LavadoEnSesion;
                    vc.UsuarioEnSesion = parent.UsuarioEnSesion;
                    vc.isCorteCompleto = self.isCorteCompleto;
                    
                    self.presentViewController(vc, animated: false, completion: nil);
                    
                }else{
                    alerta("Error", Mensaje: "No se puede hacer un corte completo con tickets en cola, favor de cobrarlos.");
                }
            }else{
            
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("LoginCorteViewController") as! LoginCorteViewController
                vc.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext;
                vc.LavadoEnSesion = parent.LavadoEnSesion;
                vc.UsuarioEnSesion = parent.UsuarioEnSesion;
                vc.isCorteCompleto = self.isCorteCompleto;
                
                self.presentViewController(vc, animated: false, completion: nil);

            }
        }
    }
    
    @IBAction func CorteIAction(sender: AnyObject) {
        self.isCorteCompleto = false;
        self.BackgroundView.backgroundColor = UIColor.MKColor.LightGreen.colorWithAlphaComponent(0.20);
        self.PrintButton.hidden = false;
        self.RefreshImage();
    }
    
    @IBAction func CorteCAction(sender: AnyObject) {
        self.isCorteCompleto = true;
        self.BackgroundView.backgroundColor = UIColor.MKColor.Red.colorWithAlphaComponent(0.80);
        self.PrintButton.hidden = true;
        self.RefreshImage();
    }

    @IBAction func CloseView(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    func alerta(Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
