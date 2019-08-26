//
//  LoginCorteViewController.swift
//  nun2x3
//
//  Created by Jose De Jesus Garfias Lopez on 30/11/15.
//  Copyright © 2015 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import MaterialKit
import SwiftyJSON
import Alamofire

class LoginCorteViewController: UIViewController, UITextFieldDelegate{
    
    let Save = NSUserDefaults.standardUserDefaults();
    let ApiUrl = VARS().getApiUrl();
    let Format = Formatter();

    var UsuarioEnSesion:Session!;
    var LavadoEnSesion:LavadoSession!;
    
    var isCorteCompleto:Bool = false;
    
    
    @IBOutlet weak var LoginView: UIView!
    @IBOutlet weak var UsernameTextfield: UITextField!
    @IBOutlet weak var PasswordTextfield: UITextField!
    
    @IBOutlet weak var LoginButton: UIButton!
    @IBOutlet weak var CancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LoginView.layer.shadowColor = UIColor.grayColor().CGColor;
        LoginView.layer.shadowOpacity = 0.5;
        LoginView.layer.shadowRadius = 2.0;
        LoginView.layer.shadowOffset = CGSizeMake(1.0, 1.0);
        LoginView.layer.masksToBounds = false;
        
        // No border, no shadow, floatingPlaceholderEnabled
        UsernameTextfield.layer.borderColor = UIColor.clearColor().CGColor;
        UsernameTextfield.placeholder = "Nombre De Usuario";
        UsernameTextfield.tintColor = UIColor.MKColor.Orange;
        
        UsernameTextfield.delegate = self;
        
        // No border, no shadow, floatingPlaceholderEnabled
        PasswordTextfield.layer.borderColor = UIColor.clearColor().CGColor;
        PasswordTextfield.placeholder = "Contraseña";
        PasswordTextfield.tintColor = UIColor.MKColor.Orange;
        
        PasswordTextfield.delegate = self;
        
        LoginButton.layer.shadowOpacity = 0.55;
        LoginButton.layer.shadowRadius = 5.0;
        LoginButton.layer.shadowColor = UIColor.grayColor().CGColor;
        LoginButton.layer.shadowOffset = CGSize(width: 0, height: 2.5);
        
