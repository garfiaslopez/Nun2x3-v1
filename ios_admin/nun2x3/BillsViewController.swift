//
//  BillsViewController.swift
//  NUn2x3
//
//  Created by Jose De Jesus Garfias Lopez on 27/09/15.
//  Copyright (c) 2015 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import MaterialKit
import SWTableViewCell

class BillsViewController: MenuViewController {
    
    @IBOutlet weak var OwnerTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.OwnerTextField.layer.borderColor = UIColor.clearColor().CGColor;
        self.OwnerTextField.tintColor = UIColor.MKColor.Orange;

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        self.ReloadData("bill");
    }
    
    @IBAction func Upload(sender: AnyObject) {
        
        if(self.ConceptoTextField.text != nil && self.CantidadTextField.text != nil && Int(self.CantidadTextField.text!) != nil){
            
            let paybill:BaseModel = BaseModel();
            
            paybill.lavado_id = self.LavadoEnSesion._id;
            paybill.denomination = self.ConceptoTextField.text!;
            paybill.total = Double(self.CantidadTextField.text!)!;
            paybill.user = self.UsuarioEnSesion.name;
            paybill.date = Format.ParseMomentDate(self.UsuarioEnSesion.date);
            paybill.isMonthly = false;
            paybill.owner = self.OwnerTextField.text!;
            paybill.typeBase = "bill";
            paybill.corte_id = self.UsuarioEnSesion.corte_id;
            
            CozyLoadingActivity.show("Imprimiendo...", disableUI: true);
            
            if let parent = self.presentingViewController as? MainViewController {
                parent.PrinterIO.PrintVale(paybill)
                CozyLoadingActivity.hide(success: true, animated: true);
            }
            self.UploadObj("/paybill", Section: "paybills", TypeBase:"bill", Obj: paybill);
            self.OwnerTextField.text = "";

        }else{
            self.alerta("Error", Mensaje: "Introducir un valor valido en los campos.");
        }
    }
    
    @IBAction func CloseView(sender: AnyObject) {
        self.CloseView();
    }
    
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
        
        if index == 0 {
            let cellIndexPath = self.ListTableView.indexPathForCell(cell);
            
            self.DeleteObj("/paybill", Section: "paybills", TypeBase: "bill", Obj: self.DataArray[cellIndexPath!.row]);
            self.DataArray.removeAtIndex(cellIndexPath!.row);
            self.ListTableView.deleteRowsAtIndexPaths([cellIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic);
            
            self.NumberLabel.text = "#\(self.DataArray.count)";
            var total:Double = 0.0;
            for obj in self.DataArray {
                total = total + obj.total;
            }
            self.TotalLabel.text = "$" + Formatter().Number.stringFromNumber(total)!;
        }
    }
    
    
}
