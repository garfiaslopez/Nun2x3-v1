
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
import SwiftSpinner

class SocketIOManager: NSObject {
    let socket = SocketIOClient(socketURL: URL(string: VARS().getApiUrl())!, config: [.log(false), .forcePolling(true)])
    static let sharedInstance = SocketIOManager();
    var actualState:String = "NO_INITIALIZED";
    var beforeState:String = "NO_INITIALIZED";
    var delegate:StateViewController!;
    var reconnectTimer:Timer!;
    let DELEGATE = UIApplication.shared.delegate as! AppDelegate;

    var Info: JSON =  ["user_name": Session().name, "user_id": Session()._id , "device": "Iphone"];
    
    override init() {
        super.init();
        self.listenActions();
    }
    
    func establishConnection() {
        
        // retreive new session user:
        self.Info = ["user_name": Session().name, "user_id": Session()._id , "device": "Iphone"];
        
        socket.connect();
    }
    func closeConnection() {
        let status = Reach().connectionStatus();
        switch status {
        case .online(.wwan), .online(.wiFi):
            socket.disconnect();
        case .unknown, .offline:
            break;
        }
    }
    
    fileprivate func listenActions() {
        socket.on("HowYouAre") {data, ack in
            self.socket.emit("ConnectedAdmin",self.Info.object as! SocketData);
        }
        socket.on("disconnect") {data, ack in
            print("DISCONNECTED DEVICE FROM SOCKET");
        }
//        socket.on("refreshActiveTickets") {data, ack in
//            print("Refresh ActiveTickets...");
//            if let dictionary = data[0] as? NSDictionary {
//                if let id = dictionary["carwash_id"] as? String {
//                    if self.delegate.CarwashSelected._id == id {
//                        self.delegate.ReloadActiveTickets();
//                    }
//                }
//            }
//        }
//        
//        socket.on("refreshDashboard") {data, ack in
//            print("Refresh Dashboard...");
//            if let dictionary = data[0] as? NSDictionary {
//                if let id = dictionary["carwash_id"] as? String {
//                    if self.delegate.CarwashSelected._id == id {
//                        self.delegate.ReloadDashBoardData();
//                    }
//                }
//            }
//        }
    }

    func SendMessageToIpad(_ title:String, msg:String, carwash_id:String){
        let message: JSON =  ["title":title, "message":msg, "carwash_id":carwash_id];
        self.socket.emit("SendMessage",message.object as! SocketData);
    }
}
