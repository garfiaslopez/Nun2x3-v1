//
//  MenuViewController.swift
//  NUn2x3
//
//  Created by Jose De Jesus Garfias Lopez on 27/09/15.
//  Copyright (c) 2015 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import MaterialKit
import SwiftyJSON
import Alamofire
import SWTableViewCell

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SWTableViewCellDelegate{
    
    let DELEGATE = UIApplication.sharedApplication().delegate as! AppDelegate
    let Save = NSUserDefaults.standardUserDefaults();
    let ApiUrl = VARS().getApiUrl();
    let Format = Formatter();
    let Store = StoreData();
    
    var Timer = NSTimer();
    var UsuarioEnSesion:Session = Session();
    var LavadoEnSesion:LavadoSession = LavadoSession();
    
    var DataArray:Array<BaseModel> = [];
    
    
    @IBOutlet weak var NavigationBar: UINavigationBar!
    
    @IBOutlet weak var Loading_View: UIImageView!

    @IBOutlet weak var ConceptoTextField: UITextField!
    @IBOutlet weak var CantidadTextField: UITextField!
    
    @IBOutlet weak var AcceptButton: UIButton!
    @IBOutlet weak var CancelButton: UIButton!

    @IBOutlet weak var AddLabel: UILabel!
    @IBOutlet weak var ListLabel: UILabel!
    
    @IBOutlet weak var AddCardView: UIView!
    @IBOutlet weak var ListTableView: UITableView!

    @IBOutlet weak var InfoCardView: UIView!
    @IBOutlet weak var TotalLabel: UILabel!
    @IBOutlet weak var NumberLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let nib = UINib(nibName: "DataBaseTableViewCell", bundle: nil);
        self.ListTableView.registerNib(nib, forCellReuseIdentifier: "cell");
        //self.ListTableView.userInteractionEnabled = false;
        
        self.NavigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Roboto-Regular", size: 25)!, NSForegroundColorAttributeName: UIColor.whiteColor()];
        
        AddCardView.layer.shadowColor = UIColor.grayColor().CGColor;
        AddCardView.layer.shadowOpacity = 0.5;
        AddCardView.layer.shadowRadius = 2.0;
        AddCardView.layer.shadowOffset = CGSizeMake(1.0, 1.0);
        AddCardView.layer.masksToBounds = false;
        
        InfoCardView.layer.shadowColor = UIColor.grayColor().CGColor;
        InfoCardView.layer.shadowOpacity = 0.5;
        InfoCardView.layer.shadowRadius = 2.0;
        InfoCardView.layer.shadowOffset = CGSizeMake(1.0, 1.0);
        InfoCardView.layer.masksToBounds = false;
        
        ListTableView.layer.shadowColor = UIColor.grayColor().CGColor;
        ListTableView.layer.shadowOpacity = 0.5;
        ListTableView.layer.shadowRadius = 2.0;
        ListTableView.layer.shadowOffset = CGSizeMake(1.0, 1.0);
        ListTableView.layer.masksToBounds = false;
        
        // No border, no shadow, floatingPlaceholderEnabled
        ConceptoTextField.layer.borderColor = UIColor.clearColor().CGColor;
        ConceptoTextField.tintColor = UIColor.MKColor.Orange;
        
        CantidadTextField.layer.borderColor = UIColor.clearColor().CGColor;
        CantidadTextField.tintColor = UIColor.MKColor.Orange;
        
        AcceptButton.layer.shadowOpacity = 0.55;
        AcceptButton.layer.shadowRadius = 5.0;
        AcceptButton.layer.shadowColor = UIColor.grayColor().CGColor;
        AcceptButton.layer.shadowOffset = CGSize(width: 0, height: 2.5);

        CancelButton.layer.shadowOpacity = 0.55;
        CancelButton.layer.shadowRadius = 5.0;
        CancelButton.layer.shadowColor = UIColor.grayColor().CGColor;
        CancelButton.layer.shadowOffset = CGSize(width: 0, height: 2.5);
        
        self.NumberLabel.text = "#0";
        self.TotalLabel.text = "$0.00";
        
        var ImagesForAnimation: [UIImage] = [];
        for i in 1...21 {
            ImagesForAnimation.append(UIImage(named:"Loading_\(i).png")!);
        }
        
        Loading_View.animationImages = ImagesForAnimation;
        Loading_View.animationDuration = 1.0;
        
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    func ConstructButtonsForTableView() -> NSMutableArray {
        let RightUtilityButtons:NSMutableArray = [];
        let CenterAtt = NSMutableParagraphStyle();
        CenterAtt.maximumLineHeight = 30.0;
        CenterAtt.alignment = NSTextAlignment.Center;
        
        let DeleteLabel = NSMutableAttributedString(string:"Eliminar");
        DeleteLabel.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSRange(location:0,length: DeleteLabel.length));
        DeleteLabel.addAttribute(NSParagraphStyleAttributeName, value: CenterAtt, range: NSRange(location: 0,length: DeleteLabel.length));
        DeleteLabel.addAttribute(NSFontAttributeName, value: UIFont(name: "Roboto", size: 20)!, range: NSRange(location: 0, length: DeleteLabel.length));
        
        RightUtilityButtons.sw_addUtilityButtonWithColor(UIColor.MKColor.Red, attributedTitle: DeleteLabel);
        
        return RightUtilityButtons;
    }
    
    func ReloadData(TypeBase:String) {
    
        self.Loading_View.startAnimating();
        
        self.DataArray = self.Store.RecoverBaseModel(TypeBase);
        self.ListTableView.reloadData();
        self.NumberLabel.text = "#\(self.DataArray.count)";
        
        var total:Double = 0.0;
        for obj in self.DataArray {
            total = total + obj.total;
        }
        self.TotalLabel.text = "$" + Formatter().Number.stringFromNumber(total)!;
        self.Loading_View.stopAnimating();
        
    }
    
    func UploadObj(Url:String,Section:String,TypeBase:String,Obj:BaseModel){
        
        self.Loading_View.startAnimating();
        CozyLoadingActivity.show("Guardando...", disableUI: true)
        
        let status = Reach().connectionStatus();
        
        switch status {
        case .Online(.WWAN), .Online(.WiFi):
            
            let POSTURL = String(ApiUrl + Url);
            let headers = [
                "Authorization": self.UsuarioEnSesion.token
            ]
            
            let DatatoSend = [
                "lavado_id": self.LavadoEnSesion._id,
                "corte_id": Obj.corte_id,
                "denomination": Obj.denomination,
                "total": String(Obj.total),
                "user": Obj.user,
                "date": Obj.date.forServer,
                "isMonthly": String(Obj.isMonthly),
                "owner": Obj.owner
            ];
            
            Alamofire.request(.POST, POSTURL, headers: headers, parameters: DatatoSend, encoding: .JSON).responseJSON { response in
                
                switch response.result {
                case .Success:
                    let data = JSON(data: response.data!);
                    if(data["success"] == true){
                        
                        //STORE LOCALLY WITH TRUE FLAG ON SERVERSAVED:
                        
                        print("TORE LOCALLY WITH TRUE FLAG ON SERVERSAVED");
                        
                        Obj.savedOnServer = true;
                        Obj._id = data["_id"].stringValue;
                        
                        self.Store.SaveBaseModel(Obj);
                        self.ReloadData(TypeBase);
                        
                        SocketIOManager.sharedInstance.EmitDashboard();
                        
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

                    Obj.savedOnServer = false;
                    self.Store.SaveBaseModel(Obj);
                    self.Save.setBool(true, forKey: "UploadBackupServer");
                    self.ReloadData(TypeBase);
                    
                    CozyLoadingActivity.hide(success: true, animated: true)
                    self.Loading_View.stopAnimating();
                }
            }
            
        case .Unknown, .Offline:
            
            print("TORE LOCALLY WITH FALSE UNKNOW FLAG ON SERVERSAVED");

            Obj.savedOnServer = false;
            self.Store.SaveBaseModel(Obj);
            self.Save.setBool(true, forKey: "UploadBackupServer");
            
            self.ReloadData(TypeBase);
            self.ClearTextFields();
            CozyLoadingActivity.hide(success: true, animated: true);
            self.Loading_View.stopAnimating();
        }
    }
    
    func DeleteObj(Url:String,Section:String,TypeBase:String,Obj:BaseModel){
        
        self.Loading_View.startAnimating();
        CozyLoadingActivity.show("Eliminando...", disableUI: true)
        
        //Si se logro guardar con un ID del servidor y tenemos para elminiarlo,
        if(Obj._id != ""){
        
            //revisar si hay internet para poder borrar en el servidor...
            let status = Reach().connectionStatus();
            
            switch status {
            case .Online(.WWAN), .Online(.WiFi):
                
                let DELURL = String(ApiUrl + Url + "/\(Obj._id)");
                let headers = [
                    "Authorization": self.UsuarioEnSesion.token
                ]
                
                Alamofire.request(.DELETE, DELURL, headers: headers, encoding: .JSON).responseJSON { response in
                    
                    switch response.result {
                    case .Success:
                        let data = JSON(data: response.data!);
                        
                        if(data["success"] == true){
                            
                            //STORE LOCALLY WITH TRUE FLAG ON SERVERSAVED:
                            self.Store.DeleteBaseModel(Obj);
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
                        self.Store.UpdateShouldBeDeleted(Obj, Should: true);
                        self.Save.setBool(true, forKey: "RefreshDeleteServer");
                        CozyLoadingActivity.hide(success: true, animated: true)
                        self.Loading_View.stopAnimating();
                    }
                }
                
            case .Unknown, .Offline:
                self.Store.UpdateShouldBeDeleted(Obj, Should: true);
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
                self.Store.DeleteBaseModel(Obj);
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
        return 70;
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
        
        var cell:DataBaseTableViewCell;
        cell = self.ListTableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! DataBaseTableViewCell
        cell.rightUtilityButtons = self.ConstructButtonsForTableView() as [AnyObject];
        cell.delegate = self;
        cell.Denomination?.text = self.DataArray[indexPath.row].denomination;
        cell.Price?.text = "$" + Formatter().Number.stringFromNumber(self.DataArray[indexPath.row].total)!;

        return cell;
        
    }
    
    // MARK:  UITableViewDelegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("SELECTED");
    }

    func CloseView(){
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    func ClearTextFields(){
        ConceptoTextField.text = "";
        CantidadTextField.text = "";
        self.dissmissKeyboard();
    }
    @IBAction func Cancel(sender: AnyObject) {
        ClearTextFields();
    }
    
    func dissmissKeyboard(){
        self.CantidadTextField.resignFirstResponder();
        self.ConceptoTextField.resignFirstResponder();
    }
    
    func alerta(Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
}
