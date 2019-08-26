//
//  LoginViewController.swift
//  nun2x3
//
//  Created by Jose De Jesus Garfias Lopez on 31/01/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import AirshipKit
import SwiftSpinner

class LoginViewController: UIViewController,UITextFieldDelegate {

    let ApiUrl = VARS().getApiUrl();
    let Save = UserDefaults.standard;
    var channelID = UAirship.push().channelID;


    @IBOutlet weak var UsernameTextfield: UITextField!
    @IBOutlet weak var PasswordTextfield: UITextField!
    @IBOutlet weak var LoginView: UIView!
    @IBOutlet weak var LoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        LoginView.layer.shadowColor = UIColor.gray.cgColor;
        LoginView.layer.shadowOpacity = 0.5;
        LoginView.layer.shadowRadius = 2.0;
        LoginView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0);
        LoginView.layer.masksToBounds = false;
        
        // No border, no shadow, floatingPlaceholderEnabled
        UsernameTextfield.layer.borderColor = UIColor.clear.cgColor;
        UsernameTextfield.placeholder = "Nombre De Usuario";
        UsernameTextfield.tintColor = UIColor.orange;
        
        UsernameTextfield.delegate = self;
        
        
        // No border, no shadow, floatingPlaceholderEnabled
        PasswordTextfield.layer.borderColor = UIColor.clear.cgColor;
        PasswordTextfield.placeholder = "Contraseña";
        PasswordTextfield.tintColor = UIColor.orange;
        
        PasswordTextfield.delegate = self;
        
        LoginButton.layer.shadowOpacity = 0.55;
        LoginButton.layer.shadowRadius = 5.0;
        LoginButton.layer.shadowColor = UIColor.gray.cgColor;
        LoginButton.layer.shadowOffset = CGSize(width: 0, height: 2.5);
        
        
        //ACTIVAR NOTIFICACIONES DEL TECLADO:
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.KeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.KeyboardDidHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil);
    }
    
    @IBAction func DoLogin(_ sender: AnyObject) {

        self.channelID = UAirship.push().channelID;

        DismissKeyboard();
        SwiftSpinner.show("Autorizando");
        
        let AuthUrl = ApiUrl + "/authenticate";
        let status = Reach().connectionStatus();
        
        switch status {
        case .online(.wwan), .online(.wiFi):
            
            let DatatoSend: Parameters = [
                "username": self.UsernameTextfield.text as AnyObject!,
                "password": self.PasswordTextfield.text as AnyObject!,
            ];
            Alamofire.request(AuthUrl, method: .post, parameters: DatatoSend, encoding: JSONEncoding.default).responseJSON { response in
                if response.result.isSuccess {
                    let data = JSON(data: response.data!);
                    if(data["success"] == true){
                        
                        if(data["user"]["rol"].stringValue == "Administrador" || data["user"]["rol"].stringValue == "SuperAdministrador" ){
                            
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
                            SaveObj["lavado_id"] = "";
                            
                            self.Save.set(SaveObj, forKey: "UsuarioEnSesion")
                            self.Save.synchronize();
                            
                            SwiftSpinner
                                .hide();
                            
                            if let swreveal = self.presentingViewController as? SWRevealViewController {
                                if let menu = swreveal.rearViewController as? MenuTableViewController {
                                    menu.UsuarioEnSesion = Session();
                                }
                                if let navigation = swreveal.frontViewController as? MainNavViewController {
                                    if let State = navigation.viewControllers.first as? StateViewController{
                                        State.UsuarioEnSesion = Session();
                                        // State.goToCarwashes(self);
                                    }
                                }
                            }
                            
                            UAirship.push().tags = [data["user"]["rol"].stringValue, "Admin"];
                            UAirship.push().updateRegistration();
                            
                            if((self.channelID) != nil){
                                let PutUrl = self.ApiUrl + "/user/" + data["user"]["_id"].stringValue;
                                let headers: HTTPHeaders = [
                                    "Authorization": data["token"].stringValue
                                ];
                                let UserData: Parameters = [
                                    "push_id": self.channelID!
                                ];
                                
                                Alamofire.request(PutUrl, method: .put, parameters: UserData, encoding: JSONEncoding.default,headers: headers).responseJSON { response in
                                    if response.result.isSuccess {
                                        print("SETED");
                                    }else{
                                        print("EROR");
                                    }
                                }
                            }
                            
                            SocketIOManager.sharedInstance.establishConnection();
                            
                            self.dismiss(animated: true, completion: nil);
                        
                        }else{
                            SwiftSpinner.hide();
                            self.alerta("Error de Sesion", Mensaje: "No tienes permisos para acceder." );
                        
                        }
                        
                    }else{
                        SwiftSpinner.hide();
                        self.alerta("Error de Sesion", Mensaje: data["message"].stringValue );
                    }
                }else{
                    SwiftSpinner.hide();
                    self.alerta("Error", Mensaje: (response.result.error?.localizedDescription)!);
                }
            }
        case .unknown, .offline:
            SwiftSpinner.hide();
            self.alerta("Sin Conexion a internet", Mensaje: "Favor de conectarse a internet para acceder.");
            break
        }            //No internet connection;
    }
    
    
    func KeyboardDidShow(){
        
        //añade el gesto del tap para esconder teclado:
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.DismissKeyboard))
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
        UsernameTextfield.resignFirstResponder();
        PasswordTextfield.resignFirstResponder();
    }
    
    func alerta(_ Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent;
    }

}
