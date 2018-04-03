//
//  SettingsTableController.swift
//  Ping!
//
//  Created by Darya T Jitmetta on 2/13/18.
//  Copyright © 2018 Darya T Jitmetta. All rights reserved.
//

import UIKit
import Font_Awesome_Swift

class SettingsTableController: UITableViewController {
    
    
    let defaults = UserDefaults.standard
    
    //Edit Profile Buttons
    @IBOutlet weak var editBtn1: UIButton!
    @IBOutlet weak var editBtn2: UIButton!
    
    //Notification Switches
    @IBOutlet weak var notifications: UISwitch!
    @IBOutlet weak var email: UISwitch!
    @IBOutlet weak var push: UISwitch!
    
    //GPS Update Buttons
    @IBOutlet weak var interval30s: UIButton!
    @IBOutlet weak var interval1m: UIButton!
    @IBOutlet weak var interval5m: UIButton!
    @IBOutlet weak var interval10m: UIButton!
    
    //Tracking Switch
    @IBOutlet weak var tracking: UISwitch!
    
    
    //Breadcrumb Buttons
    @IBOutlet weak var breadcrumbs: UISwitch!
    @IBOutlet weak var days1: UIButton!
    @IBOutlet weak var days3: UIButton!
    @IBOutlet weak var days7: UIButton!
    
    @IBAction func breadcrumbsSwitch(_ sender: Any) {
        if(breadcrumbs.isOn){
            defaults.set("on", forKey: "breadcrumbs")
            defaults.synchronize()
            print("turning ON breadcrumbs")
        }
        else {
            defaults.set("off", forKey: "breadcrumbs")
            defaults.synchronize()
             print("turning off breadcrumbs")
        }
    }
    
    
    
    @IBAction func days1(_ sender: Any) {
        defaults.set(-1, forKey: "breadHistory")
        defaults.synchronize()
        DispatchQueue.main.async(execute: {
            self.setBreadcrumbs(days: -1)
        })
    }
    
    @IBAction func days3(_ sender: Any) {
        defaults.set(-3, forKey: "breadHistory")
        defaults.synchronize()
        DispatchQueue.main.async(execute: {
            self.setBreadcrumbs(days: -3)
        })
    }
    
    @IBAction func days7(_ sender: Any) {
        defaults.set(-7, forKey: "breadHistory")
        defaults.synchronize()
        DispatchQueue.main.async(execute: {
            self.setBreadcrumbs(days: -7)
        })
    }
    
    func setBreadcrumbs(days: Int) {
        if(days == -1){
            days1.isHighlighted = true
            days3.isHighlighted = false
            days7.isHighlighted = false
        }
        if(days == -3){
            days1.isHighlighted = false
            days3.isHighlighted = true
            days7.isHighlighted = false
            
        }
        if(days == -7){
            days1.isHighlighted = false
            days3.isHighlighted = false
            days7.isHighlighted = true
            
        }
        
    }
    
    @IBAction func interval30s(_ sender: Any) {
        defaults.set(30, forKey: "gpsUpdate")
        defaults.synchronize()
        DispatchQueue.main.async(execute: {
            self.setGPS(interval: 30)
        })
    }
    @IBAction func interval1m(_ sender: Any) {
        defaults.set(1, forKey: "gpsUpdate")
        defaults.synchronize()
        DispatchQueue.main.async(execute: {
            self.setGPS(interval: 60)
        })
    }
    @IBAction func interval5m(_ sender: Any) {
        defaults.set(300, forKey: "gpsUpdate")
        defaults.synchronize()
        DispatchQueue.main.async(execute: {
            self.setGPS(interval: 300)
        })
    }
    
    @IBAction func interval10m(_ sender: Any) {
        defaults.set(600, forKey: "gpsUpdate")
        defaults.synchronize()
        DispatchQueue.main.async(execute: {
            self.setGPS(interval: 600)
        })
    }
    
    
    
