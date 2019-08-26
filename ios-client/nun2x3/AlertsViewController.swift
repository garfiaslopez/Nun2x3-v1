//
//  AlertsViewController.swift
//  nun2x3
//
//  Created by Jose De Jesus Garfias Lopez on 01/02/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import Alamofire
import SwiftyJSON
import SwiftSpinner

class AlertsViewController: UIViewController,UITextFieldDelegate {
    
    let DELEGATE = UIApplication.shared.delegate as! AppDelegate
    let ApiUrl = VARS().getApiUrl();
    let Format = Formatter();

    var UsuarioEnSesion:Session = Session();
    var Carwashes:Array<CarwashTemplate> = [];
    var CarwashesNames:Array<String> = [];
    var CarwashSelected:CarwashTemplate!;

    @IBOutlet weak var MenuButton: UIBarButtonItem!
    @IBOutlet weak var TitleTextField: UITextField!
    @IBOutlet weak var CarwashTextField: UITextField!
    @IBOutlet weak var MessageTextarea: UITextView!
    @IBOutlet weak var SendButton: UIButton!
    @IBOutlet weak var TextAreaView: UIView!
    @IBOutlet weak var CarwashStatusImage: UIImageView!
    @IBOutlet weak var CarwashNameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TitleTextField.layer.borderColor = UIColor.clear.cgColor;
        TitleTextField.tintColor = UIColor.orange;

        SendButton.layer.shadowOpacity = 0.55;
        SendButton.layer.shadowRadius = 5.0;
        SendButton.layer.shadowColor = UIColor.gray.cgColor;
        SendButton.layer.shadowOffset = CGSize(width: 0, height: 2.5);
        
        TextAreaView.layer.shadowOpacity = 0.55;
        TextAreaView.layer.shadowRadius = 5.0;
        TextAreaView.layer.shadowColor = UIColor.gray.cgColor;
        TextAreaView.layer.shadowOffset = CGSize(width: 0, height: 2.5);
        TextAreaView.layer.borderColor = UIColor.orange.cgColor;
        
        if revealViewController() != nil {
            MenuButton.target = revealViewController()
            MenuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        //ACTIVAR NOTIFICACIONES DEL TECLADO:
        NotificationCenter.default.addObserver(self, selector: #selector(AlertsViewController.KeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(AlertsViewController.KeyboardDidHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil);
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.UsuarioEnSesion = Session();
        self.CarwashSelected = CarwashTemplate();
        
        if(self.UsuarioEnSesion.token == "" && self.UsuarioEnSesion.username == ""){
            self.performSegue(withIdentifier: "LoginSegue", sender: self);
        }
        
        if self.CarwashSelected.name == "" {
            self.performSegue(withIdentifier: "CarwashSegue", sender: self);
        }
        
        // UI FOR CARWASH:
        self.CarwashNameLabel.text = self.CarwashSelected.name;
        if self.CarwashSelected.status {
            self.CarwashStatusImage.image = UIImage(named: "Online.png");
        }else{
            self.CarwashStatusImage.image = UIImage(named: "Offline.png");
        }
        
    }
    

    func KeyboardDidShow(){
        
        //añade el gesto del tap para esconder teclado:
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AlertsViewController.DismissKeyboard))
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
        self.TitleTextField.resignFirstResponder();
        self.MessageTextarea.resignFirstResponder();
    }
    
    
    @IBAction func SendMessage(_ sender: AnyObject) {
        SocketIOManager.sharedInstance.SendMessageToIpad(self.TitleTextField.text!, msg: self.MessageTextarea.text!, carwash_id: self.CarwashSelected._id);
        self.DismissKeyboard();
        self.TitleTextField.text = "";
        self.MessageTextarea.text = "";
        self.alerta("Exito", Mensaje: "Mensaje Enviado.");
    }

    func alerta(_ Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
}
