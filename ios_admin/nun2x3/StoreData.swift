//
//  StoreData.swift
//  nun2x3
//
//  Created by Jose De Jesus Garfias Lopez on 26/11/15.
//  Copyright © 2015 Jose De Jesus Garfias Lopez. All rights reserved.
//

import Foundation
import RealmSwift

class UserModel: Object {
    dynamic var _id = "";
    dynamic var name = "";
    dynamic var username = "";
    dynamic var password = "";
    dynamic var rol = "";
    dynamic var token = "";
}

class BaseModel: Object {
    dynamic var _id = "";
    dynamic var lavado_id = "";
    dynamic var denomination = "";
    dynamic var total = 0.0;
    dynamic var user = "";
    dynamic var date:NSDate = NSDate();
    dynamic var isMonthly = false;
    dynamic var owner = "";
    dynamic var typeBase = "";
    dynamic var savedOnServer = false
    dynamic var corte_id = "";
    dynamic var shouldBeDeleted = false;

}

class PendingModel: Object {
    dynamic var _id = "";
    dynamic var lavado_id = "";
    dynamic var denomination = "";
    dynamic var user = "";
    dynamic var date:NSDate = NSDate();
    dynamic var isDone = false;
    dynamic var savedOnServer = false
    dynamic var corte_id = "";
    dynamic var shouldBeDeleted = false;
    
}
class CarServModel: Object {
    dynamic var _id = "";
    dynamic var denomination = "";
    dynamic var price = 0.0;
    dynamic var img = "";
    dynamic var type = "";
}
class SimpleCarModel: Object {
    dynamic var denomination = "";
    dynamic var price = 0.0;
}
class SimpleServModel: Object {
    dynamic var denomination = "";
    dynamic var price = 0.0;
}
class TicketModel: Object {
    dynamic var _id = "";
    dynamic var lavado_id = "";
    dynamic var ticket_id = "";
    dynamic var order_id = "";
    dynamic var status = "";
    dynamic var user = "";
    dynamic var car = SimpleCarModel?();
    var services = List<SimpleServModel>()
    dynamic var exitDate = "";
    dynamic var washingTime = "";
    dynamic var total = 0.0;
    dynamic var date:NSDate = NSDate();
    dynamic var entryDate = "";
    dynamic var savedOnServer = false
    dynamic var corte_id = "";

}

class CorteModel: Object {
    dynamic var _id = "";
    dynamic var lavado_id = "";
    dynamic var user = "";
    dynamic var corte_id = "";
    dynamic var date:NSDate = NSDate();
    dynamic var savedOnServer = false
}

class StoreData {

    let Format = Formatter();
    
    var UsuarioEnSesion = Session();
    var LavadoEnSesion = LavadoSession();

    
    var StoredTickets:Array<TicketModel> = [];
    var StoredCars:Array<CarServModel> = [];
    var StoredServices:Array<CarServModel> = [];
    var StoredSpends:Array<BaseModel> = [];
    var StoredBills:Array<BaseModel> = [];
    var StoredIngresses:Array<BaseModel> = [];
    var StoredUsers:Array<UserModel> = [];
    var StoredPendings:Array<PendingModel> = [];
    var UserInSesion:UserModel?;
    
    
    var BackupTickets:Array<TicketModel> = [];
    var BackupSpends:Array<BaseModel> = [];
    var BackupBills:Array<BaseModel> = [];
    var BackupIngresses:Array<BaseModel> = [];
    var BackupCortes:Array<CorteModel> = [];
    var BackupPendings:Array<PendingModel> = [];
    
    var DeleteSpends:Array<BaseModel> = [];
    var DeleteBills:Array<BaseModel> = [];
    var DeleteIngresses:Array<BaseModel> = [];
    var DeletePendings:Array<PendingModel> = [];
    
    
    func ReloadSession (){
        self.UsuarioEnSesion = Session();
        self.LavadoEnSesion = LavadoSession();
    }
    
    func SaveUsers(users:[UserModel]){
        let realm = try! Realm();
        try! realm.write {
            realm.add(users);
        }
    }
    
