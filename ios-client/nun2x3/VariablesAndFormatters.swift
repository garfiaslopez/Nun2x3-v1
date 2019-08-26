//
//  VariablesAndFormatters.swift
//  nun2x3
//
//  Created by Jose De Jesus Garfias Lopez on 12/11/15.
//  Copyright © 2015 Jose De Jesus Garfias Lopez. All rights reserved.
//

import Foundation
import SwiftyJSON

struct DashboardTemplate {
    var color:UIColor = UIColor.clear;
    var icon:String = "tickets.png";
    var total:String = "$0.0";
    var count:String = "0";
    var description:String = "Tickets";
    var entity:String = "tickets";
}
struct CarwashTemplate {
    var name:String = "";
    var _id:String = "";
    var phone:String = "";
    var address:String = "";
    var status:Bool = false;
    
    init() {
        if let lastC = UserDefaults.standard.dictionary(forKey: "LastCarwash") {
            let carwash:JSON = JSON(lastC);
            self._id = carwash["_id"].stringValue;
            self.address = carwash["address"].stringValue;
            self.name = carwash["name"].stringValue;
            self.status = carwash["status"].boolValue;
            self.phone = carwash["phone"].stringValue;
        }
    }
}
struct UserTemplate {
    var name:String = "";
    var phone:String = "";
    var username:String = "";
    var password:String = "";
    var rol:String = "";
    var lavado_id:Array <String> = [];
}
struct BaseTemplate {
    var _id:String = "";
    var denomination:String = "";
    var total:Double = 0.0;
    var corte_id:String = "";
    var user:String = "";
    var date:String = "";
}

struct PendingTemplate {
    var _id:String = "";
    var date:String = "";
    var denomination:String = "";
    var user:String = "";
    var corte_id:String = "";

}


struct Session {
    var _id:String = "";
    var token:String = "";
    var lavado_id:String = "";
    var username:String = "";
    var password:String = "";
    var address:String = "";
    var phone:String = "";
    var name:String = "";
    var rol:String = "";
    
    init(){
        
        if let UsuarioRecover = UserDefaults.standard.dictionary(forKey: "UsuarioEnSesion") {
            
            if let value = UsuarioRecover["_id"] as? NSString {
                _id = value as String;
            }
            if let value = UsuarioRecover["token"] as? NSString {
                token = value as String;
            }
            if let value = UsuarioRecover["lavado_id"] as? NSString {
                lavado_id = value as String;
            }
            if let value = UsuarioRecover["username"] as? NSString {
                username = value as String;
            }
            if let value = UsuarioRecover["password"] as? NSString {
                password = value as String;
            }
            if let value = UsuarioRecover["address"] as? NSString {
                address = value as String;
            }
            if let value = UsuarioRecover["phone"] as? NSString {
                phone = value as String;
            }
            if let value = UsuarioRecover["name"] as? NSString {
                name = value as String;
            }
            if let value = UsuarioRecover["rol"] as? NSString {
                rol = value as String;
            }
        }
    }
}

class VARS {
    func getApiUrl() -> String {
        return "http://104.236.74.122:8509";
        //return "http://10.10.10.6:3000";
    }
}

extension String {
    
    subscript (i: Int) -> Character {
        return self[self.characters.index(self.startIndex, offsetBy: i)];
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character);
    }
    
    var floatValue: Float {
        return (self as NSString).floatValue
    }
    
    var doubleValue: Double {
        return (self as NSString).doubleValue
    }
}

extension Date {
    
    func isEqualDate(_ dateToCompare : Date) -> Bool {
        var isEqualTo = false;
        if self.compare(dateToCompare) == ComparisonResult.orderedSame{
            isEqualTo = true;
        }
        return isEqualTo;
    }
    
    
    func isGreaterThanDate(_ dateToCompare : Date) -> Bool {
        var isGreater = false;
        if self.compare(dateToCompare) == ComparisonResult.orderedDescending{
            isGreater = true;
        }
        return isGreater;
    }
    
