//
//  VariablesAndFormatters.swift
//  nun2x3
//
//  Created by Jose De Jesus Garfias Lopez on 12/11/15.
//  Copyright © 2015 Jose De Jesus Garfias Lopez. All rights reserved.
//

import Foundation

struct Session {
    
    var _id:String = "";
    var token:String = "";
    var corte_id:String = "";
    var username:String = "";
    var password:String = "";
    var address:String = "";
    var phone:String = "";
    var name:String = "";
    var rol:String = "";
    var date:String = "";
    var startDate:String = "";
    
    init(){
        
        if let UsuarioRecover = NSUserDefaults.standardUserDefaults().dictionaryForKey("UsuarioEnSesion") {
            
            if let value = UsuarioRecover["_id"] as? NSString {
                _id = value as String;
            }
            if let value = UsuarioRecover["token"] as? NSString {
                token = value as String;
            }
            if let value = UsuarioRecover["corte_id"] as? NSString {
                corte_id = value as String;
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
            if let value = UsuarioRecover["date"] as? NSString {
                date = value as String;
            }
            if let value = UsuarioRecover["startDate"] as? NSString {
                startDate = value as String;
            }
        }
        
    }
}

struct LavadoSession {
    var _id:String = "";
    var name:String = "";
    var doubleTicket:Bool = false;
    
    init(){
        
        if let LavadoRecover = NSUserDefaults.standardUserDefaults().dictionaryForKey("LavadoEnSesion") {
            if let value = LavadoRecover["_id"] as? NSString {
                _id = value as String;
            }
            if let value = LavadoRecover["name"] as? NSString {
                name = value as String;
            }
            if let value = LavadoRecover["doubleTicket"] as? Bool {
                doubleTicket = value as Bool;
            }
        }
    }
}

class VARS {
    func getApiUrl() -> String{
        
        //return "http://10.10.10.5:3000";
        
        // SERVER
        return "http://104.236.74.122:8509";
    }
    

}

extension String {
    
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)];
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

extension NSDate {
    
    func isEqualDate(dateToCompare : NSDate) -> Bool {
        var isEqualTo = false;
        if self.compare(dateToCompare) == NSComparisonResult.OrderedSame{
            isEqualTo = true;
        }
        return isEqualTo;
    }
    
    
    func isGreaterThanDate(dateToCompare : NSDate) -> Bool {
        var isGreater = false;
        if self.compare(dateToCompare) == NSComparisonResult.OrderedDescending{
            isGreater = true;
        }
        return isGreater;
    }
    
    func isLessThanDate(dateToCompare : NSDate) -> Bool {
        var isLess = false;
        if self.compare(dateToCompare) == NSComparisonResult.OrderedAscending{
            isLess = true;
        }
        return isLess;
    }
    
    
    func addDays(daysToAdd : Int) -> NSDate {
        let secondsInDays : NSTimeInterval = Double(daysToAdd) * 60 * 60 * 24;
        let dateWithDaysAdded : NSDate = self.dateByAddingTimeInterval(secondsInDays);
        return dateWithDaysAdded;
    }
    
    
    func addMonths(monthsToAdd : Int) -> NSDate {
        let calendar = NSCalendar.currentCalendar();
        calendar.timeZone = NSTimeZone.localTimeZone();
        return calendar.dateByAddingUnit(NSCalendarUnit.Month, value: monthsToAdd, toDate: self, options: [])!;
        
    }
    
    func addHours(hoursToAdd : Int) -> NSDate {
        let secondsInHours : NSTimeInterval = Double(hoursToAdd) * 60 * 60;
        let dateWithHoursAdded : NSDate = self.dateByAddingTimeInterval(secondsInHours);
        return dateWithHoursAdded;
    }
    
