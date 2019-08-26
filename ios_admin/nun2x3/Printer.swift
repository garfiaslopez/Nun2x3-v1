//
//  Printer.swift
//  nun2x3
//
//  Created by Jose De Jesus Garfias Lopez on 22/11/15.
//  Copyright © 2015 Jose De Jesus Garfias Lopez. All rights reserved.
//

import Foundation
import CoreGraphics

class Printer {
    
    var portName = "BT:Star Micronics";
    var portSettings = "";
    var largeWidth:Int32 = 832;
    var shortWidth:Int32 = 576;
    let sm_true:  UInt32 = 1;

    var fontSize = CGFloat(35.0);
    var fontName = "Roboto-Regular";
    var headerString = "Estacionamiento con autolavado 'NUn2x3'\r\n";
    var footerString = "\r\nGracias por su preferencia.";
    
    var UsuarioEnSesion = Session();
    var LavadoEnSesion = LavadoSession();
    
    let Format = Formatter();
    let Save = NSUserDefaults.standardUserDefaults();
    
    init(Lavado:LavadoSession,Usuario:Session){
        self.LavadoEnSesion = Lavado;
        self.UsuarioEnSesion = Usuario;
    }

    func PrintImage(image:UIImage){
        if !(StarPrinterStatus_2().offline == sm_true) {
            PrinterFunctions.PrintImageWithPortname(self.portName, portSettings: self.portSettings, imageToPrint: image, maxWidth: self.shortWidth, compressionEnable: true, withDrawerKick: true);
        }
    }
    func JustPrintImage(image:UIImage){
        if !(StarPrinterStatus_2().offline == sm_true) {
            PrinterFunctions.PrintImageWithPortname(self.portName, portSettings: self.portSettings, imageToPrint: image, maxWidth: self.shortWidth, compressionEnable: true, withDrawerKick: false);
        }

    }
    func OpenCashDrawer(){
        if !(StarPrinterStatus_2().offline == sm_true) {
            PrinterFunctions.OpenCashDrawerWithPortname(self.portName, portSettings: self.portSettings, drawerNumber: 1);
        }
    }
    
    func PrintExample(){
        if !(StarPrinterStatus_2().offline == sm_true) {
            PrinterFunctions.PrintSampleReceipt4InchWithPortname(self.portName, portSettings: self.portSettings);
        }
    }
    
    func PrintTicket(Ticket:TicketModel) {
        if !(StarPrinterStatus_2().offline == sm_true) {
            print("FIRSTTICKET");
            
            PrinterFunctions.PrintImageWithPortname(self.portName, portSettings: self.portSettings, imageToPrint: self.TicketToImage(Ticket, isClient: true), maxWidth: self.shortWidth, compressionEnable: true, withDrawerKick: true);
            if(self.LavadoEnSesion.doubleTicket == true) {
                print("SecondTICKET");
                PrinterFunctions.PrintImageWithPortname(self.portName, portSettings: self.portSettings, imageToPrint: self.TicketToImage(Ticket, isClient: false), maxWidth: self.shortWidth, compressionEnable: true, withDrawerKick: false);
            }

        }
    }
    
    func PrintVale(Vale:BaseModel){
        let image = self.ValeToImage(Vale);
        if !(StarPrinterStatus_2().offline == sm_true) {
            PrinterFunctions.PrintImageWithPortname(self.portName, portSettings: self.portSettings, imageToPrint: image, maxWidth: self.shortWidth, compressionEnable: true, withDrawerKick: false);
            PrinterFunctions.PrintImageWithPortname(self.portName, portSettings: self.portSettings, imageToPrint: image, maxWidth: self.shortWidth, compressionEnable: true, withDrawerKick: false);
        }

    }
    
