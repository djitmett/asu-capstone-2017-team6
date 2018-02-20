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
        let logoutAlert = UIAlertController(title: "Are you sure you want to logout?", message: "All tracking data will be lost.", preferredStyle: UIAlertControllerStyle.alert)
        
        logoutAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            
            //Clearing user's device id from DB
            let user_device_id = "uninstalled app"
            var user_phone_number = ""
            //userPhone
            if (defaults.object(forKey: "userPhone") != nil){
                user_phone_number = (defaults.object(forKey: "userPhone") as? String)!}
            
            self.updateUserDevice(user_phone_number: user_phone_number,user_device_id: user_device_id)
            
            //Logging user out
            defaults.set(false, forKey: "isLogged")
            //Deleting user phone number from data store
            if (defaults.object(forKey: "userPhone") != nil) {
                defaults.removeObject(forKey: "userPhone")
            }
            if (defaults.object(forKey: "currentTrackedUser") != nil){
                defaults.removeObject(forKey: "currentTrackedUser")
                print("Cleared tracked user")
            }
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
    
    
    func updateUserDevice(user_phone_number: String,user_device_id: String){
        //DATABASE PHP SCRIPT
        let URL_SIGNUP = "http://52.42.38.63/ioswebservice/api/updateuserdevice.php?"
        let requestURL = NSURL(string: URL_SIGNUP)
        let request = NSMutableURLRequest(url: requestURL! as URL)
        request.httpMethod = "POST"
        
        var postParameters = "user_device_id=" + user_device_id
        postParameters += "&user_phone=" + user_phone_number
        //print("PostParms=" + postParameters)
        
        //adding the parameters to request body
        request.httpBody = postParameters.data(using: String.Encoding.utf8)
        
        //creating a task to send the post request
        let task = URLSession.shared.dataTask(with: request as URLRequest){
            data, response, error in
            
            if error != nil{
                print("error is \(String(describing: error))")
                return;
            }
            
            //parsing the response
            do {
                //converting resonse to NSDictionary
                let myJSON =  try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                //parsing the json
                if let parseJSON = myJSON {
                    //creating a string
                    var msg : String!
                    //getting the json response
                    msg = parseJSON["message"] as! String?
                    //printing the response
                    print("MESSAGE=" + msg)
                }
            } catch {
                print(error)
            }
        }
        //executing the task
        task.resume()
        //Prints HTTP POST data in console
        //print(postParameters)
    }
    
    //Function call to unwind page views
    func unwind() {
        //Navigate user to login page
        //performSegue(withIdentifier: "unwindSegueToLogin", sender: self)
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "Login") as UIViewController
        self.present(nextViewController, animated:true, completion:nil)
    }
    override func viewDidLoad() {
        var firstName = ""
        var lastName = ""
        var phoneNumber = ""
        
        super.viewDidLoad()
        
        if (defaults.object(forKey: "userFirstName") != nil) {
            firstName = (defaults.object(forKey: "userFirstName") as? String)!
        }
        if (defaults.object(forKey: "userLastName") != nil) {
            lastName = (defaults.object(forKey: "userLastName") as? String)!
        }
        if (defaults.object(forKey: "userPhone") != nil) {
            phoneNumber = (defaults.object(forKey: "userPhone") as? String)!
        }
        
       
        self.userName.text = firstName + " "  + lastName
        self.userPhoneNumber.text = phoneNumber
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var firstName = ""
        var lastName = ""
        var phoneNumber = ""
        
        super.viewDidLoad()
        
        if (defaults.object(forKey: "userFirstName") != nil) {
            firstName = (defaults.object(forKey: "userFirstName") as? String)!
        }
        if (defaults.object(forKey: "userLastName") != nil) {
            lastName = (defaults.object(forKey: "userLastName") as? String)!
        }
        if (defaults.object(forKey: "userPhone") != nil) {
            phoneNumber = (defaults.object(forKey: "userPhone") as? String)!
        }
        
        
        self.userName.text = firstName + " "  + lastName
        self.userPhoneNumber.text = phoneNumber
    }
}
