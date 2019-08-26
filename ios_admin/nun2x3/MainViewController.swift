//
//  MainViewController.swift
//  NUn2x3
//
//  Created by Jose De Jesus Garfias Lopez on 12/07/15.
//  Copyright (c) 2015 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import MaterialKit
import SwiftyJSON
import Alamofire
import RealmSwift
import CoreBluetooth


class MainViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, BLEDelegate, CBPeripheralDelegate{
    
    let DELEGATE = UIApplication.sharedApplication().delegate as! AppDelegate
    var UsuarioEnSesion:Session = Session();
    var LavadoEnSesion:LavadoSession = LavadoSession();
    
    let Save = NSUserDefaults.standardUserDefaults();
    let ApiUrl = VARS().getApiUrl();
    let Sensor = BLE();
    let Store = StoreData();
    let Format = Formatter();
    var PrinterIO:Printer!;

    var Timer = NSTimer();
    var Timerble = NSTimer();
    var TimerBackup = NSTimer();
    var TimerDelete = NSTimer();

    var Cars:Array<CarServModel> = [];
    var Services:Array<CarServModel> = [];
    var Tickets:Array<TicketModel> = [];
    var isLoading = false;
    var TicketSelected:Int? = nil;
    var CounterArray:Array<Int> = [];
    var isOpenModal = false;
    var secondsAfterOpen = 0;
    
    
    @IBOutlet weak var Loading_View: UIImageView!
    @IBOutlet weak var NavigationBar: UINavigationBar!
    @IBOutlet weak var Tickets_CollectionView: UICollectionView!
    
