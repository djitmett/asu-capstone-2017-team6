//
//  LoginController.swift
//  Ping!
//
//  Created by Darya T Jitmetta on 11/20/17.
//  Copyright © 2017 Darya T Jitmetta. All rights reserved.
//

import UIKit

class LoginController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var error: UILabel!
    var pass = false
    
    let defaults = UserDefaults.standard
    
    @IBAction func login(_ sender: Any) {
        
        let userPhoneNumber = phoneNumber.text
        let userPassword = password.text
        
        phoneNumber.resignFirstResponder()
        password.resignFirstResponder()
        
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
        
        //Other DB values
        
        
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
                    print(msg)
                    
                    //If phonenumber exists in DB
                    if(msg == "Operation successfully!"){
                        data = parseJSON["data"] as! NSArray?
                        print(data)
                        let db_password = data[5] as? String
                        
                        //If password matches with phonenumber
                        print ("user entered" + password)
                        print (db_password!)
                        if(db_password! == password){
                            DispatchQueue.main.async(execute: {
                                self.error.text = "SUCCESS"
                            })
                            let user_first_name = data[2] as? String
                            let user_last_name = data[2] as? String
                            
                            //Set data store
                            let defaults = UserDefaults.standard
                            defaults.set(user_first_name, forKey: "userFirstName")
                            defaults.set(user_last_name, forKey: "userLastName")
                            defaults.set(phone_number, forKey: "userPhone")
                            defaults.set(true, forKey: "isLogged")
                            defaults.synchronize()
                            
                            //success
                            
                            DispatchQueue.main.async(execute: {
                                //send to login page
                                if let isUserLoggedIn = UserDefaults.standard.object(forKey: "isLogged"),
                                    isUserLoggedIn is Bool {
                                    let logged = (defaults.object(forKey: "isLogged") as? Bool)!
                                    
                                    if(logged){
                                        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                                        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "TabController") as! UITabBarController
                                        self.present(nextViewController, animated:true, completion:nil)
                                    }
                                }
                            })
                            
                            
                        }
                        else {
                            DispatchQueue.main.async(execute: {
                                self.error.text = "INCORRECT PASSWORD"
                            })
                        }
                    }
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
        print(postParameters)
        
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
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToLogin(segue:UIStoryboardSegue) { }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
