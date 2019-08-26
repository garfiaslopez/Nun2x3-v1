//
//  ViewController.swift
//  nun2x3
//
//  Created by Jose De Jesus Garfias Lopez on 21/01/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import Alamofire
import SwiftyJSON
import SwiftSpinner



class DashboardViewController: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    let DELEGATE = UIApplication.shared.delegate as! AppDelegate
    let ApiUrl = VARS().getApiUrl();
    let Format = Formatter();
    var UsuarioEnSesion:Session = Session();
    let Save = UserDefaults.standard;

    var DataArray:Array<DashboardTemplate> = [];
    var CarwashSelected:CarwashTemplate!;
    var Refresh:UIRefreshControl!;
    var actualCorte = 0;
    var selectedModel = 0;
    
    @IBOutlet weak var DashboardCollection: UICollectionView!
    @IBOutlet weak var CarwashStatusImage: UIImageView!
    @IBOutlet weak var CarwashNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "DashboardCollectionViewCell", bundle: nil);
        self.DashboardCollection.register(nib, forCellWithReuseIdentifier: "CustomCell");
        
        
        Refresh = UIRefreshControl();
        Refresh.tintColor = UIColor.white;
        Refresh.addTarget(self, action: #selector(DashboardViewController.ReloadDashBoardData), for: UIControlEvents.valueChanged);
        self.DashboardCollection.addSubview(Refresh);

        
        let colors = [  UIColor(red: 62/255, green: 153/255, blue: 237/255, alpha: 1),
                        UIColor(red: 64/255, green: 84/255, blue: 178/255, alpha: 1),
                        UIColor(red: 53/255, green: 160/255, blue: 78/255, alpha: 1),
                        UIColor(red: 103/255, green: 63/255, blue: 180/255, alpha: 1),
                        UIColor(red: 244/255, green: 56/255, blue: 62/255, alpha: 1),
                        UIColor(red: 252/255, green: 107/255, blue: 71/255, alpha: 1),
                        UIColor(red: 0/255, green: 150/255, blue: 136/255, alpha: 1),
                    ];
        let categories = ["Tickets","Activos","Total", "Autos", "Gastos", "Ingresos", "Vales"];
        let entities = ["tickets","active","total", "cars", "spends", "ingresses", "paybills"];
        
        
        for index in 0...categories.count - 1 {
            var ticketsDash = DashboardTemplate();
            ticketsDash.description = categories[index];
            ticketsDash.entity = entities[index];
            ticketsDash.color = colors[index];
            ticketsDash.icon = categories[index] + ".png";
            self.DataArray.append(ticketsDash);
        }
    
        
        // UI FOR CARWASH:
        self.CarwashNameLabel.text = self.CarwashSelected.name;
        if self.CarwashSelected.status {
            self.CarwashStatusImage.image = UIImage(named: "Online.png");
        }else{
            self.CarwashStatusImage.image = UIImage(named: "Offline.png");
        }
        
        // RELOAD DASHBOARD:
        self.ReloadDashBoardData();
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let carwash = [
            "name": self.CarwashSelected.name,
            "_id": self.CarwashSelected._id,
            "address": self.CarwashSelected.address,
            "phone": self.CarwashSelected.phone,
            "status": self.CarwashSelected.status
        ] as [String : Any]
        self.Save.set(carwash, forKey: "LastCarwash");
        self.Save.synchronize();
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.Save.set(nil, forKey: "LastCarwash");
        self.Save.synchronize();
    }
    
    func ReloadActiveTickets(){
        let status = Reach().connectionStatus();
        switch status {
        case .online(.wwan), .online(.wiFi):
            let GETURL = String(ApiUrl + "/activetickets/" + self.CarwashSelected._id);
            let headers = [
                "Authorization": self.UsuarioEnSesion.token
            ]
            Alamofire.request(GETURL!, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                
                if response.result.isSuccess {
                    let data = JSON(data: response.data!);
                    if(data["success"] == true){
                        let count = data["activetickets"].count;
                        self.DataArray[1].count = "#\(count)";
                        self.DashboardCollection.reloadData();
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
    }
    
    func ReloadDashBoardData(){
        //RELOAD THE INFO TO DISPLAY IN DASHBOARD:
        SwiftSpinner.show("Actualizando dashboard");
        //GET THE LAST CORTE:
        self.ReloadActiveTickets();
        
        let GETURL = String(ApiUrl + "/corte/last/" + self.CarwashSelected._id);
        let headers = [
            "Authorization": self.UsuarioEnSesion.token
        ]
        Alamofire.request(GETURL!, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if response.result.isSuccess{
                
                let data = JSON(data: response.data!);
                if(data["success"] == true){
                    self.actualCorte = data["corte"]["corte_id"].intValue + 1;
                    let POSTURL = String(self.ApiUrl + "/dashboard/" + self.CarwashSelected._id);
                    let DatatoSend: Parameters = [
                        "corte_id": String(self.actualCorte)
                    ];
                    Alamofire.request(POSTURL!, method: .post, parameters: DatatoSend, encoding: JSONEncoding.default, headers: headers).responseJSON { response in

                        if response.result.isSuccess {
                            let data = JSON(data: response.data!);
                            if(data["success"] == true){
                                
                                //STORE LOCALLY WITH TRUE FLAG ON SERVERSAVED:
                                let tickets = data["tickets"]["total"].doubleValue;
                                let spends = data["spends"]["total"].doubleValue;
                                let paybills = data["paybills"]["total"].doubleValue;
                                let ingresses = data["ingresses"]["total"].doubleValue;
                                
                                
                                let ticketsCount = data["tickets"]["count"].intValue;
                                let spendsCount = data["spends"]["count"].intValue;
                                let paybillsCount = data["paybills"]["count"].intValue;
                                let ingressesCount = data["ingresses"]["count"].intValue;
                                
                                let total = tickets + ingresses - spends;
                                
                                for index in 0...self.DataArray.count - 1 {
                                    if(index == 0){
                                        self.DataArray[index].icon = "Ticket.png"
                                        self.DataArray[index].count = "#\(ticketsCount)";
                                        self.DataArray[index].total = "";
                                    }else if(index == 1){
                                        self.DataArray[index].icon = "CarActive.png"
                                        self.DataArray[index].total = "";
                                    }else if(index == 2){
                                        self.DataArray[index].icon = "Total.png"
                                        self.DataArray[index].count = "";
                                        self.DataArray[index].total = "$\(self.Format.Number.string(from: NSNumber(value: total))!)";
                                    }else if(index == 3){
                                        self.DataArray[index].icon = "Cars.png"
                                        self.DataArray[index].count = "#\(ticketsCount)";
                                        self.DataArray[index].total = "$\(self.Format.Number.string(from: NSNumber(value: tickets))!)";
                                    }else if(index == 4){
                                        self.DataArray[index].icon = "Spend.png"
                                        self.DataArray[index].count = "#\(spendsCount)";
                                        self.DataArray[index].total = "$\(self.Format.Number.string(from: NSNumber(value: spends))!)";
                                    }else if(index == 5){
                                        self.DataArray[index].icon = "Ingress.png"
                                        self.DataArray[index].count = "#\(ingressesCount)";
                                        self.DataArray[index].total = "$\(self.Format.Number.string(from: NSNumber(value: ingresses))!)";
                                    }else if(index == 6){
                                        self.DataArray[index].icon = "Vale.png"
                                        self.DataArray[index].count = "#\(paybillsCount)";
                                        self.DataArray[index].total = "$\(self.Format.Number.string(from: NSNumber(value: paybills))!)";
                                    }else{
                                        self.DataArray[index].total = "$\(0)";
                                    }
                                }
                                
                                self.DashboardCollection.reloadData();
                                SwiftSpinner.hide();
                            }else{
                                print(data);
                                SwiftSpinner.hide();
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
        
        if(self.Refresh.isRefreshing){
            self.Refresh.endRefreshing();
            self.DashboardCollection.contentOffset = CGPoint(x: 0, y: -self.Refresh.frame.size.height);
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.DataArray.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 2, height: collectionView.frame.width / 2);
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell:DashboardCollectionViewCell;
        
        cell = self.DashboardCollection.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as! DashboardCollectionViewCell;
        
        cell.backgroundColor = self.DataArray[(indexPath as NSIndexPath).row].color;
        cell.iconView.image = UIImage(named: self.DataArray[(indexPath as NSIndexPath).row].icon)?.withRenderingMode(UIImageRenderingMode.alwaysTemplate);
        cell.iconView.tintColor = UIColor.white;
        cell.descriptionLabel.text = self.DataArray[(indexPath as NSIndexPath).row].description;
        cell.totalLabel.text = self.DataArray[(indexPath as NSIndexPath).row].total;
        cell.countLabel.text = self.DataArray[(indexPath as NSIndexPath).row].count;
        
        return cell;
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailSegue" {
            if let destination = segue.destination as? DetailModalViewController {
                destination.titleNav = self.DataArray[selectedModel].description;
                destination.entity = self.DataArray[selectedModel].entity;
                destination.corteActual = self.actualCorte;
                destination.carwashID = self.CarwashSelected._id;
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if (self.DataArray[(indexPath as NSIndexPath).row].entity == "spends" ||
            self.DataArray[(indexPath as NSIndexPath).row].entity == "ingresses" ||
            self.DataArray[(indexPath as NSIndexPath).row].entity == "paybills") {
            
            self.selectedModel = (indexPath as NSIndexPath).row;
                self.performSegue(withIdentifier: "DetailSegue", sender: self);
        }
    }
    
    func alerta(_ Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

}