    @IBOutlet weak var TicketsNumberLabel: UILabel!
    @IBOutlet weak var UserNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Sensor.delegate = self;
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true);
        
        NavigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Roboto-Regular", size: 25)!, NSForegroundColorAttributeName: UIColor.whiteColor()];
        
        let nib = UINib(nibName: "MainCollectionCell", bundle: nil);
        self.Tickets_CollectionView.registerNib(nib, forCellWithReuseIdentifier: "CustomCell");
        
        var ImagesForAnimation: [UIImage] = [];
        
        for i in 1...21 {
            ImagesForAnimation.append(UIImage(named:"Loading_\(i).png")!);
        }
        Loading_View.animationImages = ImagesForAnimation;
        Loading_View.animationDuration = 1.0;
        
        self.PrinterIO = Printer(Lavado: self.LavadoEnSesion,Usuario:self.UsuarioEnSesion);
        SocketIOManager.sharedInstance.delegate = self;
        
        
        self.Searchble();
    }

    override func viewDidAppear(animated: Bool) {
        
        print("--------------------------------VIEW DID APPEAR MAIN------------------------------------");
        print(self.UsuarioEnSesion);
        print(self.LavadoEnSesion);
        
        if(self.UsuarioEnSesion.token == "" && self.UsuarioEnSesion.username == ""){
            self.performSegueWithIdentifier("LoginSegue", sender: self);
        }else{
        
            if !Save.boolForKey("FirstLaunch") { // SI ES LA PRIMERA VEZ QUE SE ABRE:
                self.performSegueWithIdentifier("LoginSegue", sender: self);
            }else{
                
                let TotalTickets = self.Save.integerForKey("TotalTickets");
                self.TicketsNumberLabel.text = "#\(TotalTickets)";
                self.UserNameLabel.text = "\(self.UsuarioEnSesion.name)";

                //SI NECESITA ENVIAR EL BACKUP AL SERVER:
                let NeedsUploadToServer = self.Save.boolForKey("UploadBackupServer");
                if(NeedsUploadToServer){
                    //CORRE LA FUNCION EN BACKGROUND Y ENVIA TODO.
                    print("NEEDS UPDATE");
                    self.StopTimerToBackup();
                    self.StartTimerToBackup();
                }
                
                //SI NECESITA BORRAR ALGUNAS COSAS EN EL SERVER:
                let NeedsDeleteInServer = self.Save.boolForKey("RefreshDeleteServer");
                if(NeedsDeleteInServer){
                    //CORRE LA FUNCION EN BACKGROUND Y ENVIA TODO.
                    print("NEEDS DELETE");
                    self.StopTimerToDelete();
                    self.StartTimerToDelete();
                }
                if let status = Save.stringForKey("StatusApp") {
                    print(status);
                    switch status {
                        
                    case "MakeCorteIntermedio" :
                        self.MakeCorteIntermedio();
                        break;
                        
                    case "MakeCorteCompleto" :
                        self.MakeCorteCompleto();
                        break;
                        
                    case "RecoverCorteIntermedio" :
                        self.RecoverFromCorteIntermedio();
                        break;
                        
                    case "RecoverCorteCompleto":
                        self.RecoverFromCorteCompleto();
                        break;
                    case "Normal":
                        if self.Cars.count == 0 && self.Services.count == 0 {
                            self.performSegueWithIdentifier("LoginSegue", sender: self);
                        }
                        break;
                    default:
                        break;
                        
                    }
                }
            }
        }

        
        
        //Al regresar de un corte completo, checar que el bluetooth este conectado, recuperar los precios del servidor
        //recuperar la sesion actual, Loading view and update the UI.
        //IMPROVE STARTTIMER :::::::
        // AL HACER ALGUN TIPO DE CORTE BORRA USUARIOENSESION POR SI CIERRAN LA APP QUE LOS MANDE AL LOGIN

    }
    
    func AfterUploadTicket(){
        print("AfterUploadTIcket");
        if self.Tickets.count == 0 {
            //No hay tickets, send to server to confirm that activetickets is empty.
            print("Deleting");
            self.DeleteAllActiveTickets();
        }
        let NeedsUploadToServer = self.Save.boolForKey("UploadBackupServer");
        if(NeedsUploadToServer){
            print("NEEDS UPDATE");
            self.StopTimerToBackup();
            self.StartTimerToBackup();
        }
    }
    
    func DeleteAllActiveTickets(){
        let status = Reach().connectionStatus();
        switch status {
        case .Online(.WWAN), .Online(.WiFi):
            
            //Delete From ActiveTickets if in ticket has ticket_id
            let DELURL = String(self.ApiUrl + "/activetickets/" + self.LavadoEnSesion._id);
            let headers = [
                "Authorization": self.UsuarioEnSesion.token
            ]
            Alamofire.request(.DELETE, DELURL, headers: headers, encoding: .JSON).responseJSON { response in
                let data = JSON(data: response.data!);
                if(data["success"] == true){
                    print("DELETED ALL TICKETs ACTIVE IN SERVER");
                }
            }
        case .Unknown, .Offline:
            let timerAT = NSTimer.scheduledTimerWithTimeInterval(15, target: self, selector: #selector(MainViewController.AfterUploadTicket), userInfo: nil, repeats: false)
            NSRunLoop.mainRunLoop().addTimer(timerAT, forMode: NSRunLoopCommonModes);
            break;
        }
    }
    
    func RecoverCarsAndServices(){
        print("Recovering Cars And Services");
        self.Loading_View.startAnimating();
        
        let status = Reach().connectionStatus();
        
        switch status {
        case .Online(.WWAN), .Online(.WiFi):
            
            let headers = [
                "Authorization": self.UsuarioEnSesion.token
            ]
            let UrlCars = String(ApiUrl + "/cars/" + self.LavadoEnSesion._id);
            Alamofire.request(.GET, UrlCars, headers: headers).responseJSON { response in
                
                switch response.result {
                case .Success:
                    let data = JSON(data: response.data!);
                    if(data["success"] == true){

                        self.Store.DeleteAllCarsServs();
                        self.Cars = [];

                        for (_,car):(String,JSON) in data["cars"] {
                            
                            let tmp:CarServModel = CarServModel();
                            
                            tmp._id = car["_id"].stringValue;
                            tmp.denomination = car["denomination"].stringValue;
                            tmp.price = car["price"].doubleValue;
                            tmp.img = car["img"].stringValue;
                            tmp.type = "car";
                            
                            self.Cars.append(tmp);
                        }
                        
                        self.Store.SaveCarsServs(self.Cars);
                        print("Carros: \(self.Cars.count)");
                    }else{
                        if(data["message"] == "Corrupt Token."){
                            self.performSegueWithIdentifier("LoginSegue", sender: self);
                        }else{
                            self.alerta("Error de Sesion", Mensaje: data["message"].stringValue );
                            self.Loading_View.stopAnimating();
                        }
                    }
                case .Failure(let error):
                    self.alerta("Error", Mensaje: error.localizedDescription);
                    self.Loading_View.stopAnimating();
                }
            }
            
            let UrlServices = String(ApiUrl + "/services/" + self.LavadoEnSesion._id);
            Alamofire.request(.GET, UrlServices, headers: headers).responseJSON { response in
                
                switch response.result {
                case .Success:
                    let data = JSON(data: response.data!);
                    if(data["success"] == true){
                        self.Loading_View.stopAnimating();
                        self.Services = [];
                        
                        for (_,service):(String,JSON) in data["services"] {
                            
                            let tmp:CarServModel = CarServModel();
                            
                            tmp._id = service["_id"].stringValue;
                            tmp.denomination = service["denomination"].stringValue;
                            tmp.price = service["price"].doubleValue;
                            tmp.img = service["img"].stringValue;
                            tmp.type = "service";
                            
                            self.Services.append(tmp);
                        }
                        self.Store.SaveCarsServs(self.Services);
                        print("Servicios: \(self.Services.count)");
                    }else{
                        if(data["message"] == "Corrupt Token."){
                            self.performSegueWithIdentifier("LoginSegue", sender: self);
                        }else{
                            self.alerta("Error de Sesion", Mensaje: data["message"].stringValue );
                            self.Loading_View.stopAnimating();
                        }
                    }
                case .Failure(let error):
                    self.alerta("Error", Mensaje: error.localizedDescription);
                    self.Loading_View.stopAnimating();
                }
            }
            
        case .Unknown, .Offline:
            
            self.Store.RecoverCarsServs();
            
            self.Cars = self.Store.StoredCars;
            self.Services = self.Store.StoredServices;
            
            print("Carros: \(self.Cars.count)");
            print("Servicios: \(self.Services.count)");
            
            self.alerta("Sin Conexion a internet", Mensaje: "Favor de conectarse a internet.");
            self.Loading_View.stopAnimating();
        }
    }
    
    
    func RecoverUsersOnServer(){
        let status = Reach().connectionStatus();
        switch status {
        case .Online(.WWAN), .Online(.WiFi):
            let headers = [
                "Authorization": self.UsuarioEnSesion.token
            ]
            let UrlUsers = String(self.ApiUrl + "/users/withToken/" + self.LavadoEnSesion._id);
            Alamofire.request(.GET, UrlUsers, headers: headers).responseJSON { response in
                
                switch response.result {
                case .Success:
                    let data = JSON(data: response.data!);
                    if(data["success"] == true){
                        
                        var NewUsers:Array<UserModel> = [];
                        for (_,user):(String,JSON) in data["users"] {
                            
                            let tmp:UserModel = UserModel();
                            
                            tmp._id = user["user"]["_id"].stringValue;
                            tmp.name = user["user"]["info"]["name"].stringValue;
                            tmp.username = user["user"]["username"].stringValue;
                            tmp.password = user["user"]["password"].stringValue;
                            tmp.rol = user["user"]["rol"].stringValue;
                            tmp.token = user["token"].stringValue;
                            
                            NewUsers.append(tmp);
                        }
                        self.Store.DeleteAllUsers()
                        self.Store.SaveUsers(NewUsers);
                        print("Usuarios: \(NewUsers.count)");
                        
                    }else{
                        
                        if(data["message"] == "Corrupt Token."){
                            //CozyLoadingActivity.hide(success: false, animated: true);
                        }else{
                            //CozyLoadingActivity.hide(success: false, animated: false);
                            //self.alerta("Error de Sesion", Mensaje: data["message"].stringValue );
                        }
                    }
                case .Failure:
                    //CozyLoadingActivity.hide(success: false, animated: false);
                    //self.alerta("Error", Mensaje: error.localizedDescription);
                    break;
                }
            }
        case .Unknown, .Offline:
            break;
        }
    }
    
    func MakeCorteIntermedio(){
        self.TicketSelected = nil;
        self.Save.setObject("RecoverCorteIntermedio", forKey: "StatusApp");
        self.Save.setObject(nil, forKey: "UsuarioEnSesion")
        self.performSegueWithIdentifier("LoginSegue", sender: self);
    }
    
    func MakeCorteCompleto(){
        //delete nsuserdefaultsDAta
        self.Save.setInteger(0, forKey: "TotalTickets");
        self.Save.setInteger(0, forKey: "SecondLazoCounter");
        self.Save.setObject(nil, forKey: "UsuarioEnSesion")

        //incrementar el corteid:
        let corteBefore = self.Save.integerForKey("CorteActual");
        self.Save.setInteger(corteBefore + 1, forKey: "CorteActual");

        self.TicketSelected = nil;
        self.Save.setObject("RecoverCorteCompleto", forKey: "StatusApp");
        
        self.StopTimerForTickets();
        self.StopTimerBLE();
        self.performSegueWithIdentifier("LoginSegue", sender: self);
    }
    
    func RecoverFromCorteIntermedio(){
        print("Recover CorteIntermedio");
        self.Save.setObject("Normal", forKey: "StatusApp");
        self.Searchble();
    }
    
    func RecoverFromCorteCompleto(){
        print("Recover Corte Completo");
        self.Save.setObject("Normal", forKey: "StatusApp");
        self.Store.ReloadSession();
        self.RecoverCarsAndServices();
        self.RecoverUsersOnServer();
        self.StartTimerForTickets();
        self.Searchble();
    }
    
    func AddNewTicket(){
        
        
        print("NEW TICKET");
        
        let newcar:SimpleCarModel = SimpleCarModel();
        newcar.denomination = "Seleccionar";
        newcar.price = 0.0;
        
        let newTicket:TicketModel = TicketModel();
        
        newTicket.lavado_id = LavadoEnSesion._id;
        newTicket.corte_id = UsuarioEnSesion.corte_id;
        newTicket.status = "Created";
        newTicket.user = UsuarioEnSesion.name;
        newTicket.car =  newcar;
        newTicket.services = List<SimpleServModel>();
        newTicket.exitDate = "";
        newTicket.washingTime = "";
        newTicket.total = 0.0;
        newTicket.date = Format.ParseMomentDate(UsuarioEnSesion.date);
        newTicket.entryDate = self.Format.LocalDate.stringFromDate(NSDate());
        
        self.Tickets.append(newTicket);
        self.CounterArray.append(0);
        
        //SEND TO ACTIVETICKETS:
        
        let status = Reach().connectionStatus();
        
        switch status {
        case .Online(.WWAN), .Online(.WiFi):
            

            let POSTURL = String(ApiUrl + "/activeticket");
            let headers = [
                "Authorization": self.UsuarioEnSesion.token
            ]
            var DataToSend =  [String: AnyObject]();
            DataToSend["lavado_id"] = newTicket.lavado_id;
            DataToSend["indexpath"] = self.Tickets.count - 1;
            DataToSend["order_id"] = self.Save.integerForKey("TotalTickets") + self.Tickets.count;
            Alamofire.request(.POST, POSTURL, headers: headers, parameters: DataToSend, encoding: .JSON).responseJSON { response in
                switch response.result {
                case .Success:
                    let data = JSON(data: response.data!);
                    if(data["success"] == true){
                        self.Tickets[self.Tickets.count-1].ticket_id = data["ticket_id"].stringValue;
                        
                        //SEND SOCKET TO REFRESH ACTIVE TICKETS.
                        SocketIOManager.sharedInstance.EmitTicketActive();
                    }else{
                    }
                case .Failure( _): break
                }
            }
            
            break
            
        case .Unknown, .Offline:
            break
        }
        
        self.Tickets_CollectionView.reloadData();
        if self.Tickets.count > 6 {
            self.ScrollCollectionToBotom();
        }
    }
    
    func StartTimerToBackup(){
        print("STARTING TIMER TO BACKUP");
        self.TimerBackup = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(MainViewController.SendLocalDataToServer), userInfo: nil, repeats: false)
        NSRunLoop.mainRunLoop().addTimer(self.TimerBackup, forMode: NSRunLoopCommonModes);
    }
    func StopTimerToBackup(){
        self.TimerBackup.invalidate();
    }
    func SendLocalDataToServer(){
        print("Making Backup To Server");
        let status = Reach().connectionStatus();
        switch status {
        case .Online(.WWAN), .Online(.WiFi):
            self.DoBackUp();
        case .Unknown, .Offline:
            self.StartTimerToBackup();
        }
    }
    
    func StartTimerToDelete(){
        self.TimerDelete = NSTimer.scheduledTimerWithTimeInterval(40, target: self, selector: #selector(MainViewController.DeleteLocalDataToServer), userInfo: nil, repeats: false)
        NSRunLoop.mainRunLoop().addTimer(self.TimerDelete, forMode: NSRunLoopCommonModes);
    }
    func StopTimerToDelete(){
        self.TimerDelete.invalidate();
    }
    func DeleteLocalDataToServer(){
        print("Deleting To Server");
        let status = Reach().connectionStatus();
        switch status {
        case .Online(.WWAN), .Online(.WiFi):
            self.DeleteObjsInServer();
        case .Unknown, .Offline:
            self.StartTimerToDelete();
        }
    }
    
    
    func StartTimerForTickets(){
        self.Timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(MainViewController.UpdateSecondForTickets), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(self.Timer, forMode: NSRunLoopCommonModes);
    }
    func StopTimerForTickets(){
        self.Timer.invalidate();
    }
    func UpdateSecondForTickets() {
        if self.CounterArray.count > 0 {
            //verify if modal is open and count 10 seconds to close it;
            if isOpenModal {
                print("open modal");
                self.secondsAfterOpen += 1;
                if self.secondsAfterOpen >= 10 {
                    self.dismissViewControllerAnimated(false, completion: nil);
                    self.Tickets[TicketSelected!].services = List<SimpleServModel>();
                    self.secondsAfterOpen = 0;
                    self.isOpenModal = false;
                }
            }else{
                self.secondsAfterOpen = 0;
            }
            
            //Increment the seconds in the ticket..
            for i in 0 ..< self.CounterArray.count {
                self.CounterArray[i] = self.CounterArray[i] + 1;
            }
        }
        self.Tickets_CollectionView.reloadData();
    }
    
    
    //TIMER FOR CALL BLE UPDATE
    func StartTimerBLE(){
        self.Timerble = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(MainViewController.Searchble), userInfo: nil, repeats: false)
        NSRunLoop.mainRunLoop().addTimer(self.Timerble, forMode: NSRunLoopCommonModes);
    }
    
    func StopTimerBLE(){
        self.Timerble.invalidate();
    }
    
    func Searchble() {
        
        print("BUSCANDO periphereals = \(Sensor.peripherals.count)");
        if ( (Sensor.activePeripheral == nil) || Sensor.activePeripheral!.state != CBPeripheralState.Connected) {
            //isDisconnectedBLE
            print("no sensor");
            if Sensor.peripherals.count > 0 {
                print("CONNECT TO (0)");
                print(Sensor.peripherals);
                Sensor.connectToPeripheral(Sensor.peripherals[0]);
            }else{
                print("re-scanning");
                Sensor.startScanning(20);
                self.StartTimerBLE();
            }
        }else{
            print("AlreadyConnected");
            //isConnectedBLE
            self.StopTimerBLE();
        }
    }
    func bleDidReceiveData(data: NSData?) {
        
        print("RECIBIO DATO DE BLE");
        var buffer = [UInt32](count:data!.length, repeatedValue:0)
        data!.getBytes(&buffer, length:data!.length)
        
        print(buffer);
        
        if buffer.count > 0{
            if (buffer[0] == 0x0A){
                self.AddNewTicket();
            }
            if (buffer[0] == 0x0B){
                let BeforeCount = self.Save.integerForKey("SecondLazoCounter");
                self.Save.setInteger(BeforeCount + 1, forKey: "SecondLazoCounter");
            }
        }else{
            print("NO BUFFER");
        }
    }
    func bleDidUpdateState() {
        print("UPDATED SOME PERIPHEREAL");

    }
    func bleDidConnectToPeripheral() {
        print("CONNECTED TO SOME PERIPHEREAL");
        
    }
    
    func bleDidDisconenctFromPeripheral() {
        print("DISCONNECT TO SOME PERIPHEREAL");
        if let status = Save.stringForKey("StatusApp") {
            switch status {
            case "Normal":
                print("Buscando BLE de nuevo...")
                self.Searchble();
                break;
            default:
                break;
                
            }
        }
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.Tickets.count;
    }
        
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(16.0, 30.0, 0.0, 30.0);
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var cell:MainCollectionViewCell;
        
        cell = self.Tickets_CollectionView.dequeueReusableCellWithReuseIdentifier("CustomCell", forIndexPath: indexPath) as! MainCollectionViewCell;
        
        cell.Timer_Label.text = Format.formatTimeInSec(self.CounterArray[indexPath.row]);
        cell.CarType_Label.text = self.Tickets[indexPath.row].car!.denomination;
        cell.CarPrice_Label.text = String(self.Tickets[indexPath.row].car!.price);
        
        return cell;
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        self.TicketSelected = indexPath.row;
        self.isOpenModal = true;
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("CarsViewController") as! CarsViewController
        vc.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext;
        self.presentViewController(vc, animated: false, completion: nil);

    }
    
    @IBAction func AddTicketAction(sender: AnyObject) {
        AddNewTicket();
    }
    @IBAction func OpenCashDrawer(sender: AnyObject) {
        CozyLoadingActivity.show("Abriendo Caja...", disableUI: true);
        {self.PrinterIO.OpenCashDrawer()} ~> {
            CozyLoadingActivity.hide(success: true, animated: true);
        };
    }
    func ScrollCollectionToBotom(){
        let section = self.numberOfSectionsInCollectionView(Tickets_CollectionView) - 1;
        let item = self.collectionView(Tickets_CollectionView, numberOfItemsInSection: section) - 1;
        let lastIndexPath = NSIndexPath(forItem: item, inSection: section);
        self.Tickets_CollectionView.scrollToItemAtIndexPath(lastIndexPath, atScrollPosition: UICollectionViewScrollPosition.Bottom, animated: true);
    }
    func alerta(Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    func DoBackUp(){
        
        let BACKUPURL = String(ApiUrl + "/history/update/" + self.LavadoEnSesion._id);
        let headers = [
            "Authorization": self.UsuarioEnSesion.token
        ];
        
        self.Store.RecoverForUpdate();
        
        var arrayTickets:Array<[String: AnyObject]> = [];
        
        for NewTicket in self.Store.BackupTickets {
            
            var DataToSend =  [String: AnyObject]();
            var ServDict : [[String: AnyObject]]! = [];
            
            DataToSend["lavado_id"] = NewTicket.lavado_id;
            DataToSend["order_id"] = NewTicket.order_id;
            DataToSend["corte_id"] = NewTicket.corte_id;
            DataToSend["status"] = NewTicket.status;
            DataToSend["user"] = NewTicket.user;
            DataToSend["entryDate"] = NewTicket.entryDate;
            DataToSend["exitDate"] = NewTicket.exitDate;
            DataToSend["washingTime"] = NewTicket.washingTime;
            DataToSend["total"] = NewTicket.total;
            DataToSend["date"] = NewTicket.date.forServer;
            DataToSend["ticket_id"] = NewTicket.ticket_id;
            
            var cardict =  [String: AnyObject]();
            cardict["denomination"] = NewTicket.car!.denomination;
            cardict["price"] = NewTicket.car!.price;
            DataToSend["car"] = cardict;
            
            for (_, value) in NewTicket.services.enumerate() {
                var tmp =  [String: AnyObject]();
                tmp["denomination"] = value.denomination;
                tmp["price"] = value.price;
                ServDict.append(tmp);
            }
            DataToSend["services"] = ServDict;
            arrayTickets.append(DataToSend);
        }
        
        var arraySpends:Array<[String: AnyObject]> = [];
        
        for Obj in self.Store.BackupSpends {
        
            let ToSend = [
                "lavado_id": self.LavadoEnSesion._id,
                "corte_id": Obj.corte_id,
                "denomination": Obj.denomination,
                "total": String(Obj.total),
                "user": Obj.user,
                "date": Obj.date.forServer,
                "isMonthly": String(Obj.isMonthly),
                "owner": Obj.owner
            ];
            arraySpends.append(ToSend);
        }

        var arrayIngresses:Array<[String: AnyObject]> = [];
        
        for Obj in self.Store.BackupIngresses {
            
            let ToSend = [
                "lavado_id": self.LavadoEnSesion._id,
                "corte_id": Obj.corte_id,
                "denomination": Obj.denomination,
                "total": String(Obj.total),
                "user": Obj.user,
                "date": Obj.date.forServer,
                "isMonthly": String(Obj.isMonthly),
                "owner": Obj.owner
            ];
            arrayIngresses.append(ToSend);
        }

        var arrayPaybills:Array<[String: AnyObject]> = [];
        
        for Obj in self.Store.BackupBills {
            
            let ToSend = [
                "lavado_id": self.LavadoEnSesion._id,
                "corte_id": Obj.corte_id,
                "denomination": Obj.denomination,
                "total": String(Obj.total),
                "user": Obj.user,
                "date": Obj.date.forServer,
                "isMonthly": String(Obj.isMonthly),
                "owner": Obj.owner
            ];
            arrayPaybills.append(ToSend);
        }
        
        var arrayCortes:Array<[String: AnyObject]> = [];
        
        for Obj in self.Store.BackupCortes {
            
            let ToSend = [
                "lavado_id": Obj.lavado_id,
                "corte_id": Obj.corte_id,
                "user": Obj.user,
                "date": Obj.date.forServer,
            ];
            arrayCortes.append(ToSend);
        }
        
        var arrayPendings:Array<[String: AnyObject]> = [];
        
        
        for Obj in self.Store.BackupPendings {
            
            let ToSend = [
                "lavado_id": Obj.lavado_id,
                "corte_id": Obj.corte_id,
                "user": Obj.user,
                "date": Obj.date.forServer,
                "denomination": Obj.denomination,
                "isDone": String(Obj.isDone)
            ];
            arrayPendings.append(ToSend);
        }

        print("Tickets: \(arrayTickets.count)");
        print("Spends: \(arraySpends.count)");
        print("ingresses: \(arrayIngresses.count)");
        print("paybills: \(arrayPaybills.count)");
        print("cortes: \(arrayCortes.count)");
        print("pendings: \(arrayPendings.count)");
        
        let FinalDict = [
            "tickets": arrayTickets,
            "spends": arraySpends,
            "ingresses": arrayIngresses,
            "paybills": arrayPaybills,
            "cortes": arrayCortes,
            "pendings": arrayPendings
        ];
        
        Alamofire.request(.POST, BACKUPURL, headers: headers, parameters: FinalDict, encoding: .JSON).responseJSON { response in
            switch response.result {
            case .Success:
                let data = JSON(data: response.data!);
                if(data["success"] == true){
                    
                    print(data);
                    var arrayOfTicketsid:Array<String> = [];
                    var arrayOfSpendsid:Array<String> = [];
                    var arrayOfIngressesid:Array<String> = [];
                    var arrayOfPaybillsid:Array<String> = [];
                    var arrayOfPendingsid:Array<String> = [];
                    var arrayOfCortesid:Array<String> = [];
                    
                    for (_,_id):(String,JSON) in data["tickets"] {
                        arrayOfTicketsid.append(_id.stringValue);
                    }
                    for (_,_id):(String,JSON) in data["spends"] {
                        arrayOfSpendsid.append(_id.stringValue);
                    }
                    for (_,_id):(String,JSON) in data["ingresses"] {
                        arrayOfIngressesid.append(_id.stringValue);
                    }
                    for (_,_id):(String,JSON) in data["paybills"] {
                        arrayOfPaybillsid.append(_id.stringValue);
                    }
                    for (_,_id):(String,JSON) in data["pendings"] {
                        arrayOfPendingsid.append(_id.stringValue);
                    }
                    for (_,_id):(String,JSON) in data["cortes"] {
                        arrayOfCortesid.append(_id.stringValue);
                    }
                    self.Store.UpdateIdsForBaseModel (
                        arrayOfTicketsid,
                        spendsid: arrayOfSpendsid,
                        ingressesid: arrayOfIngressesid,
                        paybillsid: arrayOfPaybillsid,
                        pendingsid: arrayOfPendingsid,
                        cortesid: arrayOfCortesid
                    );
                    self.Save.setBool(false, forKey: "UploadBackupServer");
                    self.Store.ChangeBoolForRecover();
                    self.StopTimerToBackup();
                    
                }else{
                    print("UPDATE NO SUCCESSFULLY DATA NO SUCCESS");
                    //restart de timer ? why is the reason ? what problems?
                    print(data);
                    self.StartTimerToBackup();
                }
            case .Failure( _):
                print("UPDATE NO SUCCESSFULLY CASE FAILURE"); //restart de timer ? why is the reason ? what problems?

                self.StartTimerToBackup();
                break
            }
        }
    }
    
    
    func DeleteObjsInServer() {
    
        let DELURL = String(ApiUrl + "/history/delete");
        let headers = [
            "Authorization": self.UsuarioEnSesion.token
        ]
        
        self.Store.RecoverForDeleteUpdate();
        
        print("_Spends: \(self.Store.DeleteSpends.count)");
        print("_ingresses: \(self.Store.DeleteIngresses.count)");
        print("_paybills: \(self.Store.DeleteBills.count)");
        print("_pendings: \(self.Store.DeletePendings.count)");
        
        var arraySpends:Array<String> = [];
        
        for Obj in self.Store.DeleteSpends {
            let ToSend = Obj._id;
            arraySpends.append(ToSend);
        }
        
        var arrayIngresses:Array<String> = [];
        
        for Obj in self.Store.DeleteIngresses {
            let ToSend = Obj._id;
            arrayIngresses.append(ToSend);
        }
        
        var arrayPaybills:Array<String> = [];
        
        for Obj in self.Store.DeleteBills {
            let ToSend = Obj._id;
            arrayPaybills.append(ToSend);
        }
        
        var arrayPendings:Array<String> = [];
        
        for Obj in self.Store.DeletePendings {
            let ToSend = Obj._id;
            arrayPendings.append(ToSend);
        }
        
        print("Spends: \(arraySpends.count)");
        print("ingresses: \(arrayIngresses.count)");
        print("paybills: \(arrayPaybills.count)");
        print("paybills: \(arrayPendings.count)");
        
        let FinalDict = [
            "spends": arraySpends,
            "ingresses": arrayIngresses,
            "paybills": arrayPaybills,
            "pendings": arrayPendings
        ];
        
        Alamofire.request(.DELETE, DELURL, headers: headers, parameters: FinalDict, encoding: .JSON).responseJSON { response in
            switch response.result {
            case .Success:
                let data = JSON(data: response.data!);
                if(data["success"] == true){
                    print("DELETE SUCCESSFULLY");
                    self.Save.setBool(false, forKey: "RefreshDeleteServer");
                    self.Store.DeleteAfterRefreshServer();
                    self.StopTimerToDelete();
                }else{
                    print("DELETE NO SUCCESSFULLY"); //restart de timer ? why is the reason ? what problems?
                    self.StartTimerToDelete();
                }
            case .Failure( _):
                self.StartTimerToDelete();
                break
            }
        }
    }
    
    func testsaveobject(object:BaseModel){
        self.Store.SaveBaseModel(object);
    }
}