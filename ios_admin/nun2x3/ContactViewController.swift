//
//  ContactViewController.swift
//  EnUn2x3
//
//  Created by Jose De Jesus Garfias Lopez on 27/08/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MaterialKit

class ContactViewController: UIViewController, UITextFieldDelegate {
    
    let TopScroll = 110;
    
    @IBOutlet weak var NameTextField: UITextField!
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var MessageTextView: UITextView!
    @IBOutlet weak var MainScrollView: UIScrollView!
    @IBOutlet weak var SendButton: UIButton!
    @IBOutlet weak var FormView: UIView!
    @IBOutlet weak var NavigationBar: UINavigationBar!

    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.NavigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Roboto-Regular", size: 25)!, NSForegroundColorAttributeName: UIColor.whiteColor()];

        
        //ACTIVAR NOTIFICACIONES DEL TECLADO:
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ContactViewController.KeyboardDidShow), name: UIKeyboardDidShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ContactViewController.KeyboardDidHidden), name: UIKeyboardWillHideNotification, object: nil);
        
        // No border, no shadow, floatingPlaceholderEnabled
        NameTextField.layer.borderColor = UIColor.clearColor().CGColor;
        NameTextField.placeholder = "Nombre Completo";
        NameTextField.tintColor = UIColor.MKColor.Orange;
        
        NameTextField.delegate = self;
        
        // No border, no shadow, floatingPlaceholderEnabled
        EmailTextField.layer.borderColor = UIColor.clearColor().CGColor;
        EmailTextField.placeholder = "Email";
        EmailTextField.tintColor = UIColor.MKColor.Orange;
        
        EmailTextField.delegate = self;
        
        
        SendButton.layer.shadowOpacity = 0.55;
        SendButton.layer.shadowRadius = 5.0;
        SendButton.layer.shadowColor = UIColor.grayColor().CGColor;
        SendButton.layer.shadowOffset = CGSize(width: 0, height: 2.5);
        
        
        // Do any additional setup after loading the view.
        FormView.layer.shadowColor = UIColor.grayColor().CGColor;
        FormView.layer.shadowOpacity = 0.5;
        FormView.layer.shadowRadius = 2.0;
        FormView.layer.shadowOffset = CGSizeMake(1.0, 1.0);
        FormView.layer.masksToBounds = false;
        
    }
    
    @IBAction func SendAction(sender: AnyObject) {
        
        if(self.NameTextField.text != "" && self.EmailTextField.text != "" && self.MessageTextView.text != ""){
            
            CozyLoadingActivity.show("Enviando..", disableUI: true);
            
            let Url = "https://api.mailgun.net/v3/sandbox0856417e82864fe39dae8388ce6555ca.mailgun.org/messages";
            let username = "api"
            let password = "key-ca4fefa7e85cc6529534a718d47d2359"
            let loginString = NSString(format: "%@:%@", username, password)
            let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
            let base64LoginString = loginData.base64EncodedStringWithOptions([])
            let headers = [
                "Authorization": "Basic \(base64LoginString)",
                "Content-Type": "application/x-www-form-urlencoded"
            ];
            let parameters = [
                "from": "\(self.NameTextField.text!)<\(self.EmailTextField.text!)>",
                "to": "AdminEnUn2x3<nun2x3@gmail.com>",
                "subject": "CONTACTO-IPAD-ADMIN-APP",
                "text": self.MessageTextView.text!
            ];
            let status = Reach().connectionStatus();
            
            switch status {
            case .Online(.WWAN), .Online(.WiFi):
                
                Alamofire.request(.POST, Url, parameters: parameters, headers: headers, encoding: .URLEncodedInURL).responseJSON {
                    response in
                    switch response.result {
                    case .Success:
                        self.doneEmail();
                    case .Failure(let error):
                        CozyLoadingActivity.hide(success: false, animated: true);
                        self.alerta("Error", Mensaje: error.localizedDescription);
                        print(error.localizedDescription)
                    }
                }
            case .Unknown, .Offline:
                CozyLoadingActivity.hide(success: false, animated: true);
                self.alerta("Sin Conexion a internet", Mensaje: "Favor de conectarse a internet para acceder.");
                break;
                
            }
        }else{
            self.alerta("Oops!", Mensaje: "Favor de llenar todos los campos.");
        }
        
    }
    func doneEmail(){
        CozyLoadingActivity.hide(success: true, animated: true);
        self.NameTextField.text = "";
        self.MessageTextView.text = "";
        self.EmailTextField.text = "";
        self.alerta("Perfecto", Mensaje: "Muchas gracias por escribirnos, te contactaremos lo antes posible.");
        
    }
    func KeyboardDidShow(){
        
        //añade el gesto del tap para esconder teclado:
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ContactViewController.DismissKeyboard))
        view.addGestureRecognizer(tap)
        
        self.MainScrollView.setContentOffset(CGPoint(x: 0, y: TopScroll), animated: true);
        
        
    }
    func KeyboardDidHidden(){
        
        //quita los gestos para que no halla interferencia despues
        if let recognizers = self.view.gestureRecognizers {
            for recognizer in recognizers {
                self.view.removeGestureRecognizer(recognizer )
            }
        }
        
        self.MainScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true);
        
    }
    
    func DismissKeyboard(){
        self.EmailTextField.resignFirstResponder();
        self.NameTextField.resignFirstResponder();
        self.MessageTextView.resignFirstResponder();
    }
    
    func alerta(Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.Alert);
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            print("Ok PRessed");
        }
        alertController.addAction(okAction);
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func CloseModal(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
}
