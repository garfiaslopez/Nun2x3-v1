//
//  PendingsViewController.swift
//  EnUn2x3 Admin
//
//  Created by Jose De Jesus Garfias Lopez on 27/08/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import MaterialKit
import SwiftyJSON
import Alamofire
import SWTableViewCell


class PendingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SWTableViewCellDelegate{

    let DELEGATE = UIApplication.sharedApplication().delegate as! AppDelegate
    let Save = NSUserDefaults.standardUserDefaults();
    let ApiUrl = VARS().getApiUrl();
    let Format = Formatter();
    let Store = StoreData();
    
    var Timer = NSTimer();
    var UsuarioEnSesion:Session = Session();
    var LavadoEnSesion:LavadoSession = LavadoSession();
    
    var DataArray:Array<PendingModel> = [];
    
    
    
    @IBOutlet weak var NavigationBar: UINavigationBar!
    @IBOutlet weak var Loading_View: UIImageView!
    
    @IBOutlet weak var AcceptButton: MKButton!
    @IBOutlet weak var CancelButton: MKButton!
    
    @IBOutlet weak var AddLabel: UILabel!
    @IBOutlet weak var ListLabel: UILabel!
    
    @IBOutlet weak var AddCardView: UIView!
    @IBOutlet weak var ListTableView: UITableView!
    
    @IBOutlet weak var DenominationTextView: UITextView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        
        let nib = UINib(nibName: "PendingTableViewCell", bundle: nil);
        self.ListTableView.registerNib(nib, forCellReuseIdentifier: "cell");
        
        self.NavigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Roboto-Regular", size: 25)!, NSForegroundColorAttributeName: UIColor.whiteColor()];
        
        AddCardView.layer.shadowColor = UIColor.grayColor().CGColor;
        AddCardView.layer.shadowOpacity = 0.5;
        AddCardView.layer.shadowRadius = 2.0;
        AddCardView.layer.shadowOffset = CGSizeMake(1.0, 1.0);
        AddCardView.layer.masksToBounds = false;
        
        ListTableView.layer.shadowColor = UIColor.grayColor().CGColor;
        ListTableView.layer.shadowOpacity = 0.5;
        ListTableView.layer.shadowRadius = 2.0;
        ListTableView.layer.shadowOffset = CGSizeMake(1.0, 1.0);
        ListTableView.layer.masksToBounds = false;
        
        AcceptButton.layer.shadowOpacity = 0.55;
        AcceptButton.layer.shadowRadius = 5.0;
        AcceptButton.layer.shadowColor = UIColor.grayColor().CGColor;
        AcceptButton.layer.shadowOffset = CGSize(width: 0, height: 2.5);
        
        CancelButton.layer.shadowOpacity = 0.55;
        CancelButton.layer.shadowRadius = 5.0;
        CancelButton.layer.shadowColor = UIColor.grayColor().CGColor;
        CancelButton.layer.shadowOffset = CGSize(width: 0, height: 2.5);
        
        var ImagesForAnimation: [UIImage] = [];
        for i in 1...21 {
            ImagesForAnimation.append(UIImage(named:"Loading_\(i).png")!);
        }
        
