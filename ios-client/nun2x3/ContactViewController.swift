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
import SwiftSpinner


class ContactViewController: UIViewController, UITextFieldDelegate {

    let TopScroll = 110;
    
    @IBOutlet weak var NameTextField: UITextField!
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var MessageTextView: UITextView!
    @IBOutlet weak var MainScrollView: UIScrollView!
    @IBOutlet weak var SendButton: UIButton!
    @IBOutlet weak var FormView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //ACTIVAR NOTIFICACIONES DEL TECLADO:
        NotificationCenter.default.addObserver(self, selector: #selector(ContactViewController.KeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(ContactViewController.KeyboardDidHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil);
        
        // No border, no shadow, floatingPlaceholderEnabled
        NameTextField.layer.borderColor = UIColor.clear.cgColor;
        NameTextField.placeholder = "Nombre Completo";
        NameTextField.tintColor = UIColor.orange;
        
        NameTextField.delegate = self;
        
        // No border, no shadow, floatingPlaceholderEnabled
        EmailTextField.layer.borderColor = UIColor.clear.cgColor;
        EmailTextField.placeholder = "Email";
        EmailTextField.tintColor = UIColor.orange;
        
        EmailTextField.delegate = self;
        
        
        SendButton.layer.shadowOpacity = 0.55;
        SendButton.layer.shadowRadius = 5.0;
        SendButton.layer.shadowColor = UIColor.gray.cgColor;
        SendButton.layer.shadowOffset = CGSize(width: 0, height: 2.5);
        
        
        // Do any additional setup after loading the view.
        FormView.layer.shadowColor = UIColor.gray.cgColor;
        FormView.layer.shadowOpacity = 0.5;
        FormView.layer.shadowRadius = 2.0;
        FormView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0);
        FormView.layer.masksToBounds = false;
        
    }

    @IBAction func SendAction(_ sender: AnyObject) {
        
        if(self.NameTextField.text != "" && self.EmailTextField.text != "" && self.MessageTextView.text != ""){
            
            SwiftSpinner.show("Enviando");
            
            let Url = "https://api.mailgun.net/v3/sandbox0856417e82864fe39dae8388ce6555ca.mailgun.org/messages";
            let username = "api"
            let password = "key-ca4fefa7e85cc6529534a718d47d2359"
            let loginString = NSString(format: "%@:%@", username, password)
            let loginData: Data = loginString.data(using: String.Encoding.utf8.rawValue)!
            let base64LoginString = loginData.base64EncodedString(options: [])
            let headers = [
                "Authorization": "Basic \(base64LoginString)",
                "Content-Type": "application/x-www-form-urlencoded"
            ];
            let parameters = [
                "from": "\(self.NameTextField.text!)<\(self.EmailTextField.text!)>",
                "to": "AdminEnUn2x3<nun2x3@gmail.com>",
                "subject": "CONTACTO-IPHONE-CLIENT-APP",
                "text": self.MessageTextView.text!
            ];
            let status = Reach().connectionStatus();
            
            switch status {
            case .online(.wwan), .online(.wiFi):
                
                Alamofire.request(Url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON {
                    response in
                    if response.result.isSuccess {
                        self.doneEmail();
                    }else{
                        SwiftSpinner.hide();
                        self.alerta("Error", Mensaje: (response.result.error?.localizedDescription)!);
                    }
                }
            case .offline:
                SwiftSpinner.hide();
                self.alerta("Sin Conexion a internet", Mensaje: "Favor de conectarse a internet para acceder.");
                break;
            default:
                break;
            }
        }else{
            self.alerta("Oops!", Mensaje: "Favor de llenar todos los campos.");
        }
        
    }
    func doneEmail(){
        SwiftSpinner.hide();
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
    
    func alerta(_ Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.alert);
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            print("Ok PRessed");
        }
        alertController.addAction(okAction);
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func CloseModal(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil);
    }

}