    func RecoverUsers(){
        let realm = try! Realm();
        self.StoredUsers = [];
        let Query = realm.objects(UserModel);
        for user in Query {
            self.StoredUsers.append(user);
        }
    }
    

    ///////////////// CARS ANS SERVICES
    func SaveCarsServs(CarsServs:[CarServModel]){
        let realm = try! Realm();
        try! realm.write {
            realm.add(CarsServs);
        }
    }
    
    func RecoverCarsServs(){
        let realm = try! Realm();
        self.StoredCars = [];
        self.StoredServices = [];

        let Query = realm.objects(CarServModel).filter("type contains 'car'");
        let Query2 = realm.objects(CarServModel).filter("type contains 'service'");
        for car in Query {
            self.StoredCars.append(car);
        }
        for serv in Query2 {
            self.StoredServices.append(serv);
        }
    }
    
    
    
    ///////////////// BASE MODEL
    
    func SaveBaseModel(BaseObj:BaseModel){
        let realm = try! Realm();
        try! realm.write {
            realm.add(BaseObj);
        }
    }
    
    func RecoverBaseModel(TypeBase:String) -> Array<BaseModel>{
        let realm = try! Realm();
        let DateSearch = Format.ParseMomentDate(self.UsuarioEnSesion.date);
        var Return:Array<BaseModel> = [];
        let predicate = NSPredicate(format: "typeBase = %@ AND corte_id = %@ AND date = %@ AND shouldBeDeleted = %@", TypeBase,self.UsuarioEnSesion.corte_id, DateSearch,false);
        let Query = realm.objects(BaseModel).filter(predicate);
        for obj in Query {
            Return.append(obj);
        }
        return Return;
    }
    
    func DeleteBaseModel(BaseObj:BaseModel){
        let realm = try! Realm();
        try! realm.write {
            realm.delete(BaseObj);
        }
    }
    func UpdateShouldBeDeleted(BaseObj:BaseModel, Should: Bool){
        let realm = try! Realm();
        try! realm.write {
            BaseObj.shouldBeDeleted = Should;
        }
    }
    func UpdateShouldBeDeletedPending(PendingObj:PendingModel, Should: Bool) {
        let realm = try! Realm();
        try! realm.write {
            PendingObj.shouldBeDeleted = Should;
        }
    }
    func Update_id(BaseObj:BaseModel, _id: String){
        let realm = try! Realm();
        try! realm.write {
            BaseObj._id = _id;
        }
    }
    ///////////////// TICKET MODEL

    func SaveTicket(Ticket:TicketModel){
        let realm = try! Realm();
        try! realm.write {
            realm.add(Ticket);
        }
    }

    func RecoverTicketsOnSession() -> Array<TicketModel>{
        let realm = try! Realm();
        var Return:Array<TicketModel> = [];
        let predicate = NSPredicate(format: "corte_id = %@ AND date = %@",self.UsuarioEnSesion.corte_id, self.UsuarioEnSesion.date);
        let Query = realm.objects(TicketModel).filter(predicate);
        for obj in Query {
            Return.append(obj);
        }
        return Return;
    }
    
    ///////////////// PENDINGS
    
    func SavePending(PendingObj:PendingModel){
        let realm = try! Realm();
        try! realm.write {
            realm.add(PendingObj);
        }
    }
    
    func RecoverPendings() -> Array<PendingModel>{
        let realm = try! Realm();
        var Return:Array<PendingModel> = [];
        
        let predicatePendings = NSPredicate(format: "isDone = %@",false);
        let Query = realm.objects(PendingModel).filter(predicatePendings);
        for pending in Query {
            Return.append(pending);
        }
        return Return;
    }
    
    func DeletePending(Pending:PendingModel){
        let realm = try! Realm();
        try! realm.write {
            realm.delete(Pending);
        }
    }
    
