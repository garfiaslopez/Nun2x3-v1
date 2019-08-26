//
//  CarwashesViewController.swift
//  EnUn2x3
//
//  Created by Jose De Jesus Garfias Lopez on 24/08/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner


class CarwashesViewController: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    let DELEGATE = UIApplication.shared.delegate as! AppDelegate
    let ApiUrl = VARS().getApiUrl();
    let Format = Formatter();
    var UsuarioEnSesion:Session = Session();
    let Save = UserDefaults.standard;

    var DataArray:Array<DashboardTemplate> = [];
    var Carwashes:Array<CarwashTemplate> = [];
    var CarwashesNames:Array<String> = [];
    var CarwashSelected:CarwashTemplate!;
    var Refresh:UIRefreshControl!;
    
    @IBOutlet weak var CarwashesCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        let nib = UINib(nibName: "CarwashCollectionViewCell", bundle: nil);
        self.CarwashesCollection.register(nib, forCellWithReuseIdentifier: "CustomCell");
        
        Refresh = UIRefreshControl();
        Refresh.tintColor = UIColor.white;
        Refresh.addTarget(self, action: #selector(CarwashesViewController.ReloadData), for: UIControlEvents.valueChanged);
        self.CarwashesCollection.addSubview(Refresh);
        
        self.ReloadData();
    }
    func ReloadData(){

        SwiftSpinner.show("Cargando");
        let status = Reach().connectionStatus();
        switch status {
        case .online(.wwan), .online(.wiFi):
            
            let GETURL = String(ApiUrl + "/carwashes/" + self.UsuarioEnSesion._id);
            let headers = [
                "Authorization": self.UsuarioEnSesion.token
            ]
            Alamofire.request(GETURL!, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                
                if response.result.isSuccess {
                    let data = JSON(data: response.data!);
                    if(data["success"] == true){
                        SwiftSpinner.hide();
                        self.Carwashes = [];
                        self.CarwashesNames = [];
                        for (_,carwash):(String,JSON) in data["carwashes"] {
                            
                            var tmp:CarwashTemplate = CarwashTemplate();
                            
                            tmp._id = carwash["_id"].stringValue;
                            tmp.name = carwash["info"]["name"].stringValue;
                            tmp.phone = carwash["info"]["phone"].stringValue;
                            tmp.address = carwash["info"]["address"].stringValue;
                            tmp.status = carwash["status"].boolValue;
                            
                            self.CarwashesNames.append(tmp.name);
                            self.Carwashes.append(tmp);
                        }
                        
                        self.CarwashesCollection.reloadData();
                    }else{
                        if(data["message"] == "Corrupt Token."){
                            print("CORRUPT TOKEN");
                        } else {
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
            self.CarwashesCollection.contentOffset = CGPoint(x: 0, y: -self.Refresh.frame.size.height);
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.Carwashes.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width / 2) , height: (collectionView.frame.width / 2));
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell:CarwashCollectionViewCell;
        
        cell = self.CarwashesCollection.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CarwashCollectionViewCell;
        cell.layer.borderColor = UIColor.white.cgColor;
        cell.layer.borderWidth = 2.0;
        
        
        cell.denominationLabel.text = self.Carwashes[(indexPath as NSIndexPath).row].name;
        
        return cell;
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.CarwashSelected = self.Carwashes[(indexPath as NSIndexPath).row];
        let carwash = [
            "name": self.CarwashSelected.name,
            "_id": self.CarwashSelected._id,
            "address": self.CarwashSelected.address,
            "phone": self.CarwashSelected.phone,
            "status": self.CarwashSelected.status
            ] as [String : Any]
        self.Save.set(carwash, forKey: "LastCarwash");
        self.Save.synchronize();
        self.dismiss(animated: false, completion: nil);
    }
    
    @IBAction func CloseModal(_ sender: Any) {
        self.dismiss(animated: false, completion: nil);
    }
    
    func alerta(_ Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
