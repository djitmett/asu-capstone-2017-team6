//
//  LoginController.swift
//  Ping!
//
//  Created by Darya T Jitmetta on 11/20/17.
//  Copyright © 2017 Darya T Jitmetta. All rights reserved.
//

import UIKit
import Font_Awesome_Swift

class LoginController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var error: UILabel!
    @IBOutlet weak var continueBtn: UIButton!
    
    
    //Define UserDefaults
    let defaults = UserDefaults.standard
    
    @IBAction func login(_ sender: Any) {
        
        let userPhoneNumber = phoneNumber.text
        let userPassword = password.text
        
        phoneNumber.resignFirstResponder()
        password.resignFirstResponder()
        
        //Call login function
        login_db(phone_number: userPhoneNumber!, password: userPassword!)
        
    }
    
    //Validate login with database
    func login_db(phone_number:String, password:String) {
        
        //DATABASE PHP SCRIPT
        let URL_SIGNUP = "http://52.42.38.63/ioswebservice/api/getuserdata.php?"
        
        //URL is defined above
        let requestURL = NSURL(string: URL_SIGNUP)
        
        //creating NSMutableURLRequest
        let request = NSMutableURLRequest(url: requestURL! as URL)
        
        //setting the method to post
        request.httpMethod = "POST"
        
        //creating the post parameter by concatenating the keys and values from text field
        let postParameters = "user_phone="+phone_number;
        
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
                    var data : NSArray!
                    
                    //getting the json response
                    msg = parseJSON["message"] as! String?
                    
                    //printing the response
                    //print(msg)
                    
                    //If phonenumber exists in DB
                    if(msg == "Operation successfully!"){
                        data = parseJSON["data"] as! NSArray?
                        //print(data)
                        let db_password = data[5] as? String
                        
                        //PASSWORD DEBUG
                        //print ("user entered" + password)
                        //print (db_password!)
                        
                        //If password matches DB password
                        if(db_password! == password){
                            DispatchQueue.main.async(execute: {
                                self.error.text = ""
                            })
                            //Parse data
                            let user_first_name = data[2] as? String
                            let user_last_name = data[3] as? String
                            
                            //Set data store
                            let defaults = UserDefaults.standard
                            defaults.set(user_first_name, forKey: "userFirstName")
                            defaults.set(user_last_name, forKey: "userLastName")
                            defaults.set(phone_number, forKey: "userPhone")
                            defaults.set(true, forKey: "isLogged")
                            defaults.synchronize()
                            
                            //Once logged in transfer user to map view
                            DispatchQueue.main.async(execute: {
                                //send to login page
                                if let isUserLoggedIn = UserDefaults.standard.object(forKey: "isLogged"),
                                    isUserLoggedIn is Bool {
                                    let logged = (defaults.object(forKey: "isLogged") as? Bool)!
                                    
                                    if(logged){
                                        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                                        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "MainNavController")
                                        self.present(nextViewController, animated:true, completion:nil)
                                        
                                        var user_device_id = ""
                                        var user_phone_number = ""
                                        //userPhone
                                        if (defaults.object(forKey: "GT_PLAYER_ID_LAST") != nil){
                                            user_device_id = (defaults.object(forKey: "GT_PLAYER_ID_LAST") as? String)!}
                                        if (defaults.object(forKey: "userPhone") != nil){
                                            user_phone_number = (defaults.object(forKey: "userPhone") as? String)!}
                                        
                                        self.updateUserDevice(user_phone_number: user_phone_number,user_device_id: user_device_id)
                                    }
                                }
                            })                                                        
                        }
                            //Password does not match phonenumber
                        else {
                            DispatchQueue.main.async(execute: {
                                self.error.text = "INCORRECT PASSWORD"
                            })
                        }
                    }
                    //Phonenumber does not exist in DB
                    if(msg == "User does not exist!"){
                        DispatchQueue.main.async(execute: {
                            self.error.text = "USER DOES NOT EXIST!"
                        })
                    }
                }
            } catch {
                print(error)
            }
            
        }
        
        //executing the task
        task.resume()
        //Prints HTTP POST data in console
        //print(postParameters)
        
        //Clear fields after entry
        self.phoneNumber.text = ""
        self.password.text = ""
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneNumber.delegate = self
        password.delegate = self
        self.hideKeyboard()
        
        // Left View Icons
        phoneNumber.setLeftViewFAIcon(icon: .FAPhone, leftViewMode: .always, textColor: .white, backgroundColor: .clear, size: nil)
        password.setLeftViewFAIcon(icon: .FALock, leftViewMode: .always, textColor: .white, backgroundColor: .clear, size: nil)
        
        phoneNumber.layer.cornerRadius = 5
        password.layer.cornerRadius = 5
        
    }
    
    //Segue link
    @IBAction func unwindToLogin(segue:UIStoryboardSegue) { }
    
}