        Loading_View.animationImages = ImagesForAnimation;
        Loading_View.animationDuration = 1.0;

    }
    
    override func viewDidAppear(animated: Bool) {
        self.ReloadData();
    }

    func ConstructButtonsForTableView() -> NSMutableArray {
        let RightUtilityButtons:NSMutableArray = [];
        let CenterAtt = NSMutableParagraphStyle();
        CenterAtt.maximumLineHeight = 30.0;
        CenterAtt.alignment = NSTextAlignment.Center;
        
        let DeleteLabel = NSMutableAttributedString(string:"Terminada");
        DeleteLabel.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSRange(location:0,length: DeleteLabel.length));
        DeleteLabel.addAttribute(NSParagraphStyleAttributeName, value: CenterAtt, range: NSRange(location: 0,length: DeleteLabel.length));
        DeleteLabel.addAttribute(NSFontAttributeName, value: UIFont(name: "Roboto", size: 20)!, range: NSRange(location: 0, length: DeleteLabel.length));
        
        RightUtilityButtons.sw_addUtilityButtonWithColor(UIColor.MKColor.Green, attributedTitle: DeleteLabel);
        
        return RightUtilityButtons;
    }
    
    func ReloadData() {
        
        self.Loading_View.startAnimating();
        self.DataArray = self.Store.RecoverPendings();
        self.ListTableView.reloadData();
        self.Loading_View.stopAnimating();
        
    }
    
    @IBAction func UploadPending(sender: AnyObject) {
        
        if(self.DenominationTextView.text != "") {
            self.Loading_View.startAnimating();
            CozyLoadingActivity.show("Guardando...", disableUI: true)
            
            let pending:PendingModel = PendingModel();
            
            pending.lavado_id = self.LavadoEnSesion._id;
            pending.corte_id = self.UsuarioEnSesion.corte_id;
            pending.denomination = self.DenominationTextView.text;
            pending.user = self.UsuarioEnSesion.name;
            pending.date = Format.ParseMomentDate(self.UsuarioEnSesion.date);
            pending.isDone = false;
            
            
            let status = Reach().connectionStatus();
            
            switch status {
            case .Online(.WWAN), .Online(.WiFi):
                
                let POSTURL = String(ApiUrl + "/pending");
                let headers = [
                    "Authorization": self.UsuarioEnSesion.token
                ]
                
                let DatatoSend = [
                    "lavado_id": pending.lavado_id,
                    "corte_id": pending.corte_id,
                    "denomination": pending.denomination,
                    "user": pending.user,
                    "date": pending.date.forServer,
                    "isDone": String(pending.isDone),
                    ];
                
                Alamofire.request(.POST, POSTURL, headers: headers, parameters: DatatoSend, encoding: .JSON).responseJSON { response in
                    
                    switch response.result {
                    case .Success:
                        let data = JSON(data: response.data!);
                        if(data["success"] == true){
                            
                            //STORE LOCALLY WITH TRUE FLAG ON SERVERSAVED:
                            
                            print("TORE LOCALLY WITH TRUE FLAG ON SERVERSAVED");
                            
                            pending.savedOnServer = true;
                            pending._id = data["_id"].stringValue;
                            
                            self.Store.SavePending(pending);
                            self.ReloadData();
                            
                            SocketIOManager.sharedInstance.EmitAddedPending(pending);
                            
                            self.ClearTextFields();
                            CozyLoadingActivity.hide(success: true, animated: true)
                            self.Loading_View.stopAnimating();
                            
                        }else{
                            
                            CozyLoadingActivity.hide(success: false, animated: true)
                            if(data["message"] == "Corrupt Token."){
                                self.performSegueWithIdentifier("LoginSegue", sender: self);
                            }else{
                                self.alerta("Error de Sesion", Mensaje: data["message"].stringValue );
                                self.Loading_View.stopAnimating();
                            }
                        }
                    case .Failure:
                        
                        print("STORE LOCALLY WITH FALSE FLAG ON SERVERSAVED");
                        
                        pending.savedOnServer = false;
                        self.Store.SavePending(pending);
                        self.Save.setBool(true, forKey: "UploadBackupServer");
                        self.ReloadData();
                        
                        CozyLoadingActivity.hide(success: true, animated: true)
                        self.Loading_View.stopAnimating();
                    }
                }
                
            case .Unknown, .Offline:
                
                print("TORE LOCALLY WITH FALSE UNKNOW FLAG ON SERVERSAVED");
                
                pending.savedOnServer = false;
                self.Store.SavePending(pending);
                self.Save.setBool(true, forKey: "UploadBackupServer");
                
                self.ReloadData();
                self.ClearTextFields();
                CozyLoadingActivity.hide(success: true, animated: true);
                self.Loading_View.stopAnimating();
            }
        }
    }
    
    func DeletePending(Obj:PendingModel){
        
        self.Loading_View.startAnimating();
        CozyLoadingActivity.show("Eliminando...", disableUI: true)
        
        //Si se logro guardar con un ID del servidor y tenemos para elminiarlo,
        if(Obj._id != ""){
            
            //revisar si hay internet para poder borrar en el servidor...
            let status = Reach().connectionStatus();
            
            switch status {
            case .Online(.WWAN), .Online(.WiFi):
                
                let DELURL = String(ApiUrl + "/pending/\(Obj._id)");
                let headers = [
                    "Authorization": self.UsuarioEnSesion.token
                ]
                
                Alamofire.request(.DELETE, DELURL, headers: headers, encoding: .JSON).responseJSON { response in
                    
                    switch response.result {
                    case .Success:
                        let data = JSON(data: response.data!);
                        
                        if(data["success"] == true){
                            
                            //STORE LOCALLY WITH TRUE FLAG ON SERVERSAVED:
                            self.Store.DeletePending(Obj);
                            CozyLoadingActivity.hide(success: true, animated: true)
                            self.Loading_View.stopAnimating();
                        }else{
                            CozyLoadingActivity.hide(success: false, animated: true)
                            if(data["message"] == "Corrupt Token."){
                                self.performSegueWithIdentifier("LoginSegue", sender: self);
                            }else{
                                self.alerta("Error de Sesion", Mensaje: data["message"].stringValue );
                                self.Loading_View.stopAnimating();
                            }
                        }
                    case .Failure:
                        self.Store.UpdateShouldBeDeletedPending(Obj, Should: true);
                        self.Save.setBool(true, forKey: "RefreshDeleteServer");
                        CozyLoadingActivity.hide(success: true, animated: true)
                        self.Loading_View.stopAnimating();
                    }
                }
                
            case .Unknown, .Offline:
                self.Store.UpdateShouldBeDeletedPending(Obj, Should: true);
                self.Save.setBool(true, forKey: "RefreshDeleteServer");
                CozyLoadingActivity.hide(success: true, animated: true)
                self.Loading_View.stopAnimating();
            }
            
            
        }else{
            
            if(Obj.savedOnServer == true){
                //NO TENGO ID DEL OBJETO PERO YA SE SUBIO AL SERVER
                print("NO TENGO ID DEL OBJETO PERO YA ESTA EN SERVER·");
                CozyLoadingActivity.hide(success: false, animated: true)
                self.Loading_View.stopAnimating();
                
            }else{
                //Solo borralo localmente:
                self.Store.DeletePending(Obj);
                CozyLoadingActivity.hide(success: true, animated: true)
                self.Loading_View.stopAnimating();
            }
        }
    }
    
    
    // MARK: UITableViewDataSource Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.DataArray.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100;
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
        
        var cell:PendingTableViewCell;
        cell = self.ListTableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! PendingTableViewCell;
        
        cell.rightUtilityButtons = self.ConstructButtonsForTableView() as [AnyObject];
        cell.delegate = self;
        cell.dateLabel.text = Format.DatePretty.stringFromDate(self.DataArray[indexPath.row].date);
        cell.userLabel.text = self.DataArray[indexPath.row].user;
        cell.denominationLabel.text = self.DataArray[indexPath.row].denomination;
        
        return cell;
        
    }
    
    // MARK:  UITableViewDelegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("SELECTED");
    }
    
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
        
        if index == 0 {
            let cellIndexPath = self.ListTableView.indexPathForCell(cell);
            
            self.DeletePending(self.DataArray[cellIndexPath!.row]);
            self.DataArray.removeAtIndex(cellIndexPath!.row);
            self.ListTableView.deleteRowsAtIndexPaths([cellIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic);
        }
    }
    
    
    @IBAction func CloseModal(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    func ClearTextFields(){
        DenominationTextView.text = "";
        self.dissmissKeyboard();
    }
    @IBAction func Cancel(sender: AnyObject) {
        ClearTextFields();
    }
    
    
    
    func dissmissKeyboard(){
        self.DenominationTextView.resignFirstResponder();
    }
    
    func alerta(Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }

}