    ///////////////// HISTORY  MODEL
    func RecoverHistory(initialDate:String,finalDate:String){
        
        let realm = try! Realm();
        self.StoredTickets = [];
        self.StoredSpends = [];
        self.StoredIngresses = [];
        self.StoredBills = [];
        
        let Start = Format.ParseMomentDate(initialDate)
        let Finish = Format.ParseMomentDate(finalDate);
        
        let predicate = NSPredicate(format: "date >= %@ AND date < %@",Start,Finish);
        
        let QueryTickets = realm.objects(TicketModel).filter(predicate);
        for obj in QueryTickets {
            self.StoredTickets.append(obj);
        }
        
        let predicateSpends = NSPredicate(format: "date >= %@ AND date < %@ and typeBase = %@ AND shouldBeDeleted = %@",Start,Finish,"spend",false);
        let QuerySpends = realm.objects(BaseModel).filter(predicateSpends);
        for obj in QuerySpends {
            self.StoredSpends.append(obj);
        }
        
        let predicateIngresses = NSPredicate(format: "date >= %@ AND date < %@ and typeBase = %@ AND shouldBeDeleted = %@",Start,Finish,"ingress",false);
        let QueryIngresses = realm.objects(BaseModel).filter(predicateIngresses);
        for obj in QueryIngresses {
            self.StoredIngresses.append(obj);
        }
        
        let predicateBills = NSPredicate(format: "date >= %@ AND date < %@ and typeBase = %@ AND shouldBeDeleted = %@",Start,Finish,"bill",false);
        let QueryBills = realm.objects(BaseModel).filter(predicateBills);
        for obj in QueryBills {
            self.StoredBills.append(obj);
        }
    }
    
    
    
    ///////////////// CORTE  MODEL
    func RecoverCorteOnSession(){
        let realm = try! Realm();
        self.StoredTickets = [];
        self.StoredSpends = [];
        self.StoredIngresses = [];
        self.StoredBills = [];
        self.BackupCortes = [];
        
        let predicate = NSPredicate(format: "date = %@ AND corte_id = %@",Format.ParseMomentDate(self.UsuarioEnSesion.date),self.UsuarioEnSesion.corte_id);
        let QueryTickets = realm.objects(TicketModel).filter(predicate);
        for obj in QueryTickets {
            self.StoredTickets.append(obj);
        }
        
        let predicateSpends = NSPredicate(format: "date = %@ AND corte_id = %@ AND typeBase = %@ AND shouldBeDeleted = %@",Format.ParseMomentDate(self.UsuarioEnSesion.date),self.UsuarioEnSesion.corte_id,"spend",false);
        let QuerySpends = realm.objects(BaseModel).filter(predicateSpends);
        for obj in QuerySpends {
            self.StoredSpends.append(obj);
        }
        
        let predicateIngresses = NSPredicate(format: "date = %@ AND corte_id = %@ AND typeBase = %@ AND shouldBeDeleted = %@",Format.ParseMomentDate(self.UsuarioEnSesion.date),self.UsuarioEnSesion.corte_id,"ingress",false);
        let QueryIngresses = realm.objects(BaseModel).filter(predicateIngresses);
        for obj in QueryIngresses {
            self.StoredIngresses.append(obj);
        }
        
        let predicateBills = NSPredicate(format: "date = %@ AND corte_id = %@ AND typeBase = %@ AND shouldBeDeleted = %@",Format.ParseMomentDate(self.UsuarioEnSesion.date),self.UsuarioEnSesion.corte_id,"bill",false);
        let QueryBills = realm.objects(BaseModel).filter(predicateBills);
        for obj in QueryBills {
            self.StoredBills.append(obj);
        }
    }
    
    
    
    ///////////////// UPDATE FOR SERVER  MODEL
    