    func CorteToImage(Tickets:Array<TicketModel>,Spends:Array<BaseModel>, Ingresses:Array<BaseModel>,Paybills:Array<BaseModel>, Type:String) -> UIImage {
        
        var TicketImage = UIImage();
        let FinalString = NSMutableAttributedString();
        var ActualIndex = 0;
        let Logo = UIImage(named: "Logo_Print.png")!;
        let LogoRect = CGRect(x: 150, y: 0, width: Logo.size.width, height: Logo.size.height);
        
        let CenterAtt = NSMutableParagraphStyle();
        CenterAtt.maximumLineHeight = 30.0;
        CenterAtt.alignment = NSTextAlignment.Center;
        let LeftAtt = NSMutableParagraphStyle();
        LeftAtt.maximumLineHeight = 30.0;
        LeftAtt.alignment = NSTextAlignment.Left;
        let RightAtt = NSMutableParagraphStyle();
        RightAtt.maximumLineHeight = 30.0;
        RightAtt.alignment = NSTextAlignment.Left;
        let Paragraph = NSMutableParagraphStyle();
        let Tab = NSTextTab(textAlignment: NSTextAlignment.Right, location: CGFloat(self.shortWidth - 30), options:[:]);
        Paragraph.tabStops = [Tab];
        
        let RobotoAttribute = [NSFontAttributeName:UIFont(name: self.fontName, size: self.fontSize)!];
        
        var ParseCars =  [String: AnyObject]();
        var ParseServices = [String: AnyObject]();
        var ParseSpends = [String: AnyObject]();
        var ParseIngresses = [String: AnyObject]();
        var ParsePaybills = [String: AnyObject]();
        
        for ticket in Tickets {
            if let CarDict = ParseCars[(ticket.car?.denomination)!] as? NSDictionary{
                if let count = CarDict["Count"] as? Int {
                    if let total = CarDict["Total"] as? Double {
                        ParseCars[(ticket.car?.denomination)!] = ["Count": count + 1 , "Total": total + (ticket.car?.price)!];
                    }
                }
            }else{
                ParseCars[(ticket.car?.denomination)!] = ["Count": 1 , "Total" : (ticket.car?.price)!];
            }
            
            for serv in ticket.services {
                if let ServDict = ParseServices[serv.denomination] as? NSDictionary {
                    if let count = ServDict["Count"] as? Int {
                        if let total = ServDict["Total"] as? Double {
                            ParseServices[serv.denomination] = ["Count": count + 1 , "Total": total + serv.price];
                        }
                    }
                }else{
                    ParseServices[serv.denomination] = ["Count": 1, "Total": serv.price];
                }
            }
        }
        
        for spend in Spends {
            let key = spend.denomination;
            if let dict = ParseSpends[key] as? NSDictionary{
                if let count = dict["Count"] as? Int {
                    if let total = dict["Total"] as? Double {
                        ParseSpends[key] = ["Count": count + 1 , "Total": total + spend.total];
                    }
                }
            }else{
                ParseSpends[key] = ["Count": 1 , "Total" : spend.total];
            }
        }
        
        for ingress in Ingresses {
            let key = ingress.denomination;
            if let dict = ParseIngresses[key] as? NSDictionary{
                if let count = dict["Count"] as? Int {
                    if let total = dict["Total"] as? Double {
                        ParseIngresses[key] = ["Count": count + 1 , "Total": total + ingress.total];
                    }
                }
            }else{
                ParseIngresses[key] = ["Count": 1 , "Total" : ingress.total];
            }
        }
        
        for paybill in Paybills {
            let key = paybill.denomination;
            if let dict = ParsePaybills[key] as? NSDictionary{
                if let count = dict["Count"] as? Int {
                    if let total = dict["Total"] as? Double {
                        ParsePaybills[key] = ["Count": count + 1 , "Total": total + paybill.total];
                    }
                }
            }else{
                ParsePaybills[key] = ["Count": 1 , "Total" : paybill.total];
            }
        }

        //MAKING THE ATTRIBUTE STRING FOR PRINT:
        
        ////////////////ENCABEZADO
        let Header = NSMutableAttributedString(string: Type + "\r\n");
        Header.addAttribute(NSParagraphStyleAttributeName, value: CenterAtt, range: NSRange(location: 0,length: Header.length));
        FinalString.appendAttributedString(Header);
        ActualIndex = ActualIndex + Header.length;
        
        
        let SesionDate = NSMutableAttributedString(string: "Inicio: " + self.UsuarioEnSesion.startDate + "\r\n");
        SesionDate.addAttribute(NSParagraphStyleAttributeName, value: CenterAtt, range: NSRange(location: 0,length: SesionDate.length));
        FinalString.appendAttributedString(SesionDate);
        
        let SesionDateFinal = NSMutableAttributedString(string: "Cierre: " + Format.LocalDate.stringFromDate(NSDate()) + "\r\n");
        SesionDateFinal.addAttribute(NSParagraphStyleAttributeName, value: CenterAtt, range: NSRange(location: 0,length: SesionDateFinal.length));
        FinalString.appendAttributedString(SesionDateFinal);
        
        let SesionName = NSMutableAttributedString(string: "Encargado: " + self.UsuarioEnSesion.name + "\r\n");
        SesionName.addAttribute(NSParagraphStyleAttributeName, value: CenterAtt, range: NSRange(location: 0,length: SesionName.length));
        FinalString.appendAttributedString(SesionName);
        
        let SesionTotalTickets = NSMutableAttributedString(string: "# Tickets: " + "\(Tickets.count)" + "\r\n");
        SesionTotalTickets.addAttribute(NSParagraphStyleAttributeName, value: CenterAtt, range: NSRange(location: 0,length: SesionTotalTickets.length));
        FinalString.appendAttributedString(SesionTotalTickets);
        
        let BeforeCount = self.Save.integerForKey("SecondLazoCounter");
        let SecondTotalTickets = NSMutableAttributedString(string: "# Tickets (2 lazo): " + "\(BeforeCount)" + "\r\n");
        SecondTotalTickets.addAttribute(NSParagraphStyleAttributeName, value: CenterAtt, range: NSRange(location: 0,length: SecondTotalTickets.length));
        FinalString.appendAttributedString(SecondTotalTickets);
        
        let SesionTotalSpends = NSMutableAttributedString(string: "# Gastos: " + "\(Spends.count)" + "\r\n");
        SesionTotalSpends.addAttribute(NSParagraphStyleAttributeName, value: CenterAtt, range: NSRange(location: 0,length: SesionTotalSpends.length));
        FinalString.appendAttributedString(SesionTotalSpends);
        
        let SesionTotalIngresses = NSMutableAttributedString(string: "# Ingresos: " + "\(Ingresses.count)" + "\r\n");
        SesionTotalIngresses.addAttribute(NSParagraphStyleAttributeName, value: CenterAtt, range: NSRange(location: 0,length: SesionTotalIngresses.length));
        FinalString.appendAttributedString(SesionTotalIngresses);
        
        let SesionTotalPaybills = NSMutableAttributedString(string: "# Vales: " + "\(Paybills.count)" + "\r\n");
        SesionTotalPaybills.addAttribute(NSParagraphStyleAttributeName, value: CenterAtt, range: NSRange(location: 0,length: SesionTotalPaybills.length));
        FinalString.appendAttributedString(SesionTotalPaybills);
        
        let Separador = NSMutableAttributedString(string:"---------------------------------------------------------\r\n");
        Separador.addAttribute(NSParagraphStyleAttributeName, value: CenterAtt, range: NSRange(location: 0,length: Separador.length));
        FinalString.appendAttributedString(Separador);
        
        let VehicleLabel = NSMutableAttributedString(string:"Vehiculos\r\n");
        VehicleLabel.addAttribute(NSParagraphStyleAttributeName, value: CenterAtt, range: NSRange(location: 0,length: VehicleLabel.length));
        VehicleLabel.addAttribute(NSBackgroundColorAttributeName, value: UIColor.blackColor(), range: NSRange(location: 0, length: VehicleLabel.length - 2));
        VehicleLabel.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSRange(location:0,length: VehicleLabel.length));
        FinalString.appendAttributedString(VehicleLabel);
        
