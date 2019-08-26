//
//  CobrarViewController.swift
//  nun2x3
//
//  Created by Jose De Jesus Garfias Lopez on 21/11/15.
//  Copyright © 2015 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class CobrarViewController: UIViewController {

    let Save = NSUserDefaults.standardUserDefaults();
    let ApiUrl = VARS().getApiUrl();
    let Store = StoreData();
    let Format = Formatter();

    var PrinterIO:Printer!;
    var UsuarioEnSesion:Session!;
    var LavadoEnSesion:LavadoSession!;
    
    var TicketSelected:Int? = nil;
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        CozyLoadingActivity.show("Cobrando...", disableUI: true);

        if let parent = self.presentingViewController?.presentingViewController?.presentingViewController as? MainViewController{
        
            self.TicketSelected = parent.TicketSelected;
            
            let newticket = parent.Tickets[parent.TicketSelected!];
            newticket.exitDate = self.Format.LocalDate.stringFromDate(NSDate());

            newticket.washingTime = parent.Format.formatTimeInSec(parent.CounterArray[parent.TicketSelected!]);
            let PastTickets = self.Save.integerForKey("TotalTickets");
            newticket.order_id = "#\(PastTickets + 1)";
            
            //totals:
            var total = 0.0;
            for service in newticket.services {
                total = total + service.price;
            }
            newticket.total = total + newticket.car!.price;

            UploadTicket(newticket);
            SocketIOManager.sharedInstance.EmitDashboard();
            parent.Tickets.removeAtIndex(parent.TicketSelected!);
            parent.CounterArray.removeAtIndex(parent.TicketSelected!);
            parent.TicketSelected = nil;
            
            parent.Tickets_CollectionView.reloadData();
            
        }else{
            CozyLoadingActivity.hide(success: false, animated: true);
        }
        
    }
    
    func UploadTicket(NewTicket:TicketModel){
        
        print("UPLOAD TICKET FUNC");
        
        //Incrementamos uno al Total de tickets.
        let PastTickets = self.Save.integerForKey("TotalTickets");
        self.Save.setInteger(PastTickets + 1, forKey: "TotalTickets");
        
        let newTicket = NewTicket;
        newTicket.status = "Charged";
        
        let status = Reach().connectionStatus();
        
        switch status {
        case .Online(.WWAN), .Online(.WiFi):
            
            print("CONECTADO A INTERNET");

            
            let POSTURL = String(ApiUrl + "/ticket");
            let headers = [
                "Authorization": self.UsuarioEnSesion.token
            ]
            var DataToSend =  [String: AnyObject]();
            var ServDict : [[String: AnyObject]]! = [];
            
            DataToSend["lavado_id"] = newTicket.lavado_id;
            DataToSend["corte_id"] = newTicket.corte_id;
            DataToSend["order_id"] = newTicket.order_id;
            DataToSend["status"] = newTicket.status;
            DataToSend["user"] = newTicket.user;
            DataToSend["entryDate"] = newTicket.entryDate;
            DataToSend["exitDate"] = newTicket.exitDate;
            DataToSend["washingTime"] = newTicket.washingTime;
            DataToSend["total"] = newTicket.total;
            DataToSend["date"] = newTicket.date.forServer;
            
            var cardict =  [String: AnyObject]();
            cardict["denomination"] = newTicket.car!.denomination;
            cardict["price"] = newTicket.car!.price;
            DataToSend["car"] = cardict;
            
            for (_, value) in newTicket.services.enumerate() {
                var tmp =  [String: AnyObject]();
                tmp["denomination"] = value.denomination;
                tmp["price"] = value.price;
                ServDict.append(tmp);
            }
            DataToSend["services"] = ServDict;
            
            Alamofire.request(.POST, POSTURL, headers: headers, parameters: DataToSend, encoding: .JSON).responseJSON { response in
                switch response.result {
                case .Success:
                    
                    let data = JSON(data: response.data!);
                    
                    if(data["success"] == true){
                        newTicket.savedOnServer = true;
                        self.Store.SaveTicket(newTicket);
                    }else{
                        
                        print(" NO SUCCESS REQUEST");
                        print(data);

                        if(data["message"] == "Corrupt Token."){
                            //si en caso raro se corruptea el token pues se guarda local:

                            newTicket.savedOnServer = false;
                            self.Store.SaveTicket(newTicket);
                            self.Save.setBool(true, forKey: "UploadBackupServer");
                            
                            if let parent = self.presentingViewController?.presentingViewController?.presentingViewController as? MainViewController{
                                    parent.performSegueWithIdentifier("LoginSegue", sender: self);
                            }
                        }else{
                            newTicket.savedOnServer = false;
                            self.Store.SaveTicket(newTicket);
                            self.Save.setBool(true, forKey: "UploadBackupServer");
                        }
                    }
                case .Failure:
                    newTicket.savedOnServer = false;
                    self.Store.SaveTicket(newTicket);
                    self.Save.setBool(true, forKey: "UploadBackupServer");
                }
            }
            
            break
            
        case .Unknown, .Offline:
            
            print("SIN CONEXION A INTERNET");
            newTicket.savedOnServer = false;
            self.Store.SaveTicket(newTicket);
            self.Save.setBool(true, forKey: "UploadBackupServer");
        
            break
        }

        if let parent = self.presentingViewController?.presentingViewController?.presentingViewController as? MainViewController{
            parent.isOpenModal = false;
            parent.secondsAfterOpen = 0;
        }
        
        self.PrinterIO.OpenCashDrawer();
        self.PrinterIO.PrintTicket(newTicket);
        if(newTicket.ticket_id != ""){
            //Delete From ActiveTickets if in ticket has ticket_id
            let DELURL = String(self.ApiUrl + "/activeticket/" + newTicket.ticket_id);
            let headers = [
                "Authorization": self.UsuarioEnSesion.token
            ]
            Alamofire.request(.DELETE, DELURL, headers: headers, encoding: .JSON).responseJSON { response in
                let data = JSON(data: response.data!);
                if(data["success"] == true){
                    print("DELETED TICKET ACTIVE IN SERVER");
                }
            }
        }
        
        CozyLoadingActivity.hide(success: true, animated: true);
        self.CloseView();

        
    }
    
    func CloseView(){
        if let parent = self.presentingViewController?.presentingViewController?.presentingViewController as? MainViewController{
            let TotalTickets = self.Save.integerForKey("TotalTickets");
            parent.TicketsNumberLabel.text = "#\(TotalTickets)";
            parent.AfterUploadTicket();
            parent.dismissViewControllerAnimated(false, completion: nil);
        }
    }
    func alerta(Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
}