    func RecoverForUpdate(){
        
        //BASEMODEL ADD QUERY SHOULDBEDELETED == FALSE
        let realm = try! Realm();
        
        self.BackupCortes = [];
        self.BackupTickets = [];
        self.BackupSpends = [];
        self.BackupIngresses = [];
        self.BackupBills = [];
        self.BackupPendings = [];
        
        let predicate = NSPredicate(format: "savedOnServer = %@",false);
        
        let QueryTickets = realm.objects(TicketModel).filter(predicate);
        for obj in QueryTickets {
            self.BackupTickets.append(obj);
        }
        
        let predicateSpends = NSPredicate(format: "savedOnServer = %@ AND typeBase = %@ AND shouldBeDeleted = %@",false,"spend",false);
        let QuerySpends = realm.objects(BaseModel).filter(predicateSpends);
        for obj in QuerySpends {
            self.BackupSpends.append(obj);
        }
        
        let predicateIngresses = NSPredicate(format: "savedOnServer = %@ AND typeBase = %@ AND shouldBeDeleted = %@",false,"ingress",false);
        let QueryIngresses = realm.objects(BaseModel).filter(predicateIngresses);
        for obj in QueryIngresses {
            self.BackupIngresses.append(obj);
        }
        
        let predicateBills = NSPredicate(format: "savedOnServer = %@ AND typeBase = %@ AND shouldBeDeleted = %@",false,"bill",false);
        let QueryBills = realm.objects(BaseModel).filter(predicateBills);
        for obj in QueryBills {
            self.BackupBills.append(obj);
        }
        
        let predicateCortes = NSPredicate(format: "savedOnServer = %@",false);
        let QueryCortes = realm.objects(CorteModel).filter(predicateCortes);
        for obj in QueryCortes {
            self.BackupCortes.append(obj);
        }
        
        let predicatePendings = NSPredicate(format: "savedOnServer = %@",false);
        let QueryPendings = realm.objects(PendingModel).filter(predicatePendings);
        for obj in QueryPendings {
            self.BackupPendings.append(obj);
        }
    }
    
    func RecoverForDeleteUpdate(){
        
        let realm = try! Realm();

        self.DeleteSpends = [];
        self.DeleteIngresses = [];
        self.DeleteBills = [];
        self.DeletePendings = [];
        
        let predicateSpends = NSPredicate(format: "savedOnServer = %@ AND typeBase = %@ AND shouldBeDeleted = %@",true,"spend",true);
        let QuerySpends = realm.objects(BaseModel).filter(predicateSpends);
        for obj in QuerySpends {
            self.DeleteSpends.append(obj);
        }
        
        let predicateIngresses = NSPredicate(format: "savedOnServer = %@ AND typeBase = %@ AND shouldBeDeleted = %@",true,"ingress",true);
        let QueryIngresses = realm.objects(BaseModel).filter(predicateIngresses);
        for obj in QueryIngresses {
            self.DeleteIngresses.append(obj);
        }
        
        let predicateBills = NSPredicate(format: "savedOnServer = %@ AND typeBase = %@ AND shouldBeDeleted = %@",true,"bill",true);
        let QueryBills = realm.objects(BaseModel).filter(predicateBills);
        for obj in QueryBills {
            self.DeleteBills.append(obj);
        }
        
        let predicatePendings = NSPredicate(format: "savedOnServer = %@ AND shouldBeDeleted = %@",true,true);
        let QueryPendings = realm.objects(PendingModel).filter(predicatePendings);
        for obj in QueryPendings {
            self.DeletePendings.append(obj);
        }
    }
    
    
    
    func ChangeBoolForRecover(){
        
        let realm = try! Realm();
    
        try! realm.write {
            for obj in self.BackupTickets {
                obj.setValue(true, forKey: "savedOnServer");
            }
            for obj in self.BackupSpends {
                obj.setValue(true, forKey: "savedOnServer");
            }
            for obj in self.BackupIngresses {
                obj.setValue(true, forKey: "savedOnServer");
            }
            for obj in self.BackupBills {
                obj.setValue(true, forKey: "savedOnServer");
            }
            for obj in self.BackupCortes {
                obj.setValue(true, forKey: "savedOnServer");
            }
            for obj in self.BackupPendings {
                obj.setValue(true, forKey: "savedOnServer");
            }
        }
        self.BackupCortes = [];
        self.BackupTickets = [];
        self.BackupSpends = [];
        self.BackupIngresses = [];
        self.BackupBills = [];
        self.BackupPendings = [];
    }
    