        var TotalCars = 0.0;
        for (car,obj)in ParseCars {
            if let dict = obj as? NSDictionary{
                if let count = dict["Count"] as? Int {
                    if let total = dict["Total"] as? Double {
                        TotalCars = TotalCars + total;
                        let CarsTicket = NSMutableAttributedString(string: "\(count).- \(car)\t$" + String(self.Format.Number.stringFromNumber(total)!) + "\r\n");
                        CarsTicket.addAttribute(NSParagraphStyleAttributeName, value: Paragraph, range: NSRange(location: 0,length: CarsTicket.length));
                        FinalString.appendAttributedString(CarsTicket);
                    }
                }
            }
        }
        let TotalCarsLabel = NSMutableAttributedString(string: "Total" + "\t$" + String(self.Format.Number.stringFromNumber(TotalCars)!) + "\r\n");
        TotalCarsLabel.addAttribute(NSParagraphStyleAttributeName, value: Paragraph, range: NSRange(location: 0,length: TotalCarsLabel.length));
        FinalString.appendAttributedString(TotalCarsLabel);
        
        FinalString.appendAttributedString(Separador);
        
        let ServLabel = NSMutableAttributedString(string:"Servicios Adicionales\r\n");
        ServLabel.addAttribute(NSParagraphStyleAttributeName, value: CenterAtt, range: NSRange(location: 0,length: ServLabel.length));
        ServLabel.addAttribute(NSBackgroundColorAttributeName, value: UIColor.blackColor(), range: NSRange(location: 0, length: ServLabel.length - 2));
        ServLabel.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSRange(location:0,length: ServLabel.length));
        FinalString.appendAttributedString(ServLabel);
        var TotalServs = 0.0;
        for (serv,obj)in ParseServices {
            if let dict = obj as? NSDictionary{
                if let count = dict["Count"] as? Int {
                    if let total = dict["Total"] as? Double {
                        TotalServs = TotalServs + total;
                        let ServTicket = NSMutableAttributedString(string: "\(count).- \(serv)\t$" + String(self.Format.Number.stringFromNumber(total)!) + "\r\n");
                        ServTicket.addAttribute(NSParagraphStyleAttributeName, value: Paragraph, range: NSRange(location: 0,length: ServTicket.length));
                        FinalString.appendAttributedString(ServTicket);
                    }
                }
            }
        }
        
        let TotalServsLabel = NSMutableAttributedString(string: "Total" + "\t$" + String(self.Format.Number.stringFromNumber(TotalServs)!) + "\r\n");
        TotalServsLabel.addAttribute(NSParagraphStyleAttributeName, value: Paragraph, range: NSRange(location: 0,length: TotalServsLabel.length));
        FinalString.appendAttributedString(TotalServsLabel);
        
        FinalString.appendAttributedString(Separador);

        
        let IngressLabel = NSMutableAttributedString(string:"Ingresos\r\n");
        IngressLabel.addAttribute(NSParagraphStyleAttributeName, value: CenterAtt, range: NSRange(location: 0,length: IngressLabel.length));
        IngressLabel.addAttribute(NSBackgroundColorAttributeName, value: UIColor.blackColor(), range: NSRange(location: 0, length: IngressLabel.length - 2));
        IngressLabel.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSRange(location:0,length: IngressLabel.length));
        FinalString.appendAttributedString(IngressLabel);
        var TotalIngresses = 0.0;
        for (ingress,obj)in ParseIngresses {
            if let dict = obj as? NSDictionary{
                if let count = dict["Count"] as? Int {
                    if let total = dict["Total"] as? Double {
                        TotalIngresses = TotalIngresses + total;
                        let IngressTicket = NSMutableAttributedString(string: "\(count).- \(ingress)\t$" + String(self.Format.Number.stringFromNumber(total)!) + "\r\n");
                        IngressTicket.addAttribute(NSParagraphStyleAttributeName, value: Paragraph, range: NSRange(location: 0,length: IngressTicket.length));
                        FinalString.appendAttributedString(IngressTicket);
                    }
                }
            }
        }
        
        let TotalIngressesLabel = NSMutableAttributedString(string: "Total" + "\t$" + String(self.Format.Number.stringFromNumber(TotalIngresses)!) + "\r\n");
        TotalIngressesLabel.addAttribute(NSParagraphStyleAttributeName, value: Paragraph, range: NSRange(location: 0,length: TotalIngressesLabel.length));
        FinalString.appendAttributedString(TotalIngressesLabel);
        
        FinalString.appendAttributedString(Separador);

        
        
        let TotalTicketsTotal = TotalCars + TotalServs + TotalIngresses;
        let TotalTicketsTotalLabel = NSMutableAttributedString(string: "TOTAL : " + "\t$" + String(self.Format.Number.stringFromNumber(TotalTicketsTotal)!) + "\r\n");
        TotalTicketsTotalLabel.addAttribute(NSParagraphStyleAttributeName, value: Paragraph, range: NSRange(location: 0,length: TotalTicketsTotalLabel.length));
        FinalString.appendAttributedString(TotalTicketsTotalLabel);
        FinalString.appendAttributedString(Separador);
        
        
        
        
        
        
        
        let SpendLabel = NSMutableAttributedString(string:"Gastos\r\n");
        SpendLabel.addAttribute(NSParagraphStyleAttributeName, value: CenterAtt, range: NSRange(location: 0,length: SpendLabel.length));
        SpendLabel.addAttribute(NSBackgroundColorAttributeName, value: UIColor.blackColor(), range: NSRange(location: 0, length: SpendLabel.length - 2));
        SpendLabel.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSRange(location:0,length: SpendLabel.length));
        FinalString.appendAttributedString(SpendLabel);
        var TotalSpends = 0.0;
        for (spend,obj)in ParseSpends {
            if let dict = obj as? NSDictionary{
                if let count = dict["Count"] as? Int {
                    if let total = dict["Total"] as? Double {
                        TotalSpends = TotalSpends + total;
                        let SpendTicket = NSMutableAttributedString(string: "\(count).- \(spend)\t$" + String(self.Format.Number.stringFromNumber(total)!) + "\r\n");
                        SpendTicket.addAttribute(NSParagraphStyleAttributeName, value: Paragraph, range: NSRange(location: 0,length: SpendTicket.length));
                        FinalString.appendAttributedString(SpendTicket);
                    }
                }
            }
        }
        
        let TotalSpendsLabel = NSMutableAttributedString(string: "Total" + "\t$" + String(self.Format.Number.stringFromNumber(TotalSpends)!) + "\r\n");
        TotalSpendsLabel.addAttribute(NSParagraphStyleAttributeName, value: Paragraph, range: NSRange(location: 0,length: TotalSpendsLabel.length));
        FinalString.appendAttributedString(TotalSpendsLabel);
        
        FinalString.appendAttributedString(Separador);
        
        
        
        
        
        let PaybillLabel = NSMutableAttributedString(string:"Vales\r\n");
        PaybillLabel.addAttribute(NSParagraphStyleAttributeName, value: CenterAtt, range: NSRange(location: 0,length: PaybillLabel.length));
        PaybillLabel.addAttribute(NSBackgroundColorAttributeName, value: UIColor.blackColor(), range: NSRange(location: 0, length: PaybillLabel.length - 2));
        PaybillLabel.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSRange(location:0,length: PaybillLabel.length));
        FinalString.appendAttributedString(PaybillLabel);
        var TotalPaybills = 0.0;
        for (paybill,obj)in ParsePaybills {
            if let dict = obj as? NSDictionary{
                if let count = dict["Count"] as? Int {
                    if let total = dict["Total"] as? Double {
                        TotalPaybills = TotalPaybills + total;
                        let PaybillTicket = NSMutableAttributedString(string: "\(count).- \(paybill)\t$" + String(self.Format.Number.stringFromNumber(total)!) + "\r\n");
                        PaybillTicket.addAttribute(NSParagraphStyleAttributeName, value: Paragraph, range: NSRange(location: 0,length: PaybillTicket.length));
                        FinalString.appendAttributedString(PaybillTicket);
                    }
                }
            }
        }
        
        let TotalPaybillsLabel = NSMutableAttributedString(string: "Total" + "\t$" + String(self.Format.Number.stringFromNumber(TotalPaybills)!) + "\r\n");
        TotalPaybillsLabel.addAttribute(NSParagraphStyleAttributeName, value: Paragraph, range: NSRange(location: 0,length: TotalPaybillsLabel.length));
        FinalString.appendAttributedString(TotalPaybillsLabel);
        
        FinalString.appendAttributedString(Separador);
        
        let difference = TotalCars + TotalServs + TotalIngresses - TotalSpends - TotalPaybills;
        let DifferenceLabel = NSMutableAttributedString(string: "Diferencia" + "\t$" + String(self.Format.Number.stringFromNumber(difference)!) + "\r\n\r\n\r\n");
        DifferenceLabel.addAttribute(NSParagraphStyleAttributeName, value: Paragraph, range: NSRange(location: 0,length: DifferenceLabel.length));
        FinalString.appendAttributedString(DifferenceLabel);

        let FinalVars =
        "Caja: ______________________________\r\n\r\n" +
        "VoS: ______________________________\r\n\r\n" +
        "Total: _____________________________\r\n\r\n" +
        "Gastos: ___________________________\r\n\r\n" +
        "Cambio: __________________________\r\n\r\n" +
        "Vales: _____________________________\r\n\r\n" +
        "Billetes: ___________________________\r\n\r\n" +
        "Total: _____________________________\r\n\r\n" +
        "Diferencia: ________________________" ;
        
        let FooterTicket = NSMutableAttributedString(string: FinalVars);
        FooterTicket.addAttribute(NSParagraphStyleAttributeName, value: RightAtt, range: NSRange(location: 0,length: FooterTicket.length));
        FinalString.appendAttributedString(FooterTicket);
        
        //SETTING UP FOR CREATE THE PRINTER IMAGE:
        //Se agrega la fuente general a todo el ticket.
        FinalString.addAttribute(NSFontAttributeName, value: UIFont(name: self.fontName, size: self.fontSize)!, range: NSRange(location: 0, length: FinalString.length));
        
        //Se saca el tamaño estimado de todo el ticket:
        let stringtotal = FinalString.string as NSString;
        let TicketAreaSize = CGSizeMake(CGFloat(self.shortWidth), 10000);
        var TicketRectSize = stringtotal.boundingRectWithSize(TicketAreaSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: RobotoAttribute, context: nil);
        let Messured = TicketRectSize.size;
        TicketRectSize.origin.y = TicketRectSize.origin.y + LogoRect.size.height + 20;
        TicketRectSize.size.width = CGFloat(self.shortWidth);
        
        if(UIScreen.mainScreen().respondsToSelector(#selector(NSDecimalNumberBehaviors.scale))){
            if(UIScreen.mainScreen().scale == 2.0){
                UIGraphicsBeginImageContextWithOptions(Messured, false, 1.0);
            }else{
                UIGraphicsBeginImageContext(Messured);
            }
        }else{
            UIGraphicsBeginImageContext(Messured);
        }
        
        let context = UIGraphicsGetCurrentContext();
        var color = UIColor.whiteColor();
        color.set();
        let Rect = CGRectMake(0, 0, Messured.width + 1, Messured.height + 1);
        CGContextFillRect(context!, Rect);
        color = UIColor.blackColor();
        color.set();
        Logo.drawInRect(LogoRect);
        FinalString.drawInRect(TicketRectSize);
        TicketImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        
        return TicketImage;
        
    }
    
    func ValeToImage(Vale:BaseModel) -> UIImage {
        
        
        //////////////// VARIABLES:
        var TicketImage = UIImage();
        let FinalString = NSMutableAttributedString();
        var ActualIndex = 0;
        let Logo = UIImage(named: "Logo_Print.png")!;
        let LogoRect = CGRect(x: 150, y: 0, width: Logo.size.width, height: Logo.size.height);
        
        let CenterAtt = NSMutableParagraphStyle();
        CenterAtt.maximumLineHeight = 30.0;
        CenterAtt.alignment = NSTextAlignment.Center;
        let LeftAtt = NSMutableParagraphStyle();
        LeftAtt.maximumLineHeight = 30.0;
        LeftAtt.alignment = NSTextAlignment.Left;
        let RightAtt = NSMutableParagraphStyle();
        RightAtt.maximumLineHeight = 30.0;
        RightAtt.alignment = NSTextAlignment.Left;
        let Paragraph = NSMutableParagraphStyle();
        let Tab = NSTextTab(textAlignment: NSTextAlignment.Right, location: CGFloat(self.shortWidth - 30), options:[:]);
        Paragraph.tabStops = [Tab];
        
        let RobotoAttribute = [NSFontAttributeName:UIFont(name: self.fontName, size: self.fontSize)!];
        
        ////////////////ENCABEZADO
        
        let Header = NSMutableAttributedString(string: self.headerString);
        Header.addAttribute(NSParagraphStyleAttributeName, value: CenterAtt, range: NSRange(location: 0,length: Header.length));
        FinalString.appendAttributedString(Header);
        ActualIndex = ActualIndex + Header.length;

        
        let DateTicket = NSMutableAttributedString(string: Format.DatePretty.stringFromDate(Vale.date) + "\r\n");
        DateTicket.addAttribute(NSParagraphStyleAttributeName, value: CenterAtt, range: NSRange(location: 0,length: DateTicket.length));
        FinalString.appendAttributedString(DateTicket);
        
        let OperatorTicket = NSMutableAttributedString(string:"Operador: " + self.UsuarioEnSesion.name + "\r\n");
        OperatorTicket.addAttribute(NSParagraphStyleAttributeName, value: CenterAtt, range: NSRange(location: 0,length: OperatorTicket.length));
        FinalString.appendAttributedString(OperatorTicket);
        
        let Separador = NSMutableAttributedString(string:"--------------------VALE-------------------\r\n");
        Separador.addAttribute(NSParagraphStyleAttributeName, value: CenterAtt, range: NSRange(location: 0,length: Separador.length));
        FinalString.appendAttributedString(Separador);
        
        let OwnerLabel = NSMutableAttributedString(string:"Portador\r\n\r\n");
        OwnerLabel.addAttribute(NSParagraphStyleAttributeName, value: CenterAtt, range: NSRange(location: 0,length: OwnerLabel.length));
        OwnerLabel.addAttribute(NSBackgroundColorAttributeName, value: UIColor.blackColor(), range: NSRange(location: 0, length: OwnerLabel.length - 4));
        OwnerLabel.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSRange(location:0,length: OwnerLabel.length));
        FinalString.appendAttributedString(OwnerLabel);
        
        let Owner = NSMutableAttributedString(string: Vale.denomination + "\r\n\r\n");
        Owner.addAttribute(NSParagraphStyleAttributeName, value: CenterAtt, range: NSRange(location: 0,length: Owner.length));
        FinalString.appendAttributedString(Owner);
        
        
        let TotalLabel = NSMutableAttributedString(string:"Cantidad\r\n\r\n");
        TotalLabel.addAttribute(NSParagraphStyleAttributeName, value: CenterAtt, range: NSRange(location: 0,length: TotalLabel.length));
        TotalLabel.addAttribute(NSBackgroundColorAttributeName, value: UIColor.blackColor(), range: NSRange(location: 0, length: TotalLabel.length - 4));
        TotalLabel.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSRange(location:0,length: TotalLabel.length));
        FinalString.appendAttributedString(TotalLabel);
        
        let Total = NSMutableAttributedString(string: "$\(self.Format.Number.stringFromNumber(Vale.total)!)\r\n\r\n");
        Total.addAttribute(NSParagraphStyleAttributeName, value: CenterAtt, range: NSRange(location: 0,length: Total.length));
        FinalString.appendAttributedString(Total);
        
        
        let SignLabel = NSMutableAttributedString(string:"Firma\r\n\r\n");
        SignLabel.addAttribute(NSParagraphStyleAttributeName, value: CenterAtt, range: NSRange(location: 0,length: SignLabel.length));
        SignLabel.addAttribute(NSBackgroundColorAttributeName, value: UIColor.blackColor(), range: NSRange(location: 0, length: SignLabel.length - 4));
        SignLabel.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSRange(location:0,length: SignLabel.length));
        FinalString.appendAttributedString(SignLabel);
        
        let Sign = NSMutableAttributedString(string:"\r\n\r\n\r\n\r\n___________________________________\r\n");
        Sign.addAttribute(NSParagraphStyleAttributeName, value: CenterAtt, range: NSRange(location: 0,length: Sign.length));
        FinalString.appendAttributedString(Sign);
        
        //SETTING UP FOR CREATE THE PRINTER IMAGE:
        //Se agrega la fuente general a todo el ticket.
        FinalString.addAttribute(NSFontAttributeName, value: UIFont(name: self.fontName, size: self.fontSize)!, range: NSRange(location: 0, length: FinalString.length));
        
        //Se saca el tamaño estimado de todo el ticket:
        let stringtotal = FinalString.string as NSString;
        let TicketAreaSize = CGSizeMake(CGFloat(self.shortWidth), 10000);
        var TicketRectSize = stringtotal.boundingRectWithSize(TicketAreaSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: RobotoAttribute, context: nil);
        let Messured = TicketRectSize.size;
        TicketRectSize.origin.y = TicketRectSize.origin.y + LogoRect.size.height + 20;
        TicketRectSize.size.width = CGFloat(self.shortWidth);
        
        if(UIScreen.mainScreen().respondsToSelector(#selector(NSDecimalNumberBehaviors.scale))){
            if(UIScreen.mainScreen().scale == 2.0){
                UIGraphicsBeginImageContextWithOptions(Messured, false, 1.0);
            }else{
                UIGraphicsBeginImageContext(Messured);
            }
        }else{
            UIGraphicsBeginImageContext(Messured);
        }
        
        let context = UIGraphicsGetCurrentContext();
        var color = UIColor.whiteColor();
        color.set();
        let Rect = CGRectMake(0, 0, Messured.width + 1, Messured.height + 1);
        CGContextFillRect(context!, Rect);
        color = UIColor.blackColor();
        color.set();
        Logo.drawInRect(LogoRect);
        FinalString.drawInRect(TicketRectSize);
        TicketImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        
        return TicketImage;
        
    }
    
    func TicketToImage(Ticket:TicketModel, isClient:Bool) -> UIImage {
        
        //////////////// VARIABLES:
        var TicketImage = UIImage();
        let FinalString = NSMutableAttributedString();
        var ActualIndex = 0;
        let Logo = UIImage(named: "Logo_Print.png")!;
        let LogoRect = CGRect(x: 150, y: 0, width: Logo.size.width, height: Logo.size.height);
        
        let CenterAtt = NSMutableParagraphStyle();
        CenterAtt.maximumLineHeight = 30.0;
        CenterAtt.alignment = NSTextAlignment.Center;
        let LeftAtt = NSMutableParagraphStyle();
        LeftAtt.maximumLineHeight = 30.0;
        LeftAtt.alignment = NSTextAlignment.Left;
        let RightAtt = NSMutableParagraphStyle();
        RightAtt.maximumLineHeight = 30.0;
        RightAtt.alignment = NSTextAlignment.Left;
        let Paragraph = NSMutableParagraphStyle();
        let Tab = NSTextTab(textAlignment: NSTextAlignment.Right, location: CGFloat(self.shortWidth - 30), options:[:]);
        Paragraph.tabStops = [Tab];
        
        let RobotoAttribute = [NSFontAttributeName:UIFont(name: self.fontName, size: self.fontSize)!];
        
        ////////////////ENCABEZADO
        
        if(Ticket.status == "Charged"){  // si es un ticket bueno
            let Header = NSMutableAttributedString(string: self.headerString);
            Header.addAttribute(NSParagraphStyleAttributeName, value: CenterAtt, range: NSRange(location: 0,length: Header.length));
            FinalString.appendAttributedString(Header);
            ActualIndex = ActualIndex + Header.length;
        }else{ // cualquier otro (cancelado, cobrando, etc)
            let message = "Ticket cancelado\n\n";
            let Header = NSMutableAttributedString(string: message);
            Header.addAttribute(NSParagraphStyleAttributeName, value: CenterAtt, range: NSRange(location: 0,length: Header.length));
            FinalString.appendAttributedString(Header);
            ActualIndex = ActualIndex + Header.length;
        }
        
        let Separador = NSMutableAttributedString(string:"---------------------------------------------------------\r\n");
        Separador.addAttribute(NSParagraphStyleAttributeName, value: CenterAtt, range: NSRange(location: 0,length: Separador.length));
        FinalString.appendAttributedString(Separador);
        
        //let OrderTicket = NSMutableAttributedString(string: "Numero Ticket: #" + Ticket.order_id + "\r\n");
        //OrderTicket.addAttribute(NSParagraphStyleAttributeName, value: CenterAtt, range: NSRange(location: 0,length: OrderTicket.length));
        //FinalString.appendAttributedString(OrderTicket);
        
        var customer = "Cliente";
        if(!isClient) {
            customer = "Caja";
        }
        let CustomerTicket = NSMutableAttributedString(string: customer + "\r\n");
        CustomerTicket.addAttribute(NSParagraphStyleAttributeName, value: CenterAtt, range: NSRange(location: 0,length: CustomerTicket.length));
        FinalString.appendAttributedString(CustomerTicket);
        
        
        
        let DateTicket = NSMutableAttributedString(string:Ticket.entryDate + "\r\n");
        DateTicket.addAttribute(NSParagraphStyleAttributeName, value: CenterAtt, range: NSRange(location: 0,length: DateTicket.length));
        FinalString.appendAttributedString(DateTicket);
    
        let WashingTimeTicket = NSMutableAttributedString(string:"Tiempo de servicio: " + Ticket.washingTime + "\r\n");
        WashingTimeTicket.addAttribute(NSParagraphStyleAttributeName, value: CenterAtt, range: NSRange(location: 0,length: WashingTimeTicket.length));
        FinalString.appendAttributedString(WashingTimeTicket);
        
        let ServLabel = NSMutableAttributedString(string:"Servicios\r\n");
        ServLabel.addAttribute(NSParagraphStyleAttributeName, value: CenterAtt, range: NSRange(location: 0,length: ServLabel.length));
        ServLabel.addAttribute(NSBackgroundColorAttributeName, value: UIColor.blackColor(), range: NSRange(location: 0, length: ServLabel.length - 2));
        ServLabel.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSRange(location:0,length: ServLabel.length));
        
        FinalString.appendAttributedString(ServLabel);
        
        let CarTicket = NSMutableAttributedString(string: (Ticket.car?.denomination)! + "\t$" + String(self.Format.Number.stringFromNumber((Ticket.car?.price)!)!) + "\r\n");
        CarTicket.addAttribute(NSParagraphStyleAttributeName, value: Paragraph, range: NSRange(location: 0,length: CarTicket.length));
        FinalString.appendAttributedString(CarTicket);
        
        
        for serv in Ticket.services {
            let ServTicket = NSMutableAttributedString(string: serv.denomination + "\t$" + String(self.Format.Number.stringFromNumber(serv.price)!) + "\r\n");
            ServTicket.addAttribute(NSParagraphStyleAttributeName, value: Paragraph, range: NSRange(location: 0,length: ServTicket.length));
            FinalString.appendAttributedString(ServTicket);
        }
        
        FinalString.appendAttributedString(Separador);

        let TotalTicket = NSMutableAttributedString(string: "Total" + "\t$" + String(self.Format.Number.stringFromNumber(Ticket.total)!) + "\r\n");
        TotalTicket.addAttribute(NSParagraphStyleAttributeName, value: Paragraph, range: NSRange(location: 0,length: TotalTicket.length));
        FinalString.appendAttributedString(TotalTicket);
        
        let FooterTicket = NSMutableAttributedString(string: self.footerString);
        FooterTicket.addAttribute(NSParagraphStyleAttributeName, value: CenterAtt, range: NSRange(location: 0,length: FooterTicket.length));
        FinalString.appendAttributedString(FooterTicket);
        
        
        
        //SETTING UP FOR CREATE THE PRINTER IMAGE:
        //Se agrega la fuente general a todo el ticket.
        FinalString.addAttribute(NSFontAttributeName, value: UIFont(name: self.fontName, size: self.fontSize)!, range: NSRange(location: 0, length: FinalString.length));
        
        //Se saca el tamaño estimado de todo el ticket:
        let stringtotal = FinalString.string as NSString;
        let TicketAreaSize = CGSizeMake(CGFloat(self.shortWidth), 10000);
        var TicketRectSize = stringtotal.boundingRectWithSize(TicketAreaSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: RobotoAttribute, context: nil);
        let Messured = TicketRectSize.size;
        TicketRectSize.origin.y = TicketRectSize.origin.y + LogoRect.size.height + 20;
        TicketRectSize.size.width = CGFloat(self.shortWidth);

        if(UIScreen.mainScreen().respondsToSelector(#selector(NSDecimalNumberBehaviors.scale))){
            if(UIScreen.mainScreen().scale == 2.0){
                UIGraphicsBeginImageContextWithOptions(Messured, false, 1.0);
            }else{
                UIGraphicsBeginImageContext(Messured);
            }
        }else{
            UIGraphicsBeginImageContext(Messured);
        }
        
        let context = UIGraphicsGetCurrentContext();
        var color = UIColor.whiteColor();
        color.set();
        let Rect = CGRectMake(0, 0, Messured.width + 1, Messured.height + 1);
        CGContextFillRect(context!, Rect);
        color = UIColor.blackColor();
        color.set();
        Logo.drawInRect(LogoRect);
        FinalString.drawInRect(TicketRectSize);
        TicketImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        
        return TicketImage;
    }
    
}