    func isLessThanDate(_ dateToCompare : Date) -> Bool {
        var isLess = false;
        if self.compare(dateToCompare) == ComparisonResult.orderedAscending{
            isLess = true;
        }
        return isLess;
    }
    
    
    func addDays(_ daysToAdd : Int) -> Date {
        let secondsInDays : TimeInterval = Double(daysToAdd) * 60 * 60 * 24;
        let dateWithDaysAdded : Date = self.addingTimeInterval(secondsInDays);
        return dateWithDaysAdded;
    }
    
    
    func addHours(_ hoursToAdd : Int) -> Date {
        let secondsInHours : TimeInterval = Double(hoursToAdd) * 60 * 60;
        let dateWithHoursAdded : Date = self.addingTimeInterval(secondsInHours);
        return dateWithHoursAdded;
    }
    
    func addMonths(_ monthsToAdd : Int) -> Date {
        var calendar = Calendar.current;
        calendar.timeZone = TimeZone.current;
        return calendar.date(byAdding: .month, value: monthsToAdd, to: self)!;
    }
    
    var forServer: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self)
    }
    
    func yearsFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.year, from: date, to: self, options: []).year!
    }
    func monthsFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.month, from: date, to: self, options: []).month!
    }
    func weeksFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.weekOfYear, from: date, to: self, options: []).weekOfYear!
    }
    func daysFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.day, from: date, to: self, options: []).day!
    }
    func hoursFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.hour, from: date, to: self, options: []).hour!
    }
    func minutesFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.minute, from: date, to: self, options: []).minute!
    }
    func secondsFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.second, from: date, to: self, options: []).second!
    }
    func offsetFrom(_ date:Date) -> String {
        if yearsFrom(date)   > 0 { return "\(yearsFrom(date))y"   }
        if monthsFrom(date)  > 0 { return "\(monthsFrom(date))M"  }
        if weeksFrom(date)   > 0 { return "\(weeksFrom(date))w"   }
        if daysFrom(date)    > 0 { return "\(daysFrom(date))d"    }
        if hoursFrom(date)   > 0 { return "\(hoursFrom(date))h"   }
        if minutesFrom(date) > 0 { return "\(minutesFrom(date))m" }
        if secondsFrom(date) > 0 { return "\(secondsFrom(date))s" }
        return ""
    }
}

class Formatter {
    
    //Formatters:
    var Porcent:NumberFormatter{
        let formatter =  NumberFormatter();
        formatter.numberStyle = NumberFormatter.Style.percent;
        formatter.maximumFractionDigits = 1;
        formatter.multiplier = 1.0;
        formatter.percentSymbol = "%";
        return formatter;
    }
    var Date: DateFormatter{
        let formatter = DateFormatter();
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
        formatter.locale = Locale.current;
        return formatter;
    };
    
    var DateOnly: DateFormatter{
        let formatter = DateFormatter();
        formatter.dateFormat = "yyyy-MM-dd";
        formatter.locale = Locale.current;
        return formatter;
    };
    
    var LocalDate: DateFormatter{
        let formatter = DateFormatter();
        formatter.dateFormat = "dd-MM-yyyy HH:mm:ss";
        formatter.locale = Locale.current;
        return formatter;
    };
    
    var DateForSave: DateFormatter{
        let formatter = DateFormatter();
        formatter.dateFormat = "dd/MM/yy HH:mm";
        formatter.locale = Locale.current;
        return formatter;
    };
    
