//
//  DetailModalViewController.swift
//  EnUn2x3
//
//  Created by Jose De Jesus Garfias Lopez on 25/08/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner


class DetailModalViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var NavigationBar: UINavigationBar!
    @IBOutlet weak var DetailTableView: UITableView!
    
    let ApiUrl = VARS().getApiUrl();
    let Format = Formatter();
    var UsuarioEnSesion:Session = Session();
    var DataArray:Array<BaseTemplate> = [];

    var entity = "";
    var titleNav = "Titulo";
    var corteActual = 0;
    var carwashID = "";
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        let nib = UINib(nibName: "DetailModalTableViewCell", bundle: nil);
        self.DetailTableView.register(nib, forCellReuseIdentifier: "CustomCell");
        
        self.reloadData();
        
        self.NavigationBar.topItem?.title = self.titleNav;
    }
    
    func reloadData(){
        SwiftSpinner.show("Cargando");
        let status = Reach().connectionStatus();
        
        switch status {
        case .online(.wwan), .online(.wiFi):
            
            let GETURL = String(ApiUrl + "/\(self.entity)/" + self.carwashID);
            let headers = [
                "Authorization": self.UsuarioEnSesion.token
            ];
            let DatatoSend = [
                "corte_id": String(self.corteActual)
            ];
            Alamofire.request(GETURL!, method: .post, parameters: DatatoSend, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                
                if response.result.isSuccess {
                    let data = JSON(data: response.data!);
                    
                    if(data["success"] == true){
                        SwiftSpinner.hide();
                        self.DataArray = [];
                        
                        for (_,baseData):(String,JSON) in data[self.entity]["docs"] {
                            
                            var tmp:BaseTemplate = BaseTemplate();
                            
                            tmp._id = baseData["_id"].stringValue;
                            tmp.denomination = baseData["denomination"].stringValue;
                            tmp.total = baseData["total"].doubleValue;
                            tmp.corte_id = baseData["corte_id"].stringValue;
                            tmp.date = baseData["date"].stringValue;
                            tmp.user = baseData["user"].stringValue;
                            
                            self.DataArray.append(tmp);
                        }
                        self.DetailTableView.reloadData();
                        
                    }else{
                        
                        if(data["message"] == "Corrupt Token."){
                            self.performSegue(withIdentifier: "LoginSegue", sender: self);
                        }else{
                            self.alerta("Error de Sesion", Mensaje: data["message"].stringValue );
                            print(data);
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

    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.DataArray.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:DetailModalTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! DetailModalTableViewCell;
        cell.denominationLabel.text = self.DataArray[(indexPath as NSIndexPath).row].denomination;
        cell.totalLabel.text = "$\(Format.Number.string(for: self.DataArray[indexPath.row].total)!)";
        
        return cell;
    }
    
    // MARK:  UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func alerta(_ Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func CloseModal(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil);
    }

}
