//
//  IngressesViewController.swift
//  NUn2x3
//
//  Created by Jose De Jesus Garfias Lopez on 27/09/15.
//  Copyright (c) 2015 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import SWTableViewCell

class IngressesViewController: MenuViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        self.ReloadData("ingress");
    }
    
    @IBAction func Upload(sender: AnyObject) {
        
        if(self.ConceptoTextField.text != nil && self.CantidadTextField.text != nil && Int(self.CantidadTextField.text!) != nil){
            
            let ingress:BaseModel = BaseModel();
            
            ingress.lavado_id = self.LavadoEnSesion._id;
            ingress.denomination = self.ConceptoTextField.text!;
            ingress.total = Double(self.CantidadTextField.text!)!;
            ingress.user = self.UsuarioEnSesion.name;
            ingress.date = Format.ParseMomentDate(self.UsuarioEnSesion.date);
            ingress.isMonthly = false;
            ingress.owner = "";
            ingress.typeBase = "ingress";
            ingress.corte_id = self.UsuarioEnSesion.corte_id;
            
            self.UploadObj("/ingress", Section: "ingresses", TypeBase: "ingress", Obj: ingress);
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
            
            self.DeleteObj("/ingress", Section: "ingresses", TypeBase: "ingress", Obj: self.DataArray[cellIndexPath!.row]);
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