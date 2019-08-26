//
//  FirstSetupViewController.swift
//  nun2x3
//
//  Created by Jose De Jesus Garfias Lopez on 24/10/15.
//  Copyright © 2015 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import MaterialKit
import SwiftyJSON
import Alamofire

struct Lavado{
    var name:String;
    var id:String;
    var doubleTicket: Bool;
}
//Ventana que solo se abre la primera vez, tiene como finalidad saber a que autolavado pertenece 
//Guardar el ID de ese lavado.
//Guardar los usuarios de ese lavado para el LOGIN por primeraVez
//En todo caso pasando esta ventana puede funcionar sin internet.

class FirstSetupViewController: UIViewController,UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    let Save = NSUserDefaults.standardUserDefaults();
    let Store = StoreData();
    let ApiUrl = VARS().getApiUrl();
    var AdminSession: NSDictionary!
    var ActualLavados: Array<Lavado> = [];
    var LavadoSelected:Lavado = Lavado(name: "no name", id: "no id", doubleTicket: false);
    var TempToken:String = "";
    
    @IBOutlet weak var UserName_TextField: UITextField!
    @IBOutlet weak var Password_TextField: UITextField!
    @IBOutlet weak var Accept_Button: UIButton!
    @IBOutlet weak var Login_View: UIView!
    @IBOutlet weak var Loading_View: UIImageView!
    @IBOutlet weak var NavBar: UINavigationBar!
    @IBOutlet weak var Continue_Button: UIButton!
    @IBOutlet weak var CarwashesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "FirstSetupTableViewCell", bundle: nil);
        self.CarwashesTableView.registerNib(nib, forCellReuseIdentifier: "cell");
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true);
        
        Login_View.layer.shadowColor = UIColor.grayColor().CGColor;
        Login_View.layer.shadowOpacity = 0.5;
        Login_View.layer.shadowRadius = 2.0;
        Login_View.layer.shadowOffset = CGSizeMake(1.0, 1.0);
        Login_View.layer.masksToBounds = false;
        
        NavBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Roboto-Regular", size: 25)!, NSForegroundColorAttributeName: UIColor.whiteColor()];
        
        // No border, no shadow, floatingPlaceholderEnabled
        UserName_TextField.layer.borderColor = UIColor.clearColor().CGColor;
        UserName_TextField.placeholder = "Nombre De Usuario";
        UserName_TextField.tintColor = UIColor.MKColor.Orange;
        
        UserName_TextField.delegate = self;
        
        // No border, no shadow, floatingPlaceholderEnabled
        Password_TextField.layer.borderColor = UIColor.clearColor().CGColor;
        Password_TextField.placeholder = "Contraseña";
        Password_TextField.tintColor = UIColor.MKColor.Orange;
        
        Password_TextField.delegate = self;
        
        Accept_Button.layer.shadowOpacity = 0.55;
        Accept_Button.layer.shadowRadius = 5.0;
        Accept_Button.layer.shadowColor = UIColor.grayColor().CGColor;
        Accept_Button.layer.shadowOffset = CGSize(width: 0, height: 2.5);
        
        //ACTIVAR NOTIFICACIONES DEL TECLADO:
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FirstSetupViewController.KeyboardDidShow), name: UIKeyboardDidShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FirstSetupViewController.KeyboardDidHidden), name: UIKeyboardWillHideNotification, object: nil);
        
        var ImagesForAnimation: [UIImage] = [];
        
        for i in 1...21 {
            ImagesForAnimation.append(UIImage(named:"Loading_\(i).png")!);
        }
        
        Loading_View.animationImages = ImagesForAnimation;
        Loading_View.animationDuration = 1.0;


        // Do any additional setup after loading the view.
    }

    @IBAction func Login(sender: AnyObject) {
        Loading_View.startAnimating();
        DismissKeyboard();

        let AuthUrl = ApiUrl + "/authenticate";
        
        
        let status = Reach().connectionStatus();
        
        switch status {
        case .Online(.WWAN), .Online(.WiFi):
        
            let DatatoSend = [
                "username": self.UserName_TextField.text as AnyObject!,
                "password": self.Password_TextField.text as AnyObject!,
            ];
            Alamofire.request(.POST, AuthUrl, parameters: DatatoSend, encoding: .JSON).responseJSON { response in
                switch response.result {
                case .Success:
                    let data = JSON(data: response.data!);
                    if(data["success"] == true){
                        self.Loading_View.stopAnimating();
                        
                        self.ActualLavados = [];
                        
                        self.TempToken = data["token"].stringValue;
                        for (_,carwash):(String,JSON) in data["user"]["lavado_id"] {
                            let tmp:Lavado = Lavado(name: carwash["info"]["name"].stringValue, id: carwash["_id"].stringValue, doubleTicket: carwash["info"]["doubleTicket"].boolValue);
                            self.ActualLavados.append(tmp);
                        }
                        
                        self.CarwashesTableView.reloadData();
                    }else{
                        self.alerta("Error de Sesion", Mensaje: data["message"].stringValue );
                        self.Loading_View.stopAnimating();
                    }
                case .Failure(let error):
                    self.alerta("Error", Mensaje: error.localizedDescription);
                    self.Loading_View.stopAnimating();
                    
                }
            }
        case .Unknown, .Offline:
            self.alerta("Sin Conexion a internet", Mensaje: "Favor de conectarse a internet para acceder.");
            break
        }            //No internet connection:

    }

    
    // MARK: UITableViewDataSource Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.ActualLavados.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70;
    }
    
    

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:FirstSetupTableViewCell;
        cell = self.CarwashesTableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! FirstSetupTableViewCell
        cell.name?.text = self.ActualLavados[indexPath.row].name;
        
        return cell;
        
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
    
    // MARK:  UITableViewDelegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.LavadoSelected.name = self.ActualLavados[indexPath.row].name;
        self.LavadoSelected.id = self.ActualLavados[indexPath.row].id;
        self.LavadoSelected.doubleTicket = self.ActualLavados[indexPath.row].doubleTicket;
        
        let selectedCell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        selectedCell.contentView.backgroundColor = UIColor.MKColor.Green;
        
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
        let selectedCell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        selectedCell.contentView.backgroundColor = UIColor.whiteColor();
        
    }
    
    @IBAction func Continue(sender: AnyObject) {
        
        CozyLoadingActivity.show("Validando...", disableUI: true);
        
        if(LavadoSelected.name != "no name"){
            //Save The lavado:
            
            let tosave:NSDictionary = ["_id":LavadoSelected.id,"name":LavadoSelected.name, "doubleTicket":LavadoSelected.doubleTicket];
            Save.setObject(tosave, forKey: "LavadoEnSesion");
            Save.setObject("RecoverCorteCompleto", forKey: "StatusApp");
            Save.setBool(true, forKey: "FirstLaunch");
            
            
            let status = Reach().connectionStatus();
            
            switch status {
            case .Online(.WWAN), .Online(.WiFi):
                
                
                self.Store.DeleteAllUsers();
                let headers = [
                    "Authorization": self.TempToken
                ]
                let UrlUsers = String(ApiUrl + "/users/withToken/" + self.LavadoSelected.id);
                Alamofire.request(.GET, UrlUsers, headers: headers).responseJSON { response in
                    
                    switch response.result {
                    case .Success:
                        let data = JSON(data: response.data!);
                        if(data["success"] == true){
                            
                            print(data);
                            var NewUsers:Array<UserModel> = [];
                            
                            for (_,user):(String,JSON) in data["users"] {
                                
                                let tmp:UserModel = UserModel();
                                
                                tmp._id = user["user"]["_id"].stringValue;
                                tmp.name = user["user"]["info"]["name"].stringValue;
                                tmp.username = user["user"]["username"].stringValue;
                                tmp.password = user["user"]["password"].stringValue;
                                tmp.rol = user["user"]["rol"].stringValue;
                                tmp.token = user["token"].stringValue;
                                
                                NewUsers.append(tmp);
                            }
                            self.Store.SaveUsers(NewUsers);
                            print("Usuarios: \(NewUsers.count)");

                            
                            
                            
                            
                            let UrlCars = String(self.ApiUrl + "/cars/" + self.LavadoSelected.id);
                            Alamofire.request(.GET, UrlCars, headers: headers).responseJSON { response in
                                
                                switch response.result {
                                case .Success:
                                    let data = JSON(data: response.data!);
                                    if(data["success"] == true){
                                        
                                        self.Store.DeleteAllCarsServs();
                                        var Cars:Array<CarServModel> = [];
                                        
                                        for (_,car):(String,JSON) in data["cars"] {
                                            
                                            let tmp:CarServModel = CarServModel();
                                            
                                            tmp._id = car["_id"].stringValue;
                                            tmp.denomination = car["denomination"].stringValue;
                                            tmp.price = car["price"].doubleValue;
                                            tmp.img = car["img"].stringValue;
                                            tmp.type = "car";
                                            
                                            Cars.append(tmp);
                                        }
                                        
                                        self.Store.SaveCarsServs(Cars);
                                        print("Carros: \(Cars.count)");
                                        
                                        
                                        
                                        
                                        let UrlServices = String(self.ApiUrl + "/services/" + self.LavadoSelected.id);
                                        Alamofire.request(.GET, UrlServices, headers: headers).responseJSON { response in
                                            
                                            switch response.result {
                                            case .Success:
                                                let data = JSON(data: response.data!);
                                                if(data["success"] == true){
                                                    self.Loading_View.stopAnimating();
                                                    var Services:Array<CarServModel> = [];
                                                    
                                                    for (_,service):(String,JSON) in data["services"] {
                                                        
                                                        let tmp:CarServModel = CarServModel();
                                                        
                                                        tmp._id = service["_id"].stringValue;
                                                        tmp.denomination = service["denomination"].stringValue;
                                                        tmp.price = service["price"].doubleValue;
                                                        tmp.img = service["img"].stringValue;
                                                        tmp.type = "service";
                                                        
                                                        Services.append(tmp);
                                                    }
                                                    self.Store.SaveCarsServs(Services);
                                                    print("Servicios: \(Services.count)");
                                                    
                                                    
                                                    
                                                    
                                                    
                                                    

                                                
                                                    let GETCORTESURL = String(self.ApiUrl + "/corte/last/" + self.LavadoSelected.id);
                                                    Alamofire.request(.GET, GETCORTESURL, headers: headers, encoding: .JSON).responseJSON { response in
                                                        print(response); 
                                                        switch response.result {
                                                        case .Success:
                                                            let data = JSON(data: response.data!);
                                                            if(data["success"] == true){
                                                                print(data);
                                                                var actualCorte = 0;
                                                                if(data["corte"]["corte_id"]) {
                                                                    actualCorte = data["corte"]["corte_id"].intValue + 1;
                                                                }
                                                                print("CORTE ACTUAL : \(actualCorte)");
                                                                self.Save.setInteger(actualCorte, forKey: "CorteActual");

                                                                CozyLoadingActivity.hide(success: true, animated: true);
                                                                self.dismissViewControllerAnimated(true, completion: nil);

                                                            }else{
                                                                if(data["message"] == "Corrupt Token."){
                                                                    CozyLoadingActivity.hide(success: false, animated: true)
                                                                }else{
                                                                    self.alerta("Error de Sesion", Mensaje: data["message"].stringValue );
                                                                    CozyLoadingActivity.hide(success: false, animated: true)
                                                                }
                                                            }
                                                        case .Failure:
                                                            CozyLoadingActivity.hide(success: false, animated: true)
                                                        }
                                                    }
                                                    
                                                    
                                                    
                                                    
                                                    
                                                }else{
                                                    if(data["message"] == "Corrupt Token."){
                                                        CozyLoadingActivity.hide(success: false, animated: true);
                                                    }else{
                                                        CozyLoadingActivity.hide(success: false, animated: false);
                                                        self.alerta("Error de Sesion", Mensaje: data["message"].stringValue );
                                                    }
                                                }
                                            case .Failure(let error):
                                                CozyLoadingActivity.hide(success: false, animated: false);
                                                self.alerta("Error", Mensaje: error.localizedDescription);
                                            }
                                        }
                                        
                                        
                                        
                                        
 
                                    }else{
                                        if(data["message"] == "Corrupt Token."){
                                            CozyLoadingActivity.hide(success: false, animated: true);
                                        }else{
                                            CozyLoadingActivity.hide(success: false, animated: false);
                                            self.alerta("Error de Sesion", Mensaje: data["message"].stringValue );
                                        }
                                    }
                                case .Failure(let error):
                                    CozyLoadingActivity.hide(success: false, animated: false);
                                    self.alerta("Error", Mensaje: error.localizedDescription);
                                }
                            }
    
                            
                            
                            
                            
                            
                        }else{
                            if(data["message"] == "Corrupt Token."){
                                CozyLoadingActivity.hide(success: false, animated: true);
                            }else{
                                CozyLoadingActivity.hide(success: false, animated: false);
                                self.alerta("Error de Sesion", Mensaje: data["message"].stringValue );
                            }
                        }
                    case .Failure(let error):
                        CozyLoadingActivity.hide(success: false, animated: false);
                        self.alerta("Error", Mensaje: error.localizedDescription);
                    }
                }
                
                
            case .Unknown, .Offline:
                CozyLoadingActivity.hide(success: false, animated: true);
                alerta("Error", Mensaje: "Favor de conectarse a internet.");
                break
            }
        }else{
            CozyLoadingActivity.hide(success: false, animated: true);
            alerta("Error", Mensaje: "Favor de seleccionar algun lavado");
        }
    }

    
    
    
    func KeyboardDidShow(){
        
        //añade el gesto del tap para esconder teclado:
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(FirstSetupViewController.DismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    func KeyboardDidHidden(){
        
        //quita los gestos para que no halla interferencia despues
        if let recognizers = self.view.gestureRecognizers {
            for recognizer in recognizers {
                self.view.removeGestureRecognizer(recognizer )
            }
        }
    }
    
    func DismissKeyboard(){
        UserName_TextField.resignFirstResponder();
        Password_TextField.resignFirstResponder();
    }
    
    func alerta(Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
}
