//
//  HistoryViewController.swift
//  NUn2x3
//
//  Created by Jose De Jesus Garfias Lopez on 27/09/15.
//  Copyright (c) 2015 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import MaterialKit
import SwiftyJSON
import Alamofire
import RealmSwift

class HistoryViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource{

    let ApiUrl = VARS().getApiUrl();
    let Format = Formatter();
    
    var PrinterIO:Printer!;
    var UsuarioEnSesion:Session!;
    var LavadoEnSesion:LavadoSession!;
    
    var SelectedTicket:Int? = nil;
    var TicketsHistory:Array<TicketModel> = [];
    var ResumeArray:Array<(String,String)> = [];
    
    var imageHistoryCorte:UIImage!;
    var SelectedDate:NSDate = NSDate();

    //tag:0 detail
    //tag:1 resume
    
    @IBOutlet weak var NavigationBar: UINavigationBar!
    @IBOutlet weak var FilterLabel: UILabel!
    @IBOutlet weak var DetailLabel: UILabel!
    @IBOutlet weak var FilterView: UIView!
    @IBOutlet weak var StartDateTextfield: UITextField!
    @IBOutlet weak var DateSegment: UISegmentedControl!
    
    
    @IBOutlet weak var SearchButton: UIButton!
    @IBOutlet weak var PrintButton: UIButton!
    @IBOutlet weak var ResumeView: UIView!
    @IBOutlet weak var ResumeTableView: UITableView!
    @IBOutlet weak var ResumeTotalLabel: UILabel!
    @IBOutlet weak var DetailTableView: UITableView!
    @IBOutlet weak var LoadingView: UIImageView!
    @IBOutlet weak var HistoryView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let nib = UINib(nibName: "DataBaseTableViewCell", bundle: nil);
        self.ResumeTableView.registerNib(nib, forCellReuseIdentifier: "cell");
        
        self.NavigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Roboto-Regular", size: 25)!, NSForegroundColorAttributeName: UIColor.whiteColor()];
        
        FilterView.layer.shadowColor = UIColor.grayColor().CGColor;
        FilterView.layer.shadowOpacity = 0.5;
        FilterView.layer.shadowRadius = 2.0;
        FilterView.layer.shadowOffset = CGSizeMake(1.0, 1.0);
        FilterView.layer.masksToBounds = false;
        
        ResumeView.layer.shadowColor = UIColor.grayColor().CGColor;
        ResumeView.layer.shadowOpacity = 0.5;
        ResumeView.layer.shadowRadius = 2.0;
        ResumeView.layer.shadowOffset = CGSizeMake(1.0, 1.0);
        ResumeView.layer.masksToBounds = false;
        
        
        // No border, no shadow, floatingPlaceholderEnabled
        StartDateTextfield.layer.borderColor = UIColor.clearColor().CGColor;
        StartDateTextfield.tintColor = UIColor.orangeColor();
        StartDateTextfield.delegate = self;
        StartDateTextfield.placeholder = NSDate().forServer;

        SearchButton.layer.shadowOpacity = 0.55;
        SearchButton.layer.shadowRadius = 5.0;
        SearchButton.layer.shadowColor = UIColor.grayColor().CGColor;
        SearchButton.layer.shadowOffset = CGSize(width: 0, height: 2.5);

        PrintButton.layer.shadowOpacity = 0.55;
        PrintButton.layer.shadowRadius = 5.0;
        PrintButton.layer.shadowColor = UIColor.grayColor().CGColor;
        PrintButton.layer.shadowOffset = CGSize(width: 0, height: 2.5);

