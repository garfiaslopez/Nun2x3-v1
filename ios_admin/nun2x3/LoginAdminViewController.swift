//
//  LoginAdminViewController.swift
//  nun2x3
//
//  Created by Jose De Jesus Garfias Lopez on 29/11/15.
//  Copyright © 2015 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import MaterialKit
import SwiftyJSON
import Alamofire


class LoginAdminViewController: UIViewController, UITextFieldDelegate{

    let ApiUrl = VARS().getApiUrl();
    let Format = Formatter();
    
    var UsuarioEnSesion:Session!;
    var LavadoEnSesion:LavadoSession!;
    
    var TicketSelected:Int? = nil;
    
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginAdminViewController.KeyboardDidShow), name: UIKeyboardDidShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginAdminViewController.KeyboardDidHidden), name: UIKeyboardWillHideNotification, object: nil);
        

    }
    
    override func viewDidAppear(animated: Bool) {
        
        
        
    }

    @IBAction func LoginAction(sender: AnyObject) {
        
        DismissKeyboard();

        if( self.UsernameTextfield.text != ""  && self.PasswordTextfield.text != ""){
            
            CozyLoadingActivity.show("Autorizando...", disableUI: true);
            let AuthUrl = ApiUrl + "/authenticate";
            print(AuthUrl);
            
            
            if let parent = self.presentingViewController?.presentingViewController as? MainViewController {
            
                if parent.Store.AuthAdmin(self.UsernameTextfield.text!, password: self.PasswordTextfield.text!) {
                    
                    {parent.PrinterIO.PrintTicket(parent.Tickets[self.TicketSelected!])} ~> {
                        
                        let status = Reach().connectionStatus();
                        
                        switch status {
                        case .Online(.WWAN), .Online(.WiFi):

                            let headers = [
                                "Authorization": self.UsuarioEnSesion.token
                            ]
                            let DELURL = String(self.ApiUrl + "/activeticket/" + self.LavadoEnSesion._id + "/byindex/" + String(self.TicketSelected!));
                            Alamofire.request(.DELETE, DELURL, headers: headers, encoding: .JSON).responseJSON { response in
                                let data = JSON(data: response.data!);
                                if(data["success"] == true){
                                    print("DELETED");
                                }
                            }
                        case .Unknown, .Offline:
                            break;
                        }  

                    
                    
                        CozyLoadingActivity.hide(success: true, animated: true);
                        parent.Tickets.removeAtIndex(self.TicketSelected!);
                        parent.CounterArray.removeAtIndex(self.TicketSelected!);
                        parent.Tickets_CollectionView.reloadData();
                        parent.dismissViewControllerAnimated(false, completion: nil);
                    }
                    
                }else{
                    CozyLoadingActivity.hide(success: false, animated: true);
                    self.alerta("Error", Mensaje: "No tienes los permisos Para esta operacion.");
                }
            
            }
        }else{
            self.alerta("Error", Mensaje: "Favor de rellenar los campos.");
        }
    }
    
    func KeyboardDidShow(){
        
        //añade el gesto del tap para esconder teclado:
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginAdminViewController.DismissKeyboard))
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