    var Number: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumSignificantDigits = 2;
        return formatter
    };
    
    var Currency: NumberFormatter {
        let formatter = NumberFormatter();
        formatter.numberStyle = .currency;
        return formatter;
    };
    
    var LocalFromISO: DateFormatter{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
        formatter.timeZone = TimeZone.autoupdatingCurrent;
        formatter.locale = Locale.current;
        return formatter;
    }
    
    var ToISO: DateFormatter{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter;
    }
    
    var DatePretty: DateFormatter{
        let formatter = DateFormatter();
        formatter.dateFormat = "dd/MMMM/YYYY";
        formatter.locale = Locale.current;
        return formatter;
    };
    var HourPretty: DateFormatter{
        let formatter = DateFormatter();
        formatter.dateFormat = "HH:mm";
        formatter.locale = Locale.current;
        return formatter;
    };
    
    var DateShortOnly: DateFormatter{
        let formatter = DateFormatter();
        formatter.locale = Locale.current;
        formatter.timeZone = TimeZone.autoupdatingCurrent;
        formatter.dateFormat = "dd/MMM/YY";
        
        return formatter;
    };
    
    var DateYearOnly: DateFormatter{
        let formatter = DateFormatter();
        formatter.locale = Locale.current;
        formatter.dateFormat = "YYYY";
        return formatter;
    };
    
    var DateMonthOnly: DateFormatter{
        let formatter = DateFormatter();
        formatter.locale = Locale.current;
        formatter.dateFormat = "MMMM";
        return formatter;
    };
    
    var DateMonthYearOnly: DateFormatter{
        let formatter = DateFormatter();
        formatter.locale = Locale.current;
        formatter.dateFormat = "MMMM/YYYY";
        return formatter;
    };
    
    var DateDayOnly: DateFormatter{
        let formatter = DateFormatter();
        formatter.locale = Locale.current;
        formatter.dateFormat = "dd";
        return formatter;
    };
    
    var DateHourOnly: DateFormatter{
        let formatter = DateFormatter();
        formatter.locale = Locale.current;
        formatter.dateFormat = "HH";
        return formatter;
    };
    
    func ParseMomentDate(_ date: String) -> Foundation.Date{
        var dateString:String = "";
        for i in 0 ..< date.characters.count {
            if(date[i] == "T"){
                dateString += " ";
            }else if(date[i] == "."){
                break;
            }else{
                dateString += date[i];
            }
        }
        if let DateISO = ToISO.date(from: dateString) {
            let strlocal = LocalFromISO.string(from: DateISO);
            if let DateToReturn = Date.date(from: strlocal) {
                return DateToReturn;
            }else{
                print("Could not parse date")
            }
        } else {
            print("Could not parse date")
        }
        return Foundation.Date();
    }
    
    func ParseMoment(_ date: String) -> Foundation.Date{
        var dateString:String = "";
        for i in 0 ..< date.characters.count {
            if(date[i] == "T"){
                dateString += " ";
            }else if(date[i] == "."){
                break;
            }else{
                dateString += date[i];
            }
        }
        return Date.date(from: dateString)!;
    }
    
    
    
    func FirstDayOfWeek(_ date: Foundation.Date) -> Foundation.Date {
        
        var calendar = Calendar.current;
        calendar.timeZone = TimeZone.current;
        var dateComponents = (calendar as NSCalendar).components([.year, .month, .weekOfMonth], from: date);
        dateComponents.hour = 0;
        dateComponents.minute = 0;
        dateComponents.second = 0;
        dateComponents.weekday = 2;
        return calendar.date(from: dateComponents)!
    }
    
    
    func FirstDayOfMonth(_ date: Foundation.Date) -> Foundation.Date {
        var calendar = Calendar.current;
        calendar.timeZone = TimeZone.current;
        var dateComponents = (calendar as NSCalendar).components([.year, .month, .weekOfMonth], from: date);
        dateComponents.hour = 0;
        dateComponents.minute = 0;
        dateComponents.second = 0;
        dateComponents.day = 1;
        return calendar.date(from: dateComponents)!
    }
    
    func FirstDayOfYear(_ date: Foundation.Date) -> Foundation.Date {
        var calendar = Calendar.current;
        calendar.timeZone = TimeZone.current;
        var dateComponents = (calendar as NSCalendar).components([.year, .month, .weekOfMonth], from: date);
        dateComponents.hour = 0;
        dateComponents.minute = 0;
        dateComponents.second = 0;
        dateComponents.day = 1;
        dateComponents.month = 1;
        return calendar.date(from: dateComponents)!
    }
    
    func Today() ->Foundation.Date {
        
        var calendar = Calendar.current;
        calendar.timeZone = TimeZone.current;
        var dateComponents = (calendar as NSCalendar).components([.year, .month, .day], from: Foundation.Date());
        dateComponents.hour = 0;
        dateComponents.minute = 0;
        dateComponents.second = 0;
        return calendar.date(from: dateComponents)!
        
    }
    
    func formatTimeInSec(_ totalSeconds: Int) -> String {
        let seconds = totalSeconds % 60
        let minutes = (totalSeconds / 60) % 60
        let hours = totalSeconds / 3600
        let strHours = hours > 9 ? String(hours) : "0" + String(hours)
        let strMinutes = minutes > 9 ? String(minutes) : "0" + String(minutes)
        let strSeconds = seconds > 9 ? String(seconds) : "0" + String(seconds)
        
        if hours > 0 {
            return "\(strHours):\(strMinutes):\(strSeconds)"
        }
        else {
            return "\(strMinutes):\(strSeconds)"
        }
    }
    
    init(){
    }
}