    var forServer: String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)!
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return formatter.stringFromDate(self)
    }
    
    func yearsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Year, fromDate: date, toDate: self, options: []).year
    }
    func monthsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Month, fromDate: date, toDate: self, options: []).month
    }
    func weeksFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.WeekOfYear, fromDate: date, toDate: self, options: []).weekOfYear
    }
    func daysFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Day, fromDate: date, toDate: self, options: []).day
    }
    func hoursFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Hour, fromDate: date, toDate: self, options: []).hour
    }
    func minutesFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Minute, fromDate: date, toDate: self, options: []).minute
    }
    func secondsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Second, fromDate: date, toDate: self, options: []).second
    }
    func offsetFrom(date:NSDate) -> String {
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
    var Porcent:NSNumberFormatter{
        let formatter =  NSNumberFormatter();
        formatter.numberStyle = NSNumberFormatterStyle.PercentStyle;
        formatter.maximumFractionDigits = 1;
        formatter.multiplier = 1.0;
        formatter.percentSymbol = "%";
        return formatter;
    }
    var Date: NSDateFormatter{
        let formatter = NSDateFormatter();
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
        formatter.locale = NSLocale.systemLocale();
        return formatter;
    };
    
    var DateOnly: NSDateFormatter{
        let formatter = NSDateFormatter();
        formatter.dateFormat = "yyyy-MM-dd";
        formatter.locale = NSLocale.systemLocale();
        return formatter;
    };
    
    var LocalDate: NSDateFormatter{
        let formatter = NSDateFormatter();
        formatter.dateFormat = "dd-MM-yyyy HH:mm:ss";
        formatter.locale = NSLocale.systemLocale();
        return formatter;
    };
    
    var DateForSave: NSDateFormatter{
        let formatter = NSDateFormatter();
        formatter.dateFormat = "dd/MM/yy HH:mm";
        formatter.locale = NSLocale.systemLocale();
        return formatter;
    };
    
    var Number: NSNumberFormatter {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.minimumSignificantDigits = 2;
        return formatter
    };
    
    var Currency: NSNumberFormatter {
        let formatter = NSNumberFormatter();
        formatter.numberStyle = .CurrencyStyle;
        return formatter;
    };
    
    var LocalFromISO: NSDateFormatter{
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
        formatter.timeZone = NSTimeZone.localTimeZone();
        formatter.locale = NSLocale.systemLocale();
        return formatter;
    }
    
    var ToISO: NSDateFormatter{
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)!
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return formatter;
    }
    
    var DatePretty: NSDateFormatter{
        let formatter = NSDateFormatter();
        formatter.dateFormat = "dd/MMMM/YYYY";
        formatter.locale = NSLocale.currentLocale();
        return formatter;
    };
    var HourPretty: NSDateFormatter{
        let formatter = NSDateFormatter();
        formatter.dateFormat = "HH:mm";
        formatter.locale = NSLocale.currentLocale();
        return formatter;
    };
    
    var DateShortOnly: NSDateFormatter{
        let formatter = NSDateFormatter();
        formatter.locale = NSLocale.currentLocale();
        formatter.timeZone = NSTimeZone.localTimeZone();
        formatter.dateFormat = "dd/MMM/YY";
        
        return formatter;
    };
    
    var DateMonthOnly: NSDateFormatter{
        let formatter = NSDateFormatter();
        formatter.locale = NSLocale.currentLocale();
        formatter.dateFormat = "MMMM";
        return formatter;
    };
    
    var DateMonthYearOnly: NSDateFormatter{
        let formatter = NSDateFormatter();
        formatter.locale = NSLocale.currentLocale();
        formatter.dateFormat = "MMMM/YYYY";
        return formatter;
    };
    
    var DateDayOnly: NSDateFormatter{
        let formatter = NSDateFormatter();
        formatter.locale = NSLocale.currentLocale();
        formatter.dateFormat = "dd";
        return formatter;
    };
    
    var DateHourOnly: NSDateFormatter{
        let formatter = NSDateFormatter();
        formatter.locale = NSLocale.currentLocale();
        formatter.dateFormat = "HH";
        return formatter;
    };
    
    var DateYearOnly: NSDateFormatter{
        let formatter = NSDateFormatter();
        formatter.locale = NSLocale.currentLocale();
        formatter.dateFormat = "YYYY";
        return formatter;
    };
    
    func ParseMomentDate(date: String) -> NSDate{
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
        if let DateISO = ToISO.dateFromString(dateString) {
            let strlocal = LocalFromISO.stringFromDate(DateISO);
            if let DateToReturn = Date.dateFromString(strlocal) {
                return DateToReturn;
            }else{
                print("Could not parse date")
            }
        } else {
            print("Could not parse date")
        }
        return NSDate();
    }
    
    func ParseMoment(date: String) -> NSDate{
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
        return Date.dateFromString(dateString)!;
    }
    
    
    
    func FirstDayOfWeek(date: NSDate) -> NSDate {
        
        let calendar = NSCalendar.currentCalendar();
        calendar.timeZone = NSTimeZone.systemTimeZone();
        let dateComponents = calendar.components([.Year, .Month, .WeekOfMonth], fromDate: date);
        dateComponents.hour = 0;
        dateComponents.minute = 0;
        dateComponents.second = 0;
        dateComponents.weekday = 2;
        return calendar.dateFromComponents(dateComponents)!
    }
    
    func FirstDayOfYear(date: NSDate) -> NSDate {
        let calendar = NSCalendar.currentCalendar();
        calendar.timeZone = NSTimeZone.systemTimeZone();
        let dateComponents = calendar.components([.Year, .Month, .WeekOfMonth], fromDate: date);
        dateComponents.hour = 0;
        dateComponents.minute = 0;
        dateComponents.second = 0;
        dateComponents.day = 1;
        dateComponents.month = 1;
        return calendar.dateFromComponents(dateComponents)!
    }
    
    
    func FirstDayOfMonth(date: NSDate) -> NSDate {
        let calendar = NSCalendar.currentCalendar();
        calendar.timeZone = NSTimeZone.systemTimeZone();
        let dateComponents = calendar.components([.Year, .Month, .WeekOfMonth], fromDate: date);
        dateComponents.hour = 0;
        dateComponents.minute = 0;
        dateComponents.second = 0;
        dateComponents.day = 1;
        return calendar.dateFromComponents(dateComponents)!
    }
    
    func Today() ->NSDate {
        
        let calendar = NSCalendar.currentCalendar();
        calendar.timeZone = NSTimeZone.systemTimeZone();
        let dateComponents = calendar.components([.Year, .Month, .Day], fromDate: NSDate());
        dateComponents.hour = 0;
        dateComponents.minute = 0;
        dateComponents.second = 0;
        return calendar.dateFromComponents(dateComponents)!
        
    }
    
    func formatTimeInSec(totalSeconds: Int) -> String {
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

