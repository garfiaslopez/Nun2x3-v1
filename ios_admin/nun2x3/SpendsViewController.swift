//
//  SpendsViewController.swift
//  NUn2x3
//
//  Created by Jose De Jesus Garfias Lopez on 27/09/15.
//  Copyright (c) 2015 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import SWTableViewCell

class SpendsViewController: MenuViewController{
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        self.ReloadData("spend");
    }
    
    @IBAction func UploadSpend(sender: AnyObject) {
        
        if(self.ConceptoTextField.text != "" && self.CantidadTextField.text != "" && Int(self.CantidadTextField.text!) != nil){
            
            let spend:BaseModel = BaseModel();
            
            spend.lavado_id = self.LavadoEnSesion._id;
            spend.denomination = self.ConceptoTextField.text!;
            spend.total = Double(self.CantidadTextField.text!)!;
            spend.user = self.UsuarioEnSesion.name;
            spend.date = Format.ParseMomentDate(self.UsuarioEnSesion.date);
            spend.isMonthly = false;
            spend.owner = "";
            spend.typeBase = "spend";
            spend.corte_id = self.UsuarioEnSesion.corte_id;
            
            self.UploadObj("/spend", Section: "spends", TypeBase: "spend", Obj: spend);
            
        }else{
            self.alerta("Error", Mensaje: "Introducir un valor valido en los campos.");
        }
        
        self.ListTableView.reloadData();
    }
    
    @IBAction func CloseView(sender: AnyObject) {
        self.CloseView();
    }
    
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
        
        if index == 0 {
            let cellIndexPath = self.ListTableView.indexPathForCell(cell);
            
            self.DeleteObj("/spend", Section: "spends", TypeBase: "spend", Obj: self.DataArray[cellIndexPath!.row]);
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