        var ImagesForAnimation: [UIImage] = [];
        for i in 1...21 {
            ImagesForAnimation.append(UIImage(named:"Loading_\(i).png")!);
        }
        LoadingView.animationImages = ImagesForAnimation;
        LoadingView.animationDuration = 1.0;

        
    }
    
    override func viewDidAppear(animated: Bool) {
        self.SelectedDate = self.Format.Today();
        self.StartDateTextfield.text = self.Format.DatePretty.stringFromDate(self.SelectedDate);
        self.ReloadData(self.Format.Today().forServer, endDate: self.Format.Today().addDays(1).forServer);
        if let parent = self.presentingViewController as? MainViewController{
            self.UsuarioEnSesion = parent.UsuarioEnSesion;
            self.LavadoEnSesion = parent.LavadoEnSesion;
            self.PrinterIO = parent.PrinterIO;
        }
    }
    
    func ReloadData(startDate:String, endDate:String){
        
        self.LoadingView.startAnimating();

        if let parent = self.presentingViewController as? MainViewController{
            
            self.TicketsHistory = [];
            self.ResumeArray = [];
        
            parent.Store.RecoverHistory(startDate, finalDate: endDate);
            
            self.TicketsHistory = parent.Store.StoredTickets;
            
            print(self.TicketsHistory);
            
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
            let difference = (totalTickets + totalIngresses) - totalSpends;
            self.ResumeTotalLabel.text = self.Format.Number.stringFromNumber(difference);
            
            self.ResumeTableView.reloadData();
            self.LoadingView.stopAnimating();
            
            //LOAD THE CORTE 
            
            self.imageHistoryCorte = parent.PrinterIO.CorteToImage(parent.Store.StoredTickets, Spends: parent.Store.StoredSpends, Ingresses: parent.Store.StoredIngresses, Paybills: parent.Store.StoredBills, Type: "HISTORIAL: \(startDate) - \(endDate))");
            
            let imageView = UIImageView(image: imageHistoryCorte);
            self.HistoryView.addSubview(imageView);
            self.HistoryView.contentSize = CGSizeMake(imageView.frame.size.width, imageView.frame.size.height);
            self.HistoryView.scrollEnabled = true;

        }
        
    }
    
    @IBAction func Search(sender: AnyObject) {
        if(self.StartDateTextfield != ""){
            switch self.DateSegment.selectedSegmentIndex {
            case 0:
                self.ReloadData(self.SelectedDate.forServer, endDate: self.SelectedDate.addDays(1).forServer);
                break;
            case 1:
                let initial = self.Format.FirstDayOfMonth(self.SelectedDate);
                let final = initial.addMonths(1);
                self.ReloadData(initial.forServer, endDate: final.forServer);
                break;
            case 2:
                let initial = self.Format.FirstDayOfYear(self.SelectedDate);
                self.ReloadData(initial.forServer, endDate: initial.addDays(366).forServer);
            default:
                self.ReloadData(Format.Today().forServer, endDate: self.Format.Today().addDays(1).forServer);
            }
        }else{
            self.alerta("Error", Mensaje: "Favor de elegir un rango de fechas.");
        }
    }
    
    @IBAction func Print(sender: AnyObject) {
        
        CozyLoadingActivity.show("Imprimiendo...", disableUI: true);
        {self.PrinterIO.PrintImage(self.imageHistoryCorte)} ~> {
            CozyLoadingActivity.hide(success: true, animated: true);
        }
    }

    // MARK: UITableViewDataSource Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView.tag == 0){
            return TicketsHistory.count;
        }else if(tableView.tag == 1){
            return ResumeArray.count;
        }else{
            return 0;
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50;
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if cell.respondsToSelector(Selector("setLayoutMargins:")){
            cell.layoutMargins = UIEdgeInsetsZero;
        }
        
        if cell.respondsToSelector(Selector("setSeparatorInset:")){
            cell.separatorInset = UIEdgeInsetsZero;
        }
        if cell.respondsToSelector(Selector("setPreservesSuperviewLayoutMargins:")
            ){
            cell.preservesSuperviewLayoutMargins = false;
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:DataBaseTableViewCell!;
        
        
        if(tableView.tag == 0 ){
            
            cell = self.DetailTableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! DataBaseTableViewCell
            cell.Denomination.font = UIFont(name: "Roboto-Regular", size: 25);
            cell.Denomination?.text = Format.DatePretty.stringFromDate(self.TicketsHistory[indexPath.row].date);
            cell.Price?.text = "$" + Formatter().Number.stringFromNumber(self.TicketsHistory[indexPath.row].total)!;
            
        }else if(tableView.tag == 1){
            
            cell = self.ResumeTableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! DataBaseTableViewCell
            
            cell.Denomination?.text = self.ResumeArray[indexPath.row].0;
            cell.Price?.text = self.ResumeArray[indexPath.row].1;
            
        }
        
        return cell;
    }
    
    // MARK:  UITableViewDelegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if(tableView.tag == 0 ){
            self.SelectedTicket = indexPath.row;
            
            let selectedCell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
            selectedCell.contentView.backgroundColor = UIColor.MKColor.Green;
            
            if let parent = self.presentingViewController as? MainViewController{
                
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ShowTicketViewController") as! ShowTicketViewController
                vc.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext;
                vc.PrinterIO = parent.PrinterIO;
                vc.ActualTicket = self.TicketsHistory[indexPath.row];
                
                self.presentViewController(vc, animated: false, completion: nil);
            }
        }
        
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
        if(tableView.tag == 0 ){
            let selectedCell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
            selectedCell.contentView.backgroundColor = UIColor.whiteColor();
        }
    }
    @IBAction func ChangeDateFilter(sender: AnyObject) {
        
        switch self.DateSegment.selectedSegmentIndex {
        case 0:
            self.StartDateTextfield.text = self.Format.DatePretty.stringFromDate(self.SelectedDate);
            break;
        case 1:
            self.StartDateTextfield.text = self.Format.DateMonthYearOnly.stringFromDate(self.SelectedDate);
            break;
        case 2:
            self.StartDateTextfield.text = self.Format.DateYearOnly.stringFromDate(self.SelectedDate);
            break;
        default:
            self.StartDateTextfield.text = self.Format.DatePretty.stringFromDate(self.SelectedDate);
            break;
        }
        
    }
    
    @IBAction func CloseView(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        DatePickerDialog().show("Selecciona Una Fecha", doneButtonTitle: "Seleccionar", cancelButtonTitle: "Cancelar", defaultDate: self.SelectedDate, datePickerMode: UIDatePickerMode.Date){
            (date) -> Void in
            
            let dateS = self.Format.DateOnly.stringFromDate(date);
            self.SelectedDate = self.Format.DateOnly.dateFromString(dateS)!;
            
            switch self.DateSegment.selectedSegmentIndex {
            case 0:
                textField.text = self.Format.DatePretty.stringFromDate(date);
                break;
            case 1:
                textField.text = self.Format.DateMonthYearOnly.stringFromDate(date);
                break;
            case 2:
                textField.text = self.Format.DateYearOnly.stringFromDate(date);
                break;
            default:
                textField.text = self.Format.DatePretty.stringFromDate(date);
                break;
            }
            
        }
        
        return false;
    }
    
    func alerta(Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }

}
