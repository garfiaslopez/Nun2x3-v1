//
//  UsersViewController.swift
//  nun2x3
//
//  Created by Jose De Jesus Garfias Lopez on 01/02/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner

class UsersViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    let ApiUrl = VARS().getApiUrl();
    let Format = Formatter();

    var UsuarioEnSesion:Session = Session();
    var Refresh:UIRefreshControl!;
    var UsersArray:Array<UserTemplate> = [];

    @IBOutlet weak var MenuButton: UIBarButtonItem!
    @IBOutlet weak var UsersList: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "UserTableViewCell", bundle: nil);
        self.UsersList.register(nib, forCellReuseIdentifier: "CustomCell");

        if revealViewController() != nil {
            MenuButton.target = revealViewController()
            MenuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        Refresh = UIRefreshControl();
        Refresh.tintColor = UIColor.orange;
        Refresh.addTarget(self, action: #selector(UsersViewController.ReloadData), for: UIControlEvents.valueChanged);
        self.UsersList.addSubview(Refresh);
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(self.UsuarioEnSesion.token == "" && self.UsuarioEnSesion.username == ""){
            self.performSegue(withIdentifier: "LoginSegue", sender: self);
        }else{
            self.ReloadData();
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.UsersArray.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UserTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! UserTableViewCell;
        
        cell.nameLabel.text = self.UsersArray[(indexPath as NSIndexPath).row].name;
        cell.rolLabel.text = self.UsersArray[(indexPath as NSIndexPath).row].rol;
        
        var LavadoString = "";
        for lavado in self.UsersArray[(indexPath as NSIndexPath).row].lavado_id {
            LavadoString = LavadoString + lavado + " ,";
        }
        
        cell.carwashesLabel.text = LavadoString;
        
        return cell;
    }
    
    // MARK:  UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.UsersList.deselectRow(at: indexPath, animated: true);
        let phoneNumber: String = "telprompt://" + self.UsersArray[(indexPath as NSIndexPath).row].phone;
        UIApplication.shared.openURL(URL(string:phoneNumber)!);
    }


    func alerta(_ Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func ReloadData(){
        SwiftSpinner.show("Cargando");
        let status = Reach().connectionStatus();
        
        switch status {
        case .online(.wwan), .online(.wiFi):
            
            let GETURL = String(ApiUrl + "/users/byAccount/" + self.UsuarioEnSesion._id);
            let headers = [
                "Authorization": self.UsuarioEnSesion.token
            ]
            Alamofire.request(GETURL!, encoding: JSONEncoding.default,headers: headers).responseJSON { response in
                
                if response.result.isSuccess {
                    
                    let data = JSON(data: response.data!);
                    if(data["success"] == true){
                        SwiftSpinner.hide();
                        
                        self.UsersArray = [];
                        
                        for (_,user):(String,JSON) in data["users"] {
                            
                            var tmp:UserTemplate = UserTemplate();
                            
                            tmp.name = user["info"]["name"].stringValue;
                            tmp.phone = user["info"]["phone"].stringValue;
                            tmp.username = user["username"].stringValue;
                            tmp.password = user["password"].stringValue;
                            tmp.rol = user["rol"].stringValue;
                            
                            for (_,lavado):(String,JSON) in user["lavado_id"] {
                                tmp.lavado_id.append(lavado.stringValue);
                            }
                            
                            self.UsersArray.append(tmp);
                        }
                        self.UsersList.reloadData();
                        
                    }else{
                        
                        if(data["message"] == "Corrupt Token."){
                            self.performSegue(withIdentifier: "LoginSegue", sender: self);
                        }else{
                            self.alerta("Error de Sesion", Mensaje: data["message"].stringValue );
                            SwiftSpinner.hide();
                        }
                    }
                }else{
                    SwiftSpinner.hide();
                }
            }
            
        case .unknown, .offline:
            SwiftSpinner.hide();
            self.alerta("Sin Conexion", Mensaje: "Favor de conectarse a internet.");
        }
        
        if(self.Refresh.isRefreshing){
            self.Refresh.endRefreshing();
            self.UsersList.contentOffset = CGPoint(x: 0, y: -self.Refresh.frame.size.height);
        }
    }
    
    
}
