//
//  ProfileController.swift
//  Ping!
//
//  Created by Darya T Jitmetta on 11/20/17.
//  Copyright © 2017 Darya T Jitmetta. All rights reserved.
//

import UIKit

class ProfileController: UIViewController {
    
    @IBOutlet weak var userPhoneNumber: UILabel!
    @IBOutlet weak var userName: UILabel!
    
    
      let defaults = UserDefaults.standard
    
    
    @IBAction func logout(_ sender: Any) {
        
        let defaults = UserDefaults.standard
        //Alert on attempted logout
        let logoutAlert = UIAlertController(title: "Are you sure you want to logout?", message: "All data will be lost.", preferredStyle: UIAlertControllerStyle.alert)
        
        logoutAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            
            //Logging user out
            defaults.set(false, forKey: "isLogged")
            //Deleting user phone number from data store
            defaults.removeObject(forKey: "userPhone")
            //Updating data store
            print("Resetting username-start")
            defaults.synchronize()
            print("Resetting username-end")
            
            //Navigate user to login page
            self.unwind()
        }))
        
        logoutAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            //No cancel logic needed
        }))
        
        present(logoutAlert, animated: true, completion: nil)
        
        
    }
    
    //Function call to unwind page views
    func unwind() {
        //Navigate user to login page
        performSegue(withIdentifier: "unwindSegueToLogin", sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let firstName = (defaults.object(forKey: "userFirstName") as? String)!
        let lastName = (defaults.object(forKey: "userLastName") as? String)!
        let phoneNumber = (defaults.object(forKey: "userPhone") as? String)!
        
        self.userName.text = firstName + " "  + lastName
        self.userPhoneNumber.text = phoneNumber
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