    func setGPS(interval: Int){
        if(interval == 30) {
            interval30s.isHighlighted = true
            interval1m.isHighlighted = false
            interval5m.isHighlighted = false
            interval10m.isHighlighted = false
        }
        if(interval == 60) {
            interval30s.isHighlighted = false
            interval1m.isHighlighted = true
            interval5m.isHighlighted = false
            interval10m.isHighlighted = false
        }
        if(interval == 300) {
            interval30s.isHighlighted = false
            interval1m.isHighlighted = false
            interval5m.isHighlighted = true
            interval10m.isHighlighted = false
        }
        if(interval == 600) {
            interval30s.isHighlighted = false
            interval1m.isHighlighted = false
            interval5m.isHighlighted = false
            interval10m.isHighlighted = true
        }
    }
    
    
    //Map Display Buttons
    @IBOutlet weak var typeStandard: UIButton!
    @IBOutlet weak var typeSatelite: UIButton!
    @IBOutlet weak var typeHybrid: UIButton!
    
    //Set Map Display User Default
    @IBAction func typeStandard(_ sender: Any) {
        defaults.set("standard", forKey: "mapType")
        defaults.synchronize()
        DispatchQueue.main.async(execute: {
            self.setMapDisplay(mapButton: "standard")
        })
    }
    
    
    @IBAction func typeSatellite(_ sender: Any) {
        defaults.set("satellite", forKey: "mapType")
        defaults.synchronize()
        DispatchQueue.main.async(execute: {
            self.setMapDisplay(mapButton: "satellite")
        })
    }
    
    
    @IBAction func typeHybrid(_ sender: Any) {
        defaults.set("hybrid", forKey: "mapType")
        defaults.synchronize()
        DispatchQueue.main.async(execute: {
            self.setMapDisplay(mapButton: "hybrid")
        })
    }
    
    //Set Map Display Button
    func setMapDisplay(mapButton:String){
        if(mapButton == "standard") {
            typeStandard.isHighlighted = true
            typeSatelite.isHighlighted = false
            typeHybrid.isHighlighted = false
        }
        if(mapButton == "satellite") {
            typeStandard.isHighlighted = false
            typeSatelite.isHighlighted = true
            typeHybrid.isHighlighted = false
        }
        if(mapButton == "hybrid") {
            typeStandard.isHighlighted = false
            typeSatelite.isHighlighted = false
            typeHybrid.isHighlighted = true
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Edit Profile Arrow
        editBtn2.setFAIcon(icon: .FAArrowCircleRight, iconSize: 35, forState: .normal)
        
        //GPS Update Interval State
        if (defaults.object(forKey: "gpsUpdate") != nil) {
            let selection = (defaults.object(forKey: "gpsUpdate") as? Int)!
            setGPS(interval: selection)
        }
        else {
            setGPS(interval: 30)
            defaults.set(30, forKey: "gpsUpdate")
            defaults.synchronize()
            
        }
        
        //Map Display State
        if (defaults.object(forKey: "mapType") != nil) {
            let selection = (defaults.object(forKey: "mapType") as? String)!
            setMapDisplay(mapButton: selection)
        }
        else {
            setMapDisplay(mapButton: "standard")
            defaults.set("standard", forKey: "mapType")
            defaults.synchronize()
        }
        
        //Breadcrumb Enabled State
        if (defaults.object(forKey: "breadcrumbs") != nil) {
            let state = (defaults.object(forKey: "breadcrumbs") as? String)!
            if(state == "on"){
                breadcrumbs.setOn(true, animated: true)
            }
            else{
                breadcrumbs.setOn(false, animated: true)
            }
        }
        else {
            defaults.set("on", forKey: "breadcrumbs")
            defaults.synchronize()
        }
        
        
        //Breadcrumb Display State
        if (defaults.object(forKey: "breadHistory") != nil) {
            let selection = (defaults.object(forKey: "breadHistory") as? Int)!
            setBreadcrumbs(days: selection)
        }
        else {
            setBreadcrumbs(days: -7)
            defaults.set(-7, forKey: "breadHistory")
            defaults.synchronize()
        }
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    
    
    // MARK: - Table view data source
    
    //override func numberOfSections(in tableView: UITableView) -> Int {
    //    // #warning Incomplete implementation, return the number of sections
    //     return 0
    // }
    
    // override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //     // #warning Incomplete implementation, return the number of rows
    //     return 0
    // }
    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
