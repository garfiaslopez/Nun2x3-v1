//
//  PendingsViewController.swift
//  EnUn2x3
//
//  Created by Jose De Jesus Garfias Lopez on 27/08/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import ActionSheetPicker_3_0
import SwiftSpinner

class PendingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let ApiUrl = VARS().getApiUrl();
    let Format = Formatter();
    
    var UsuarioEnSesion:Session = Session();
    var Refresh:UIRefreshControl!;
    var PendingsArray:Array<PendingTemplate> = [];
    var Carwashes:Array<CarwashTemplate> = [];
    var CarwashesNames:Array<String> = [];
    var CarwashSelected:CarwashTemplate!;
    
    @IBOutlet weak var CarwashStatusImage: UIImageView!
    @IBOutlet weak var CarwashNameLabel: UILabel!
    @IBOutlet weak var MenuButton: UIBarButtonItem!
    @IBOutlet weak var PendingList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "PendingTableViewCell", bundle: nil);
        self.PendingList.register(nib, forCellReuseIdentifier: "CustomCell");
        
        if revealViewController() != nil {
            MenuButton.target = revealViewController()
            MenuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        Refresh = UIRefreshControl();
        Refresh.tintColor = UIColor.orange;
        Refresh.addTarget(self, action: #selector(UsersViewController.ReloadData), for: UIControlEvents.valueChanged);
        self.PendingList.addSubview(Refresh);
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.UsuarioEnSesion = Session();
        self.CarwashSelected = CarwashTemplate();
        
        if(self.UsuarioEnSesion.token == "" && self.UsuarioEnSesion.username == ""){
            self.performSegue(withIdentifier: "LoginSegue", sender: self);
        }else{
            self.ReloadData();
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
        
    func ReloadData(){
        SwiftSpinner.show("Cargando");
        let status = Reach().connectionStatus();
        
        switch status {
        case .online(.wwan), .online(.wiFi):
            
            let GETURL = String(ApiUrl + "/pendings/" + self.CarwashSelected._id);
            let headers = [
                "Authorization": self.UsuarioEnSesion.token
            ]
            Alamofire.request(GETURL!, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                
                if response.result.isSuccess {
                    let data = JSON(data: response.data!);
                    if(data["success"] == true){
                        print(data);
                        SwiftSpinner.hide();
                        self.PendingsArray = [];
                        
                        for (_,pending):(String,JSON) in data["pendings"] {
                            
                            var tmp:PendingTemplate = PendingTemplate();
                            
                            tmp.denomination = pending["denomination"].stringValue;
                            tmp.date = pending["date"].stringValue;
                            tmp._id = pending["_id"].stringValue;
                            tmp.corte_id = pending["corte_id"].stringValue;
                            tmp.user = pending["user"].stringValue;
                            
                            self.PendingsArray.append(tmp);
                        }
                        self.PendingList.reloadData();
                        
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
            self.PendingList.contentOffset = CGPoint(x: 0, y: -self.Refresh.frame.size.height);
        }
    
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.PendingsArray.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:PendingTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! PendingTableViewCell;
        
        let date = Format.ParseMomentDate(self.PendingsArray[(indexPath as NSIndexPath).row].date);
        cell.dateLabel.text = Format.DatePretty.string(from: date);
        cell.userLabel.text = self.PendingsArray[(indexPath as NSIndexPath).row].user;
        cell.descriptionLabel.text = self.PendingsArray[(indexPath as NSIndexPath).row].denomination;
        
        return cell;
    }
    
    // MARK:  UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let date = Format.ParseMomentDate(self.PendingsArray[(indexPath as NSIndexPath).row].date);
        self.alerta(Format.DatePretty.string(from: date), Mensaje: self.PendingsArray[(indexPath as NSIndexPath).row].denomination);
    }
    
    func alerta(_ Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    

}