    func UpdateIdsForBaseModel(ticketsid:[String],spendsid:[String], ingressesid:[String],paybillsid:[String],pendingsid:[String],cortesid:[String]){
        
        let realm = try! Realm();

        try! realm.write {
            if self.BackupTickets.count > 0 {
                for i in 0...ticketsid.count-1 {
                    self.BackupTickets[i].setValue(ticketsid[i], forKey: "_id");
                }
            }
            if self.BackupSpends.count > 0 {
                for i in 0...spendsid.count-1 {
                    self.BackupSpends[i].setValue(spendsid[i], forKey: "_id");
                }
            }
            if self.BackupIngresses.count > 0 {
                for i in 0...ingressesid.count-1 {
                    self.BackupIngresses[i].setValue(ingressesid[i], forKey: "_id");
                }
            }
            if self.BackupBills.count > 0 {
                for i in 0...paybillsid.count-1 {
                    self.BackupBills[i].setValue(paybillsid[i], forKey: "_id");
                }
            }
            if self.BackupPendings.count > 0 {
                for i in 0...pendingsid.count-1 {
                    self.BackupPendings[i].setValue(pendingsid[i], forKey: "_id");
                }
            }
            if self.BackupCortes.count > 0 {
                for i in 0...cortesid.count-1 {
                    self.BackupCortes[i].setValue(cortesid[i], forKey: "_id");
                }
            }
        }
    }
    
    func DeleteAfterRefreshServer(){
        let realm = try! Realm();

        try! realm.write {
            realm.delete(self.DeleteSpends);
            realm.delete(self.DeleteIngresses);
            realm.delete(self.DeleteBills);
            realm.delete(self.DeletePendings);
        }
        
        self.DeleteSpends = [];
        self.DeleteIngresses = [];
        self.DeleteBills = [];
        self.DeletePendings = [];
    }
    
    ///////////////////// CORTEMODEL 
    
    func SaveCorte(Corte:CorteModel){
        let realm = try! Realm();
        try! realm.write {
            realm.add(Corte);
        }
    }
    
    
    func DeleteAllUsers(){
        let realm = try! Realm();

        let Query = realm.objects(UserModel);
        try! realm.write {
            realm.delete(Query);
        }
    }
    
    func DeleteAllCarsServs(){
        let realm = try! Realm();

        let Query = realm.objects(CarServModel);
        try! realm.write {
            realm.delete(Query);
        }
    }
    func DeleteAllTickets(){
        let realm = try! Realm();

        let Query = realm.objects(TicketModel);
        try! realm.write {
            realm.delete(Query);
        }
    }
    func DeleteAllSpends(){
        let realm = try! Realm();

        let Query = realm.objects(BaseModel).filter("typeBase contains 'spend'");
        try! realm.write {
            realm.delete(Query);
        }
    }
    
    func DeleteAllIngresses(){
        let realm = try! Realm();

        let Query = realm.objects(BaseModel).filter("typeBase contains 'ingress'");
        try! realm.write {
            realm.delete(Query);
        }
    }
    
    func DeleteAllBills(){
        let realm = try! Realm();

        let Query = realm.objects(BaseModel).filter("typeBase contains 'bill'");
        try! realm.write {
            realm.delete(Query);
        }
    }
    
    func DeleteAllPendings(){
        let realm = try! Realm();
        
        let Query = realm.objects(PendingModel);
        try! realm.write {
            realm.delete(Query);
        }
    }
    
    func AuthUser(username:String, password:String) -> Bool{
        let realm = try! Realm();

        let predicate = NSPredicate(format: "username = %@ AND password = %@", username, password);
        let objs = realm.objects(UserModel).filter(predicate);
        if(objs.count >= 1){
            self.UserInSesion = objs[0];
            return true;
        }
        return false;
    }
    
    func AuthAdmin(username:String, password:String) -> Bool {
        let realm = try! Realm();

        let predicate = NSPredicate(format: "username = %@ AND password = %@ AND rol = %@", username, password,"Administrador");
        let objs = realm.objects(UserModel).filter(predicate);
        if(objs.count >= 1){
            self.UserInSesion = objs[0];
            return true;
        }
        return false;
    }
}

