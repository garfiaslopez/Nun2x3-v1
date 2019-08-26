
//
//  State.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 03/04/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//
import UIKit
import Foundation
import SocketIO
import SwiftyJSON

class SocketIOManager: NSObject {
    var socket:SocketIOClient = SocketIOClient(socketURL: NSURL(string: VARS().getApiUrl())!, config: [.Log(false), .ForcePolling(true)]);
    static let sharedInstance = SocketIOManager();
    var actualState:String = "NO_INITIALIZED";
    var beforeState:String = "NO_INITIALIZED";
    var delegate:MainViewController!;
    var reconnectTimer:NSTimer!;
    let DELEGATE = UIApplication.sharedApplication().delegate as! AppDelegate;

    var Info: JSON =  ["carwash_name": LavadoSession().name, "carwash_id": LavadoSession()._id, "user_name": Session().name, "user_id": Session()._id , "device": "Ipad"];
    
    override init() {
        super.init();
        self.listenActions();
    }
    
    func establishConnection() {
        
        // retreive new session user:
        self.Info =  ["carwash_name": LavadoSession().name, "carwash_id": LavadoSession()._id, "user_name": Session().name, "user_id": Session()._id , "device": "Ipad"];

        socket.connect();
    }
    func closeConnection() {
        
        let status = Reach().connectionStatus();
        switch status {
        case .Online(.WWAN), .Online(.WiFi):
            socket.disconnect();
        case .Unknown, .Offline:
            break;
        }
    }
    
    private func listenActions() {
        socket.on("HowYouAre") {data, ack in
            self.socket.emit("ConnectedIpad",self.Info.object);
        }
        socket.on("disconnect") {data, ack in
            print("DISCONNECTED DEVICE FROM SOCKET");
        }
        
        socket.on("MessageToIpad") {data, ack in
            print("MessageToIpad")
            if let dictionary = data[0] as? NSDictionary {
                if let title = dictionary["title"] as? String {
                    if let message = dictionary["message"] as? String {
                        self.delegate.alerta(title, Mensaje: message);
                    }
                }
            }
        }
    }

    func SendMessageToIpad(title:String, msg:String, carwash_id:String){
        let message: JSON =  ["title":title, "message":msg, "carwash_id":carwash_id];
        self.socket.emit("SendMessage",message.object);
    }
    
    func EmitDashboard() {
        self.socket.emit("RefreshDashboard",self.Info.object);
    }
    func EmitTicketActive() {
        self.socket.emit("RefreshActiveTickets",self.Info.object);
    }
    func EmitNotification(Event:String){
        self.socket.emit(Event,self.Info.object);
    }
    func EmitAddedPending(pending: PendingModel){
        print("EMITTING FUNC")
        let p =  ["carwash_name": LavadoSession().name, "carwash_id": LavadoSession()._id,"pending_id": pending._id, "denomination": pending.denomination, "user_id": pending.user, "device": "Ipad"];
        self.socket.emit("PendingAdded", p);
    }
}
