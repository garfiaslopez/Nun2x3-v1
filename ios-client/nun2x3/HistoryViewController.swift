//
//  HistoryViewController.swift
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


class HistoryViewController: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UITextFieldDelegate{
    
    let ApiUrl = VARS().getApiUrl();
    let Format = Formatter();
    var UsuarioEnSesion:Session = Session();
    
    var DataArray:Array<DashboardTemplate> = [];
    var Carwashes:Array<CarwashTemplate> = [];
    var CarwashesNames:Array<String> = [];
    var CarwashSelected:CarwashTemplate!;
    var SelectedDate:Date = Date();
    
    @IBOutlet weak var SearchButton: UIButton!
    @IBOutlet weak var MenuButton: UIBarButtonItem!
    @IBOutlet weak var HistoryCollection: UICollectionView!
    @IBOutlet weak var CarwashStatusImage: UIImageView!
    @IBOutlet weak var CarwashNameLabel: UILabel!
    @IBOutlet weak var initialDateTextfield: UITextField!
    @IBOutlet weak var DateSegment: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "DashboardCollectionViewCell", bundle: nil);
        self.HistoryCollection.register(nib, forCellWithReuseIdentifier: "CustomCell");
        
        let colors = [  UIColor(red: 62/255, green: 153/255, blue: 237/255, alpha: 1),
            UIColor(red: 53/255, green: 160/255, blue: 78/255, alpha: 1),
            UIColor(red: 103/255, green: 63/255, blue: 180/255, alpha: 1),
            UIColor(red: 244/255, green: 56/255, blue: 62/255, alpha: 1),
            UIColor(red: 252/255, green: 107/255, blue: 71/255, alpha: 1),
            UIColor(red: 0/255, green: 150/255, blue: 136/255, alpha: 1),
        ];
        let categories = ["Tickets","Total", "Autos", "Gastos", "Ingresos", "Vales"];
        
        if revealViewController() != nil {
            MenuButton.target = revealViewController()
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer());
            MenuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        }
        
        for index in 0 ..< categories.count {
            var ticketsDash = DashboardTemplate();
            ticketsDash.description = categories[index];
            ticketsDash.color = colors[index];
            ticketsDash.icon = categories[index] + ".png";
            self.DataArray.append(ticketsDash);
        }
        
        // No border, no shadow, floatingPlaceholderEnabled
        initialDateTextfield.layer.borderColor = UIColor.clear.cgColor
        initialDateTextfield.tintColor = UIColor.orange;
        initialDateTextfield.delegate = self;
        initialDateTextfield.placeholder = Date().forServer;
        
        SearchButton.layer.shadowOpacity = 0.55;
        SearchButton.layer.shadowRadius = 5.0;
        SearchButton.layer.shadowColor = UIColor.gray.cgColor;
        SearchButton.layer.shadowOffset = CGSize(width: 0, height: 2.5);
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.UsuarioEnSesion = Session();
        self.CarwashSelected = CarwashTemplate();
        
        if(self.UsuarioEnSesion.token == "" && self.UsuarioEnSesion.username == ""){
            self.performSegue(withIdentifier: "LoginSegue", sender: self);
        }else{
            self.SelectedDate = Format.Today();
            self.initialDateTextfield.text = self.Format.DatePretty.string(from: self.SelectedDate);
            self.ReloadDashBoardData(Format.Today().forServer, endDate: self.Format.Today().addDays(1).forServer);
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
    
    func ReloadDashBoardData(_ startDate:String, endDate:String){
        //RELOAD THE INFO TO DISPLAY IN DASHBOARD:
        SwiftSpinner.show("Actualizando historial");
        let headers = [
            "Authorization": self.UsuarioEnSesion.token
        ]
        
        let POSTURL = String(self.ApiUrl + "/dashboard/" + self.CarwashSelected._id);
        let DatatoSend = [
            "initialDate": startDate,
            "finalDate": endDate,
        ];
        
        Alamofire.request(POSTURL!, method: .post, parameters: DatatoSend, encoding: JSONEncoding.default,headers: headers).responseJSON { response in
            
            if response.result.isSuccess {
                let data = JSON(data: response.data!);
                if(data["success"] == true){
                    
                    //STORE LOCALLY WITH TRUE FLAG ON SERVERSAVED:
                    print(data);
                    
                    let tickets = data["tickets"]["total"].doubleValue;
                    let spends = data["spends"]["total"].doubleValue;
                    let paybills = data["paybills"]["total"].doubleValue;
                    let ingresses = data["ingresses"]["total"].doubleValue;
                    
                    let ticketsCount = data["tickets"]["count"].intValue;
                    let spendsCount = data["spends"]["count"].intValue;
                    let paybillsCount = data["paybills"]["count"].intValue;
                    let ingressesCount = data["ingresses"]["count"].intValue;
                    
                    let total = tickets + ingresses - spends;
                    
                    for index in 0 ..< self.DataArray.count {
                        
                        if(index == 0){
                            self.DataArray[index].icon = "Ticket.png"
                            self.DataArray[index].count = "#\(ticketsCount)";
                            self.DataArray[index].total = "";
                        }else if(index == 1){
                            self.DataArray[index].icon = "Total.png"
                            self.DataArray[index].count = "";
                            self.DataArray[index].total = "$\(self.Format.Number.string(from: NSNumber(value: total))!)";
                        }else if(index == 2){
                            self.DataArray[index].icon = "Cars.png"
                            self.DataArray[index].count = "#\(ticketsCount)";
                            self.DataArray[index].total = "$\(self.Format.Number.string(from: NSNumber(value: tickets))!)";
                        }else if(index == 3){
                            self.DataArray[index].icon = "Spend.png"
                            self.DataArray[index].count = "#\(spendsCount)";
                            self.DataArray[index].total = "$\(self.Format.Number.string(from: NSNumber(value: spends))!)";
                        }else if(index == 4){
                            self.DataArray[index].icon = "Ingress.png"
                            self.DataArray[index].count = "#\(ingressesCount)";
                            self.DataArray[index].total = "$\(self.Format.Number.string(from: NSNumber(value: ingresses))!)";
                            
                        }else if(index == 5){
                            self.DataArray[index].icon = "Vale.png"
                            self.DataArray[index].count = "#\(paybillsCount)";
                            self.DataArray[index].total = "$\(self.Format.Number.string(from: NSNumber(value: paybills))!)";
                        }else{
                            self.DataArray[index].total = "$\(0)";
                        }
                    }
                    
                    self.HistoryCollection.reloadData();
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
        
    }
    
    @IBAction func ChangeDateFilter(_ sender: Any) {
        
        switch self.DateSegment.selectedSegmentIndex {
        case 0:
            self.initialDateTextfield.text = self.Format.DatePretty.string(from: self.SelectedDate);
            break;
        case 1:
            self.initialDateTextfield.text = self.Format.DateMonthYearOnly.string(from: self.SelectedDate);
            break;
        case 2:
            self.initialDateTextfield.text = self.Format.DateYearOnly.string(from: self.SelectedDate);
            break;
        default:
            self.initialDateTextfield.text = self.Format.DatePretty.string(from: self.SelectedDate);
            break;
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
        
        cell = self.HistoryCollection.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as! DashboardCollectionViewCell;
        
        cell.backgroundColor = self.DataArray[(indexPath as NSIndexPath).row].color;
        cell.iconView.image = UIImage(named: self.DataArray[(indexPath as NSIndexPath).row].icon)?.withRenderingMode(UIImageRenderingMode.alwaysTemplate);
        cell.iconView.tintColor = UIColor.white;
        cell.descriptionLabel.text = self.DataArray[(indexPath as NSIndexPath).row].description;
        cell.totalLabel.text = self.DataArray[(indexPath as NSIndexPath).row].total;
        cell.countLabel.text = self.DataArray[(indexPath as NSIndexPath).row].count;
        
        return cell;
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    @IBAction func Search(_ sender: AnyObject) {
    
        switch self.DateSegment.selectedSegmentIndex {
        case 0:
            self.ReloadDashBoardData(self.SelectedDate.forServer, endDate: self.SelectedDate.addDays(1).forServer);
            break;
        case 1:
            let initial = self.Format.FirstDayOfMonth(self.SelectedDate);
            let final = initial.addMonths(1);
            self.ReloadDashBoardData(initial.forServer, endDate: final.forServer);
            break;
        case 2:
            let initial = self.Format.FirstDayOfYear(self.SelectedDate);
            self.ReloadDashBoardData(initial.forServer, endDate: initial.addDays(366).forServer);
        default:
            self.ReloadDashBoardData(Format.Today().forServer, endDate: self.Format.Today().addDays(1).forServer);
        }
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        DatePickerDialog().show("Selecciona Una Fecha", doneButtonTitle: "Seleccionar", cancelButtonTitle: "Cancelar", defaultDate: self.SelectedDate, datePickerMode: UIDatePickerMode.date){
            (date) -> Void in
            
            let dateS = self.Format.DateOnly.string(from: date);
            self.SelectedDate = self.Format.DateOnly.date(from: dateS)!;
            
            switch self.DateSegment.selectedSegmentIndex {
            case 0:
                textField.text = self.Format.DatePretty.string(from: date);
                break;
            case 1:
                textField.text = self.Format.DateMonthYearOnly.string(from: date);
                break;
            case 2:
                textField.text = self.Format.DateYearOnly.string(from: date);
                break;
            default:
                textField.text = self.Format.DatePretty.string(from: date);
                break;
            }
            
        }
        
        return false;
    }
    
    func alerta(_ Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    
}