        CancelButton.layer.shadowOpacity = 0.55;
        CancelButton.layer.shadowRadius = 5.0;
        CancelButton.layer.shadowColor = UIColor.grayColor().CGColor;
        CancelButton.layer.shadowOffset = CGSize(width: 0, height: 2.5);
        
        
        //ACTIVAR NOTIFICACIONES DEL TECLADO:
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginCorteViewController.KeyboardDidShow), name: UIKeyboardDidShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginCorteViewController.KeyboardDidHidden), name: UIKeyboardWillHideNotification, object: nil);
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        
        
    }
    
    @IBAction func LoginAction(sender: AnyObject) {
        
        DismissKeyboard();
        CozyLoadingActivity.show("Autorizando...", disableUI: true);
        
        if( self.UsernameTextfield.text != ""  && self.PasswordTextfield.text != ""){
            if(self.UsernameTextfield.text == self.UsuarioEnSesion.username){
                self.makeCorte();
            }else{
                //FOR EMERGENCY!
                if(self.UsernameTextfield.text == "hacercorte" && self.PasswordTextfield.text == "12345"){
                    self.makeCorte();
                }else{
                    CozyLoadingActivity.hide(success: false, animated: true);
                    self.alerta("Error de Sesion", Mensaje: "Favor de loguearse el usuario activo." );
                }
            }
        }else{
            CozyLoadingActivity.hide(success: false, animated: true);
            self.alerta("Error", Mensaje: "Favor de rellenar los campos.");
        }
    }
    
    func makeCorte(){
        if let parent = self.presentingViewController?.presentingViewController as? MainViewController {
            if parent.Store.AuthUser(self.UsernameTextfield.text!, password: self.PasswordTextfield.text!) {
                if let subparent = self.presentingViewController as? UITabBarController {
                    for view in subparent.viewControllers!{
                        if let corte = view as? CorteViewController {
                            {corte.PrinterIO.PrintImage(corte.ImageCorte!)} ~> {
                                CozyLoadingActivity.hide(success: true, animated: true);
                                if(self.isCorteCompleto){
                                    
                                    self.Save.setObject("MakeCorteCompleto", forKey: "StatusApp");
                                    let status = Reach().connectionStatus();
                                    var saveCorteOnServer = false;
                                    switch status {
                                    case .Online(.WWAN), .Online(.WiFi):
                                        
                                        let POSTURL = String(self.ApiUrl + "/corte");
                                        let headers = [
                                            "Authorization": self.UsuarioEnSesion.token
                                        ]
                                        var DataToSend =  [String: AnyObject]();
                                        DataToSend["lavado_id"] = self.LavadoEnSesion._id;
                                        DataToSend["corte_id"] = self.UsuarioEnSesion.corte_id;
                                        DataToSend["user"] = self.UsuarioEnSesion.name;
                                        DataToSend["date"] = self.UsuarioEnSesion.date;
                                        
                                        Alamofire.request(.POST, POSTURL, headers: headers, parameters: DataToSend, encoding: .JSON).responseJSON { response in
                                            switch response.result {
                                            case .Success:
                                                let data = JSON(data: response.data!);
                                                if(data["success"] == true){
                                                    saveCorteOnServer = true;
                                                }else{
                                                    self.Save.setBool(true, forKey: "UploadBackupServer");
                                                }
                                            case .Failure( _):
                                                self.Save.setBool(true, forKey: "UploadBackupServer");
                                                break
                                            }
                                        }
                                        self.recoverUsers();
                                        SocketIOManager.sharedInstance.EmitNotification("MakeCorteCompleto");
                                    case .Unknown, .Offline:
                                        self.Save.setBool(true, forKey: "UploadBackupServer");
                                    }
                                    
                                    //SEND CORTE INSTANCE TO DB FOR SERVER KNOWS IN WHAT CORTENUMBER YOU ARE:
                                    let newCorte:CorteModel = CorteModel();
                                    newCorte.lavado_id = self.LavadoEnSesion._id;
                                    newCorte.corte_id = self.UsuarioEnSesion.corte_id;
                                    newCorte.user = self.UsuarioEnSesion.name;
                                    newCorte.date = self.Format.ParseMomentDate(self.UsuarioEnSesion.date);
                                    newCorte.savedOnServer = saveCorteOnServer;
                                    parent.Store.SaveCorte(newCorte);
                                }else{
                                    self.Save.setObject("MakeCorteIntermedio", forKey: "StatusApp");
                                    SocketIOManager.sharedInstance.EmitNotification("MakeCorteIntermedio");
                                }
                                parent.dismissViewControllerAnimated(false, completion: nil);
                            }
                        }
                    }
                }
            }else{
                CozyLoadingActivity.hide(success: false, animated: true);
                self.alerta("Error de Sesion", Mensaje: "Usuario o contraseña incorrectos." );
            }
        }
    }
    
    func recoverUsers(){
        let headers = [
            "Authorization": self.UsuarioEnSesion.token
        ]
        let UrlUsers = String(self.ApiUrl + "/users/withToken/" + self.LavadoEnSesion._id);
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
                    if let parent = self.presentingViewController?.presentingViewController as? MainViewController {
                        parent.Store.DeleteAllUsers()
                        parent.Store.SaveUsers(NewUsers);
                        print("Usuarios: \(NewUsers.count)");
                    };
                }else{
                    
                    if(data["message"] == "Corrupt Token."){
                        //CozyLoadingActivity.hide(success: false, animated: true);
                    }else{
                        //CozyLoadingActivity.hide(success: false, animated: false);
                        //self.alerta("Error de Sesion", Mensaje: data["message"].stringValue );
                    }
                }
            case .Failure:
                //CozyLoadingActivity.hide(success: false, animated: false);
                //self.alerta("Error", Mensaje: error.localizedDescription);
                break;
            }
        }
    }
    
    func KeyboardDidShow(){
        
        //añade el gesto del tap para esconder teclado:
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginCorteViewController.DismissKeyboard))
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
    
    @IBAction func CancelLogin(sender: AnyObject) {
        if let parent = self.presentingViewController?.presentingViewController as? MainViewController {
            parent.dismissViewControllerAnimated(false, completion: nil);
        }
    }
    
    func DismissKeyboard(){
        UsernameTextfield.resignFirstResponder();
        PasswordTextfield.resignFirstResponder();
    }
    
    func alerta(Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
}
