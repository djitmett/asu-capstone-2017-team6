//
//  VerifySMSToken.swift
//  Ping!
//
//  Created by Darya T Jitmetta on 3/23/18.
//  Copyright © 2018 Darya T Jitmetta. All rights reserved.
//

import UIKit

class VerifySMSToken: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var sms_code: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sms_code.delegate = self
        self.hideKeyboard()

    }
    
    
    @IBAction func resend_verify(_ sender: Any) {
        let defaults = UserDefaults.standard
        if (defaults.object(forKey: "userPhoneVerify") != nil) {
            let phone_number = (defaults.object(forKey: "userPhoneVerify") as? String)!
            let phone_number_trim = phone_number.trimmingCharacters(in: .whitespaces)
            let verify_type = "sms"
            TwilioAPI().start_verification(phone_number:phone_number_trim, verify_type:verify_type, segue:"none")
        }
        
    }
    
    
    @IBOutlet weak var call_verify: UIButton!
    @IBAction func call_verify(_ sender: Any) {
        let defaults = UserDefaults.standard
        if (defaults.object(forKey: "userPhoneVerify") != nil) {
            let phone_number = (defaults.object(forKey: "userPhoneVerify") as? String)!
            let phone_number_trim = phone_number.trimmingCharacters(in: .whitespaces)
            let verify_type = "call"
            TwilioAPI().start_verification(phone_number:phone_number_trim, verify_type:verify_type, segue:"none")
        }
    }
    
    @IBOutlet weak var verify_sms_next: UIButton!
    
    @IBAction func verify_sms_next(_ sender: Any) {
        
        if (sms_code.text != "" ) {
            let defaults = UserDefaults.standard
            if (defaults.object(forKey: "userPhoneVerify") != nil) {
                let phone_number = (defaults.object(forKey: "userPhoneVerify") as? String)!
                let phone_number_trim = phone_number.trimmingCharacters(in: .whitespaces)
                check_verification(phone_number: phone_number_trim, sms_code: sms_code.text!)
            }
            
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func check_verification(phone_number:String, sms_code:String) {
        let headers = [
            "x-authy-api-key": "hdWHzYFILyJRhk4PAA5X6mRanNzm7x5d",
            "cache-control": "no-cache",
            "postman-token": "718a6020-f9d1-c8c5-71ed-038f42d768bd"
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.authy.com/protected/json/phones/verification/check?country_code=1&phone_number=\(phone_number)&verification_code=\(sms_code)")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error!)
            } else {
                //let httpResponse = response as? HTTPURLResponse
               // print(httpResponse!)
                
                do {

                    let myJSON =  try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary

                    if let parseJSON = myJSON {
                        var msg : String!
                        var success : Bool!

                        //getting the json response
                        msg = parseJSON["message"] as! String?
                        success = parseJSON["success"] as! Bool?
                        
                        //printing the response
                        print(msg)
                        print(success)
                        
                        //If SMS validation success
                        if(success == true){
                             DispatchQueue.main.async(execute: {
                                let successAlert = UIAlertController(title: "Success", message: "Your phone number has been validated.", preferredStyle: UIAlertControllerStyle.alert)
                                
                                successAlert.addAction(UIAlertAction(title: "Continue to Sign-Up", style: .default, handler: { (action: UIAlertAction!) in
                                    
                                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                                    let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SignUp") as UIViewController
                                    self.present(nextViewController, animated:true, completion:nil)
                                    
                                }))
                                
                                
                                self.present(successAlert, animated: true, completion: nil)
                                
                            })
                        }
                        //If SMS validation failed
                        if(success == false && msg=="Verification code is incorrect"){
                            DispatchQueue.main.async(execute: {
                                let alert = UIAlertController(title: "Error", message: "Verification code is incorrect. Please try again.", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                                
                            })
                        }
                    }
                } catch {
                    print(error)
                }
                
            }
        })
        
        dataTask.resume()
    }
    
        
    }
    
    
