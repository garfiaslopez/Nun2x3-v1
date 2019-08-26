//
//  ViewController.swift
//  nun2x3
//
//  Created by Jose De Jesus Garfias Lopez on 21/10/15.
//  Copyright © 2015 Jose De Jesus Garfias Lopez. All rights reserved.
//
import UIKit
import MaterialKit
import SwiftyJSON
import Alamofire

class ViewController: UIViewController,UITextFieldDelegate {
    
    let Save = NSUserDefaults.standardUserDefaults();
    let ApiUrl = VARS().getApiUrl();
    var UsuarioSesion: NSDictionary!
    let Format = Formatter();
    let Store = StoreData();
    
    @IBOutlet weak var UserName_TextField: UITextField!
    @IBOutlet weak var Password_TextField: UITextField!
    @IBOutlet weak var Accept_Button: UIButton!
    @IBOutlet weak var Login_View: UIView!
    @IBOutlet weak var Loading_View: UIImageView!
    @IBOutlet weak var NavBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.KeyboardDidShow), name: UIKeyboardDidShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.KeyboardDidHidden), name: UIKeyboardWillHideNotification, object: nil);
        
        var ImagesForAnimation: [UIImage] = [];
        
        for i in 1...21 {
            ImagesForAnimation.append(UIImage(named:"Loading_\(i).png")!);
        }
        Loading_View.animationImages = ImagesForAnimation;
        Loading_View.animationDuration = 1.0;
        
    }
    override func viewDidAppear(animated: Bool) {
        
        if(Save.objectForKey("LavadoEnSesion") == nil){
            self.performSegueWithIdentifier("FirstSetupSegue", sender: self);
        }else{
            let lavado = Save.objectForKey("LavadoEnSesion");
            
            if let C:AnyObject = lavado!.valueForKey("id"){
                let id = String(C);
                print(id);
            }
            if let K:AnyObject = lavado!.valueForKey("name"){
                let name = String(K);
                print(name);
            }
        }
        
    }
    
    
    
    @IBAction func DoLogin(sender: AnyObject) {
        
        Loading_View.startAnimating();
        let AuthUrl = ApiUrl + "/authenticate";
        
        dispatch_async(dispatch_get_main_queue()) {
            
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
                            
                            //save the user and dissmiss the view
                            var SaveObj = [String : String]();
                            
                            SaveObj["token"] = data["token"].stringValue;
                            SaveObj["_id"] = data["user"]["_id"].stringValue;
                            SaveObj["username"] = data["user"]["username"].stringValue;
                            SaveObj["password"] = data["user"]["password"].stringValue;
                            SaveObj["address"] = data["user"]["info"]["address"].stringValue;
                            SaveObj["phone"] = data["user"]["info"]["phone"].stringValue;
                            SaveObj["name"] = data["user"]["info"]["name"].stringValue;
                            SaveObj["rol"] = data["user"]["rol"].stringValue;

                            //CHECK IF YOU HAVE A PREVIUS SESSION AND IF YOU GONNA MAKE A CORTE INTERMEDIO O COMPLETO FOR THE DATE:
                            
                            if let status = self.Save.stringForKey("StatusApp") {
                                if(status == "RecoverCorteIntermedio"){
                                    if let parent = self.presentingViewController as? MainViewController {
                                        SaveObj["date"] = parent.UsuarioEnSesion.date;
                                    }else{
                                    }
                                }else if(status == "Normal"){
                                    if let parent = self.presentingViewController as? MainViewController {
                                        SaveObj["date"] = parent.UsuarioEnSesion.date;
                                    }else{
                                    }
                                    self.Save.setObject("RecoverCorteCompleto", forKey: "StatusApp");
                                }else{
                                    SaveObj["date"] = self.Format.Today().forServer;
                                }
                            }else{
                                SaveObj["date"] = self.Format.Today().forServer;
                            }
                            
                            SaveObj["startDate"] = self.Format.LocalDate.stringFromDate(NSDate());    // APERTURA DATE
                            
                            let corteBefore = self.Save.integerForKey("CorteActual");
                            print("Corte actual \(corteBefore)");
                            SaveObj["corte_id"] = String(corteBefore);
                            
                            self.Save.setObject(SaveObj, forKey: "UsuarioEnSesion")
                            self.Save.synchronize();
                            
                            if let parent = self.presentingViewController as? MainViewController {
                                
                                //nuevos valores para la sesionACtual
                                parent.UsuarioEnSesion = Session();
                                parent.LavadoEnSesion = LavadoSession();
                                
                                //nuevos valores para la clase "IMPRESORA"
                                parent.PrinterIO.UsuarioEnSesion = Session();
                                parent.PrinterIO.LavadoEnSesion = LavadoSession();
                                
                                // nuevos valores para el StoreData
                                parent.Store.UsuarioEnSesion = Session();
                                parent.Store.LavadoEnSesion = LavadoSession();
                            }
                            
                            self.dismissViewControllerAnimated(true, completion: nil);
                            
                            SocketIOManager.sharedInstance.establishConnection();

                            
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
                //No internet connection:
                
                if self.Store.AuthUser(self.UserName_TextField.text!, password: self.Password_TextField.text!) {
                    var SaveObj = [String : String]();
                    if let user = self.Store.UserInSesion {
                        SaveObj["token"] = user.token;
                        SaveObj["_id"] = user._id;
                        SaveObj["username"] = user.username;
                        SaveObj["password"] = user.password;
                        SaveObj["name"] = user.name;
                        SaveObj["rol"] = user.rol;
                        
                        
                        //CHECK IF YOU HAVE A PREVIUS SESSION AND IF YOU GONNA MAKE A CORTE INTERMEDIO O COMPLETO FOR THE DATE:
                        
                        if let status = self.Save.stringForKey("StatusApp") {
                            if(status == "RecoverCorteIntermedio"){
                                if let parent = self.presentingViewController as? MainViewController {
                                    SaveObj["date"] = parent.UsuarioEnSesion.date;
                                }else{
                                }
                            }else if(status == "Normal"){
                                if let parent = self.presentingViewController as? MainViewController {
                                    SaveObj["date"] = parent.UsuarioEnSesion.date;
                                }else{
                                }
                                self.Save.setObject("RecoverCorteCompleto", forKey: "StatusApp");
                            }else{
                                SaveObj["date"] = self.Format.Today().forServer;
                            }
                        }else{
                            SaveObj["date"] = self.Format.Today().forServer;
                        }                        
                        
                        SaveObj["startDate"] = self.Format.LocalDate.stringFromDate(NSDate());    // APERTURA DATE
                        
                        let corteBefore = self.Save.integerForKey("CorteActual");
                        SaveObj["corte_id"] = String(corteBefore);
                        
                        self.Save.setObject(SaveObj, forKey: "UsuarioEnSesion")
                        self.Save.synchronize();
                        
                        if let parent = self.presentingViewController as? MainViewController {
                            
                            //nuevos valores para la sesionACtual
                            parent.UsuarioEnSesion = Session();
                            parent.LavadoEnSesion = LavadoSession();
                            
                            //nuevos valores para la clase "IMPRESORA"
                            parent.PrinterIO.UsuarioEnSesion = Session();
                            parent.PrinterIO.LavadoEnSesion = LavadoSession();
                            
                            // nuevos valores para el StoreData
                            parent.Store.UsuarioEnSesion = Session();
                            parent.Store.LavadoEnSesion = LavadoSession();
                            
                        }
                        
                        self.Loading_View.stopAnimating();
                        self.dismissViewControllerAnimated(true, completion: nil);
                        
                    }else{
                        self.alerta("Error de Sesion", Mensaje: "Error Recuperando Usuario." );
                        self.Loading_View.stopAnimating();
                    }
                }else{
                    self.alerta("Error de Sesion", Mensaje: "Usuario o Contraseña incorrectos." );
                    self.Loading_View.stopAnimating();
                }
            }
        }
    }
    
    
    func KeyboardDidShow(){
        
        //añade el gesto del tap para esconder teclado:
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.DismissKeyboard))
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

