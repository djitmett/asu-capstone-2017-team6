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
        
        //Navigate user to login page
        performSegue(withIdentifier: "unwindSegueToLogin", sender: self)

        //Logging user out
        defaults.set(false, forKey: "isLogged")
        //Deleting user phone number from data store
        defaults.removeObject(forKey: "userPhone")
        //Updating data store
        print("Resetting username-start")
        defaults.synchronize()
        print("Resetting username-end")

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
